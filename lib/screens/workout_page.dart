import 'dart:async';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:health/health.dart'; // REQUIRED for Heart Rate
import 'package:permission_handler/permission_handler.dart';
import 'todays_workout_page.dart';
import 'package:mobile_project/models/workout_result_model.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  // WORKOUT HISTORY
  List<WorkoutResult> history = [];
  
  // --- STEPS STATE (Pedometer) ---
  StreamSubscription<StepCount>? _stepSubscription;
  int _todaySteps = 0;
  List<double> _weeklySteps = List.filled(7, 0.0); 
  int _savedStepAnchor = 0; 
  String _lastSavedDate = ""; 
  String _stepStatus = "Init...";

  // --- HEART RATE STATE (Health Connect) ---
  List<FlSpot> _heartRateSpots = [];
  bool _isFetchingHeartRate = false;
  String _heartRateStatus = "Syncing...";

  @override
  void initState() {
    super.initState();
    _loadData();
    _initPedometer(); // Live Steps
    _fetchHeartRate(); // Watch Heart Rate
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  // ====================================================
  // 1. DATA LOADING (History & Charts)
  // ====================================================
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // A. Load Workout History
    final rawHistory = prefs.getStringList('workout_history') ?? [];
    setState(() {
      history = rawHistory.map((e) {
        final p = e.split('|');
        return WorkoutResult(
          name: "Workout",
          totalMinutes: int.parse(p[1]),
          totalCalories: int.parse(p[2]),
        );
      }).toList();
    });

    // B. Load Steps Chart
    String? weeklyRaw = prefs.getString('chart_weekly_steps');
    if (weeklyRaw != null) {
      List<double> loaded = weeklyRaw.split(',').map((e) => double.tryParse(e) ?? 0.0).toList();
      if (loaded.length < 7) loaded = List.filled(7, 0.0);
      setState(() {
        _weeklySteps = loaded;
        _todaySteps = _weeklySteps.last.toInt();
      });
    }

    // C. Load Anchors
    _savedStepAnchor = prefs.getInt('today_step_anchor') ?? 0;
    _lastSavedDate = prefs.getString('last_step_date') ?? "";
  }

  // ====================================================
  // 2. PEDOMETER LOGIC (Real-time Steps)
  // ====================================================
  Future<void> _initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      setState(() => _stepStatus = "Live");
      _stepSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: (e) => setState(() => _stepStatus = "Error"),
      );
    } else {
      setState(() => _stepStatus = "Denied");
    }
  }

  void _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final int sensorValue = event.steps;
    final String todayDate = DateTime.now().toIso8601String().split('T').first;

    // A. New Day Reset
    if (_lastSavedDate != todayDate) {
      if (_lastSavedDate.isNotEmpty) {
        _weeklySteps.removeAt(0); 
        _weeklySteps.add(0.0); 
        await prefs.setString('chart_weekly_steps', _weeklySteps.join(','));
      }
      _savedStepAnchor = sensorValue;
      _lastSavedDate = todayDate;
      await prefs.setInt('today_step_anchor', _savedStepAnchor);
      await prefs.setString('last_step_date', _lastSavedDate);
      setState(() => _todaySteps = 0);
    }

    // B. Reboot Reset
    if (sensorValue < _savedStepAnchor) {
      _savedStepAnchor = 0;
      await prefs.setInt('today_step_anchor', 0);
    }

    // C. Update UI
    int realSteps = sensorValue - _savedStepAnchor;
    if (realSteps < 0) realSteps = 0;

    if (mounted) {
      setState(() {
        _todaySteps = realSteps;
        _weeklySteps[6] = realSteps.toDouble(); // Live update chart
      });
      await prefs.setString('chart_weekly_steps', _weeklySteps.join(','));
    }
  }

  // ====================================================
  // 3. HEART RATE LOGIC (Health Connect)
  // ====================================================
  Future<void> _fetchHeartRate() async {
    setState(() => _isFetchingHeartRate = true);
    
    Health health = Health();
    var types = [HealthDataType.HEART_RATE];

    try {
      // Configure Health Connect
      await health.configure();

      // Request Permissions
      bool requested = await health.requestAuthorization(types);

      if (requested) {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day);

        // Fetch Data from Watch/Phone
        List<HealthDataPoint> hrData = await health.getHealthDataFromTypes(
          types: [HealthDataType.HEART_RATE],
          startTime: midnight,
          endTime: now,
        );

        // Sort by time
        hrData.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));

        // Convert to Chart Spots (X = Hour, Y = BPM)
        List<FlSpot> spots = hrData.map((e) {
          double hour = e.dateFrom.hour + (e.dateFrom.minute / 60.0);
          double bpm = (e.value as NumericHealthValue).numericValue.toDouble();
          return FlSpot(hour, bpm);
        }).toList();

        if (mounted) {
          setState(() {
            _heartRateSpots = spots;
            _heartRateStatus = "Synced";
            _isFetchingHeartRate = false;
          });
        }
      } else {
        setState(() {
          _heartRateStatus = "No Permission";
          _isFetchingHeartRate = false;
        });
      }
    } catch (e) {
      debugPrint("Health Error: $e");
      setState(() {
        _heartRateStatus = "Error connecting";
        _isFetchingHeartRate = false;
      });
    }
  }

  // ====================================================
  // 4. UI BUILD
  // ====================================================
  Future<void> _saveWorkout(WorkoutResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final newEntry = '$today|${result.totalMinutes}|${result.totalCalories}';
    final raw = prefs.getStringList('workout_history') ?? [];
    if (raw.isNotEmpty && raw.last == newEntry) return;
    raw.add(newEntry);
    await prefs.setStringList('workout_history', raw);
    _loadData();
  }

  int get totalMinutes => history.fold(0, (sum, e) => sum + e.totalMinutes);
  int get totalCalories => history.fold(0, (sum, e) => sum + e.totalCalories);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final shadow = isDark ? Colors.black54 : Colors.black12;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PROFILE CARD
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: shadow, blurRadius: 10)],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.red.shade400,
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text('You', style: TextStyle(color: textColor, fontSize: 16)),
                const SizedBox(height: 6),
                Text('${history.length}',
                    style: const TextStyle(color: Colors.red, fontSize: 28, fontWeight: FontWeight.bold)),
                Text('Workouts Completed', style: TextStyle(color: subTextColor)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Stat('Minutes', '$totalMinutes'),
                    _Stat('Calories', '$totalCalories'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _SectionTitle('Activity Trends'),
          const SizedBox(height: 16),

          // --- HEART RATE CHART (FROM WATCH) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: shadow, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Heart Rate (Today)', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(_heartRateStatus, style: TextStyle(color: subTextColor, fontSize: 12)),
                      ],
                    ),
                    if (_isFetchingHeartRate)
                       const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                       const Icon(Icons.favorite, color: Colors.red, size: 20),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: _heartRateSpots.isEmpty 
                    ? Center(child: Text("No heart rate data from watch", style: TextStyle(color: subTextColor)))
                    : _HeartRateChart(isDark: isDark, spots: _heartRateSpots),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // --- STEPS CHART (FROM PEDOMETER) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: shadow, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Steps (Last 7 Days)', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, color: Colors.orange, size: 20),
                        const SizedBox(width: 4),
                        Text('$_todaySteps', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: _StepsBarChart(isDark: isDark, steps: _weeklySteps),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _SectionTitle('Recent Workout'),
          const SizedBox(height: 12),
          
          if (history.isEmpty)
             Text("No workouts yet.", style: TextStyle(color: subTextColor))
          else
            ...history.reversed.map((e) => _WorkoutTile(
                result: e, cardColor: cardColor, textColor: textColor, subTextColor: subTextColor
            )),

          const SizedBox(height: 30),

          // BUTTON
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: () async {
                final result = await Navigator.push<WorkoutResult>(
                  context,
                  MaterialPageRoute(builder: (_) => const TodaysWorkoutPage()),
                );
                if (result != null) await _saveWorkout(result);
              },
              child: const Text('Go to Today’s Workout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ================== WIDGETS ==================

class _HeartRateChart extends StatelessWidget {
  final bool isDark;
  final List<FlSpot> spots;
  const _HeartRateChart({required this.isDark, required this.spots});

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox.shrink();
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4, 
              getTitlesWidget: (value, meta) {
                int hour = value.toInt();
                if (hour % 6 == 0) { 
                   return Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text('$hour:00', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 10)),
                   );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.2)),
          ),
        ],
        minX: 0, maxX: 24, minY: 40, maxY: 180, // Adjusted maxY for reasonable Heart Rate
      ),
    );
  }
}

class _StepsBarChart extends StatelessWidget {
  final bool isDark;
  final List<double> steps;

  const _StepsBarChart({required this.isDark, required this.steps});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if(index >= 0 && index < 7) {
                   // Label "Today" for index 6
                   if (index == 6) return const Padding(padding: EdgeInsets.only(top: 5), child: Text("Today", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)));
                   return Padding(padding: const EdgeInsets.only(top: 5), child: Text("D-${6-index}", style: const TextStyle(fontSize: 10)));
                }
                return const SizedBox();
              },
            )
          ), 
        ),
        borderData: FlBorderData(show: false),
        barGroups: steps.asMap().entries.map((e) {
          int index = e.key;
          double val = e.value;
          Color barColor;
          if (index == 6) {
            barColor = Colors.orange; // Highlight Today
          } else {
            barColor = val > 5000 ? Colors.green : (isDark ? Colors.grey.shade700 : Colors.grey.shade300);
          }
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: val,
                color: barColor,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)), Text(label)]);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold));
  }
}

class _WorkoutTile extends StatelessWidget {
  final WorkoutResult result;
  final Color cardColor, textColor, subTextColor;
  const _WorkoutTile({required this.result, required this.cardColor, required this.textColor, required this.subTextColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(result.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          Text('${result.totalMinutes} min • ${result.totalCalories} cal', style: TextStyle(color: subTextColor)),
        ])
      ]),
    );
  }
}
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'todays_workout_page.dart';
import 'package:mobile_project/models/workout_result_model.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  // WORKOUT HISTORY (Manual)
  List<WorkoutResult> history = [];
  
  // LIVE STEPS STATE
  StreamSubscription<StepCount>? _stepSubscription;
  int _todaySteps = 0;
  List<double> _weeklySteps = List.filled(7, 0.0); // Stores last 7 days
  
  // Internal tracking variables
  int _savedStepAnchor = 0; // The sensor value at start of today
  String _lastSavedDate = ""; 
  String _status = "Initializing...";

  @override
  void initState() {
    super.initState();
    _loadData();
    _initPedometer();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  // --- 1. DATA LOADING ---
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // A. Load Manual Workout History
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

    // B. Load Weekly Chart Data
    // Stored as string "100.0,200.0,0.0..."
    String? weeklyRaw = prefs.getString('chart_weekly_steps');
    if (weeklyRaw != null) {
      setState(() {
        _weeklySteps = weeklyRaw.split(',').map((e) => double.tryParse(e) ?? 0.0).toList();
      });
    }

    // C. Load Step Calculation Anchors
    _savedStepAnchor = prefs.getInt('today_step_anchor') ?? 0;
    _lastSavedDate = prefs.getString('last_step_date') ?? "";
  }

  // --- 2. PEDOMETER SETUP ---
  Future<void> _initPedometer() async {
    // Request Permission
    if (await Permission.activityRecognition.request().isGranted) {
      setState(() => _status = "Listening...");
      
      _stepSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
      );
    } else {
      setState(() => _status = "Permission Denied");
    }
  }

  void _onStepCountError(error) {
    setState(() => _status = "Sensor Error: $error");
  }

  // --- 3. CORE LOGIC: CALCULATE TODAY & SAVE HISTORY ---
  void _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final int sensorValue = event.steps;
    final String todayDate = DateTime.now().toIso8601String().split('T').first;

    // A. HANDLE NEW DAY (Midnight Reset)
    if (_lastSavedDate != todayDate) {
      if (_lastSavedDate.isNotEmpty) {
        // 1. Shift chart data: Remove oldest day, add Yesterday's total
        _weeklySteps.removeAt(0); 
        _weeklySteps.add(_todaySteps.toDouble());
        
        // 2. Save chart to disk
        await prefs.setString('chart_weekly_steps', _weeklySteps.join(','));
      }

      // 3. Reset for Today
      // The "Anchor" becomes the current sensor value, so steps start at 0
      _savedStepAnchor = sensorValue;
      _lastSavedDate = todayDate;
      
      await prefs.setInt('today_step_anchor', _savedStepAnchor);
      await prefs.setString('last_step_date', _lastSavedDate);
      
      // Reset displayed steps
      setState(() {
        _todaySteps = 0;
      });
    }

    // B. HANDLE PHONE REBOOT (Sensor resets to 0)
    // If current sensor value is LESS than our anchor, the phone restarted.
    if (sensorValue < _savedStepAnchor) {
      _savedStepAnchor = 0;
      await prefs.setInt('today_step_anchor', 0);
    }

    // C. CALCULATE LIVE STEPS
    int calculatedSteps = sensorValue - _savedStepAnchor;
    if (calculatedSteps < 0) calculatedSteps = 0;
    
    if (mounted) {
      setState(() {
        _todaySteps = calculatedSteps;
        _status = "Live";
      });
    }
  }

  // --- 4. SAVE MANUAL WORKOUT ---
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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

          // --- STEPS CHART (PEDOMETER VERSION) ---
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
                        Text('Steps (Last 7 Days)', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("Status: $_status", style: TextStyle(color: subTextColor, fontSize: 10)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, color: Colors.blue, size: 20),
                        const SizedBox(width: 4),
                        Text('$_todaySteps', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
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

// --- SUB WIDGETS ---

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
                const days = ['M','T','W','T','F','S','S'];
                int index = value.toInt();
                if(index >= 0 && index < 7) {
                   return Padding(padding: const EdgeInsets.only(top: 5), child: Text(days[index], style: const TextStyle(fontSize: 10)));
                }
                return const SizedBox();
              },
            )
          ), 
        ),
        borderData: FlBorderData(show: false),
        barGroups: steps.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: e.value > 5000 ? Colors.green : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
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
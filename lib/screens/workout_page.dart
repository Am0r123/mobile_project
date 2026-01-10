import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'todays_workout_page.dart';
import 'package:mobile_project/models/workout_result_model.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  WorkoutResult? lastWorkout;
  List<WorkoutResult> history = [];
  
  List<FlSpot> heartRateSpots = [];
  bool isFetchingHealthData = false;
  String healthStatus = "Syncing...";

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _fetchHealthData(); 
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('workout_history') ?? [];

    final parsed = raw.map((e) {
      final p = e.split('|');
      return WorkoutResult(
        name: "Workout",
        totalMinutes: int.parse(p[1]),
        totalCalories: int.parse(p[2]),
      );
    }).toList();

    setState(() {
      history = parsed;
      if (parsed.isNotEmpty) lastWorkout = parsed.last;
    });
  }

  // This is now the ONLY place where saving happens
  Future<void> _saveWorkout(WorkoutResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final raw = prefs.getStringList('workout_history') ?? [];
    raw.add('$today|${result.totalMinutes}|${result.totalCalories}');
    await prefs.setStringList('workout_history', raw);
    _loadHistory();
  }

  Future<void> _fetchHealthData() async {
    setState(() => isFetchingHealthData = true);
    var types = [HealthDataType.HEART_RATE, HealthDataType.STEPS];
    try {
      if (Platform.isAndroid) await Permission.activityRecognition.request();
      Health().configure();
      bool requested = await Health().requestAuthorization(types);
      if (requested) {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day);
        List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
          types: [HealthDataType.HEART_RATE],
          startTime: midnight,
          endTime: now,
        );
        healthData.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
        List<FlSpot> spots = healthData.map((e) {
          double hour = e.dateFrom.hour + (e.dateFrom.minute / 60.0);
          double bpm = (e.value as NumericHealthValue).numericValue.toDouble();
          return FlSpot(hour, bpm);
        }).toList();

        if (mounted) {
          setState(() {
            heartRateSpots = spots;
            healthStatus = spots.isEmpty ? "No data today" : "Synced";
            isFetchingHealthData = false;
          });
        }
      } else {
        setState(() {
          healthStatus = "Permission Denied";
          isFetchingHealthData = false;
        });
      }
    } catch (e) {
      debugPrint("Health Error: $e");
      setState(() {
        healthStatus = "Error loading data";
        isFetchingHealthData = false;
      });
    }
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                    style: const TextStyle(
                        color: Colors.red,
                        fontSize: 28,
                        fontWeight: FontWeight.bold)),
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
                        Text(healthStatus, style: TextStyle(color: subTextColor, fontSize: 12)),
                      ],
                    ),
                    if (isFetchingHealthData)
                       const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                       const Icon(Icons.favorite, color: Colors.red, size: 20),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 150,
                  child: heartRateSpots.isEmpty && !isFetchingHealthData 
                    ? Center(child: Text("No heart rate data from watch found.", style: TextStyle(color: subTextColor)))
                    : _HeartRateChart(isDark: isDark, spots: heartRateSpots),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

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
                    Text('Daily Steps', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Icon(Icons.directions_walk, color: Colors.blue, size: 20),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 180,
                  child: _StepsBarChart(isDark: isDark),
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
            ...history.reversed.map(
              (e) => _WorkoutTile(
                result: e,
                cardColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
              ),
            ),

          const SizedBox(height: 30),

          // --- FIXED BUTTON LOGIC ---
          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                // 1. Open the workout pages
                final result = await Navigator.push<WorkoutResult>(
                  context,
                  MaterialPageRoute(builder: (_) => const TodaysWorkoutPage()),
                );

                // 2. CHECK IF DATA CAME BACK, THEN SAVE
                if (result != null) {
                   await _saveWorkout(result);
                } else {
                   // Just in case user backed out without finishing, ensure UI is fresh
                   await _loadHistory();
                }
              },
              child: const Text(
                'Go to Today’s Workout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... Keep charts and widgets (_HeartRateChart, _StepsBarChart, _Stat, _InsightCard, _SectionTitle, _WorkoutTile) exactly as before.

// ================== UPDATED CHART WIDGET ==================

class _HeartRateChart extends StatelessWidget {
  final bool isDark;
  final List<FlSpot> spots; // Now accepts dynamic spots

  const _HeartRateChart({required this.isDark, required this.spots});

  @override
  Widget build(BuildContext context) {
    // If we are fetching or have no spots, show a flat line or empty
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
              interval: 4, // Show label every 4 hours
              getTitlesWidget: (value, meta) {
                // Convert X (double hour) to String (e.g., 14.5 -> 2pm)
                int hour = value.toInt();
                if (hour % 6 == 0) { // Labels at 6, 12, 18
                   String text = '$hour:00';
                   return Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text(text, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 10)),
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
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.2),
            ),
          ),
        ],
        // Ensure X axis covers the whole day 0-24h
        minX: 0,
        maxX: 24,
        minY: 40, // Reasonable min HR
        maxY: 200, // Reasonable max HR
      ),
    );
  }
}

// ... Keep _StepsBarChart, _Stat, _InsightCard, _SectionTitle, _WorkoutTile exactly as they were before ...
// (I will omit them here to save space, but they must be included in your file)

class _StepsBarChart extends StatelessWidget {
  final bool isDark;
  const _StepsBarChart({required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Static Data for now (You can use Health package to make this dynamic too)
    final List<double> weeklySteps = [4500, 6200, 3100, 8900, 10500, 5600, 7100];

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
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                if (value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: weeklySteps.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: e.value > 8000 ? Colors.green : Colors.grey.shade400,
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
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
        Text(label),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;
  final Color shadow;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
    required this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: shadow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.red, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  final WorkoutResult result;
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;

  const _WorkoutTile({
    required this.result,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.name, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              Text('${result.totalMinutes} min • ${result.totalCalories} cal',
                  style: TextStyle(color: subTextColor)),
            ],
          )
        ],
      ),
    );
  }
}

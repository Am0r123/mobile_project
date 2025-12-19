import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _loadHistory();
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

  Future<void> _saveWorkout(WorkoutResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;

    final raw = prefs.getStringList('workout_history') ?? [];
    raw.add('$today|${result.totalMinutes}|${result.totalCalories}');
    await prefs.setStringList('workout_history', raw);

    _loadHistory();
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

          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _InsightCard(
                  title: 'Sleep',
                  value: '6h 41m',
                  subtitle: 'Restless',
                  icon: Icons.bedtime,
                  cardColor: cardColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  shadow: shadow,
                ),
                _InsightCard(
                  title: 'Heart',
                  value: '84 bpm',
                  subtitle: 'Resting',
                  icon: Icons.favorite,
                  cardColor: cardColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  shadow: shadow,
                ),
                _InsightCard(
                  title: 'Weight',
                  value: '3.9 lbs',
                  subtitle: 'To Goal',
                  icon: Icons.monitor_weight,
                  cardColor: cardColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  shadow: shadow,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _SectionTitle('Recent Workout'),
          const SizedBox(height: 12),
          ...history.reversed.map(
            (e) => _WorkoutTile(
              result: e,
              cardColor: cardColor,
              textColor: textColor,
              subTextColor: subTextColor,
            ),
          ),

          const SizedBox(height: 30),

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
                final result = await Navigator.push<WorkoutResult>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TodaysWorkoutPage(),
                  ),
                );
                if (result != null) await _saveWorkout(result);
              },
              child: const Text(
                'Go to Today’s Workout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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

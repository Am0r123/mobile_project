import 'package:flutter/material.dart';
import 'package:mobile_project/screens/workout_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_project/models/workout_result_model.dart';
import 'workout_session_page.dart';

class Exercise {
  final String name;
  final int minutes;
  final int caloriesPerMinute;

  Exercise({
    required this.name,
    required this.minutes,
    required this.caloriesPerMinute,
  });
}

class TodaysWorkoutPage extends StatefulWidget {
  const TodaysWorkoutPage({super.key});

  @override
  State<TodaysWorkoutPage> createState() => _TodaysWorkoutPageState();
}

class _TodaysWorkoutPageState extends State<TodaysWorkoutPage> {
  late Future<List<Exercise>> todayWorkout;

  @override
  void initState() {
    super.initState();
    todayWorkout = loadTodayWorkout();
  }

  Future<List<Exercise>> loadTodayWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final dayIndex = DateTime.now().weekday - 1;

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    final raw = prefs.getStringList('workout_${days[dayIndex]}') ?? [];

    return raw.map((e) {
      final parts = e.split('|');
      return Exercise(
        name: parts[0],
        minutes: int.parse(parts[1]),
        caloriesPerMinute: int.parse(parts[2]),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todayName = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][DateTime.now().weekday - 1];

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Workout")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<Exercise>>(
          future: todayWorkout,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final exercises = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$todayName's Workout",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                if (exercises.isEmpty)
                  const Text('Rest day 💤'),

                ...exercises.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '• ${e.name} – ${e.minutes} min',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: exercises.isEmpty
                        ? null
                        : () async {
                            final result = await Navigator.push<WorkoutResult>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WorkoutSessionPage(exercises: exercises),
                              ),
                            );

                            if (result != null && context.mounted) {
                              Navigator.pop(context, result);
                            }
                          },
                    child: const Text(
                      "Start Workout",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

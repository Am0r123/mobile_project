import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_project/models/workout_result_model.dart';
import 'workout_session_page.dart';

class Exercise {
  final String name;
  final int minutes;
  final int caloriesPerMinute;
  final String gifKey;

  Exercise({
    required this.name,
    required this.minutes,
    required this.caloriesPerMinute,
    required this.gifKey,
  });
}

class TodaysWorkoutPage extends StatefulWidget {
  const TodaysWorkoutPage({super.key});

  @override
  State<TodaysWorkoutPage> createState() => _TodaysWorkoutPageState();
}

class _TodaysWorkoutPageState extends State<TodaysWorkoutPage> {
  late Future<List<Exercise>> todayWorkout;
  late Future<bool> completedToday;

  @override
  void initState() {
    super.initState();
    todayWorkout = _loadTodayWorkout();
    completedToday = _isTodayCompleted();
  }

  Future<List<Exercise>> _loadTodayWorkout() async {
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
        gifKey: parts[3],
      );
    }).toList();
  }

  Future<bool> _isTodayCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    return prefs.getString('last_completed_day') == today;
  }

  Future<void> _markTodayCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    await prefs.setString('last_completed_day', today);
    setState(() {
      completedToday = Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final todayName = const [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][DateTime.now().weekday - 1];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Workout"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<Exercise>>(
          future: todayWorkout,
          builder: (context, workoutSnap) {
            if (!workoutSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final exercises = workoutSnap.data!;

            return FutureBuilder<bool>(
              future: completedToday,
              builder: (context, completedSnap) {
                final isCompleted = completedSnap.data ?? false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$todayName's Workout",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (exercises.isEmpty)
                      const Text(
                        'Rest day 💤',
                        style: TextStyle(fontSize: 16),
                      ),

                    ...exercises.map(
                      (e) => Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isCompleted ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            e.name,
                            style: TextStyle(
                              fontSize: 16,
                              decoration:
                                  isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text(
                            '${e.minutes} min • ${e.caloriesPerMinute * e.minutes} cal',
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isCompleted || exercises.isEmpty ? Colors.grey : Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isCompleted || exercises.isEmpty
                            ? null
                            : () async {
                                final result = await Navigator.push<WorkoutResult>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WorkoutSessionPage(
                                      exercises: exercises,
                                    ),
                                  ),
                                );

                                if (result != null && context.mounted) {
                                  // --- FIXED LOGIC START ---
                                  // 1. Mark UI as completed (Green checks)
                                  await _markTodayCompleted();

                                  // 2. DO NOT SAVE TO HISTORY HERE!
                                  // Just pass the result back to the Home Page.
                                  Navigator.pop(context, result);
                                  // --- FIXED LOGIC END ---
                                }
                              },
                        child: Text(
                          isCompleted ? 'Workout Completed ✔' : 'Start Workout',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

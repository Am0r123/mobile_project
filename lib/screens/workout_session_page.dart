import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_project/models/workout_result_model.dart';
import 'todays_workout_page.dart';

class WorkoutSessionPage extends StatefulWidget {
  final List<Exercise> exercises;

  const WorkoutSessionPage({super.key, required this.exercises});

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  int currentIndex = 0;
  late int remainingSeconds;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    _startExercise();
  }

  void _startExercise() {
    remainingSeconds = widget.exercises[currentIndex].minutes * 60;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        _nextExercise();
      }
    });
  }
  void _nextExercise() {
    timer?.cancel(); // stop current timer
    if (currentIndex + 1 < widget.exercises.length) {
      setState(() => currentIndex++);
      _startExercise();
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    timer?.cancel(); // stop timer

    int totalMinutes = widget.exercises.fold(0, (sum, e) => sum + e.minutes);
    int totalCalories = widget.exercises.fold(0, (sum, e) => sum + e.minutes * e.caloriesPerMinute);

    Navigator.pop(
      context,
      WorkoutResult(
        name: "Today's Workout",
        totalMinutes: totalMinutes,
        totalCalories: totalCalories,
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.exercises[currentIndex];
    final nextExerciseName = currentIndex + 1 < widget.exercises.length
        ? widget.exercises[currentIndex + 1].name
        : 'Finish';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Session"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _formatTime(remainingSeconds),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              current.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text("Next: $nextExerciseName"),
            const SizedBox(height: 30),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 120, color: Colors.red.shade300),
                  const SizedBox(height: 20),
                  const Text(
                    "Follow proper form and breathing.\nKeep steady pace.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
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
                onPressed: () {
                  if (currentIndex + 1 < widget.exercises.length) {
                    _nextExercise();
                  } else {
                    _finishWorkout();
                  }
                },
                child: Text(
                  currentIndex + 1 < widget.exercises.length ? "Skip" : "Finish",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todays_workout_page.dart';
import '../services/exercise_gif_mapper.dart';
import 'package:mobile_project/models/workout_result_model.dart';

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
      if (!mounted) {
        t.cancel();
        return;
      }

      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        _nextExercise();
      }
    });
  }

  void _nextExercise() {
    timer?.cancel();
    if (currentIndex + 1 < widget.exercises.length) {
      setState(() => currentIndex++);
      _startExercise();
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() async {
    timer?.cancel();
    int totalMinutes =
        widget.exercises.fold(0, (sum, e) => sum + e.minutes);
    int totalCalories =
        widget.exercises.fold(
            0, (sum, e) => sum + e.minutes * e.caloriesPerMinute);
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final history =
        prefs.getStringList('completed_workouts') ?? [];

    history.add('$today|$totalMinutes|$totalCalories');
    await prefs.setStringList('completed_workouts', history);
    await prefs.setString('last_completed_day', today);
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
  Widget build(BuildContext context) {
    final current = widget.exercises[currentIndex];

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
            Text(_formatTime(remainingSeconds),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            Text(
              current.name,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Image.network(
                ExerciseGifMapper.getGif(current.gifKey),
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _nextExercise,
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

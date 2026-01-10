import 'dart:async';
import 'package:flutter/material.dart';
// REMOVED: import 'package:shared_preferences/shared_preferences.dart';
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
  bool isPaused = false;
  bool _isFinishing = false; 

  @override
  void initState() {
    super.initState();
    _startExercise();
  }

  void _startExercise() {
    remainingSeconds = widget.exercises[currentIndex].minutes * 60;
    isPaused = false;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }

      if (isPaused) return;

      if (remainingSeconds > 0) {
        setState(() => remainingSeconds--);
      } else {
        _nextExercise();
      }
    });
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void _nextExercise() {
    if (_isFinishing) return;

    timer?.cancel();
    if (currentIndex + 1 < widget.exercises.length) {
      setState(() => currentIndex++);
      _startExercise();
    } else {
      _finishWorkout();
    }
  }

  // UPDATED: No async, No SharedPreferences. Just return data.
  void _finishWorkout() {
    if (_isFinishing) return;
    _isFinishing = true; 

    timer?.cancel();
    
    int totalMinutes = widget.exercises.fold(0, (sum, e) => sum + e.minutes);
    int totalCalories = widget.exercises.fold(0, (sum, e) => sum + e.minutes * e.caloriesPerMinute);
    
    if (mounted) {
      Navigator.pop(
        context,
        WorkoutResult(
          name: "Today's Workout",
          totalMinutes: totalMinutes,
          totalCalories: totalCalories,
        ),
      );
    }
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
              style: TextStyle(
                fontSize: 48, 
                fontWeight: FontWeight.bold,
                color: isPaused ? Colors.orange : Colors.black, 
              ),
            ),
             if (isPaused)
              const Text("PAUSED", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, letterSpacing: 2)),

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

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPaused ? Colors.green : Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _togglePause,
                      icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                      label: Text(
                        isPaused ? "RESUME" : "PAUSE",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),

                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isFinishing ? null : _nextExercise,
                      icon: _isFinishing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : Icon(currentIndex + 1 < widget.exercises.length ? Icons.skip_next : Icons.check),
                      label: Text(
                        currentIndex + 1 < widget.exercises.length ? "SKIP" : "FINISH",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

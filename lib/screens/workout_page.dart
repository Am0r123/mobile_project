import 'package:flutter/material.dart';
import 'workout_session_page.dart';
import 'todays_workout_page.dart';
import 'package:mobile_project/models/workout_result_model.dart';

/// -------------------------------
/// WORKOUT PAGE
/// -------------------------------
class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  WorkoutResult? lastWorkout;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final shadowColor = isDark ? Colors.black54 : Colors.grey.withOpacity(0.2);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Fitness Tracker'),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : Colors.red,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _MainStatsCard(
              cardColor: cardColor,
              textColor: textColor,
              subTextColor: subTextColor,
              shadowColor: shadowColor,
            ),
            const SizedBox(height: 16),

            /// -------------------------------
            /// MINI STATS
            /// -------------------------------
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _MiniStatCard(
                    title: 'Sleep',
                    value: '6h 41m',
                    subtitle: 'Restless',
                    icon: Icons.bedtime,
                    cardColor: cardColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    shadowColor: shadowColor,
                  ),
                  _MiniStatCard(
                    title: 'Heart',
                    value: '84 bpm',
                    subtitle: 'Resting',
                    icon: Icons.favorite,
                    cardColor: cardColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    shadowColor: shadowColor,
                  ),
                  _MiniStatCard(
                    title: 'Weight',
                    value: '3.9 lbs',
                    subtitle: 'To Goal',
                    icon: Icons.monitor_weight,
                    cardColor: cardColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    shadowColor: shadowColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// -------------------------------
            /// RECENT EXERCISE (REAL DATA)
            /// -------------------------------
            _SectionTitle(title: 'Recent Exercise', textColor: Colors.red),
            const SizedBox(height: 12),

            if (lastWorkout != null)
              _ExerciseTile(
                title: lastWorkout!.name,
                duration: '${lastWorkout!.totalMinutes} min',
                calories: '${lastWorkout!.totalCalories} cal',
                cardColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                shadowColor: shadowColor,
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No workout completed yet',
                  style: TextStyle(color: subTextColor),
                ),
              ),

            const SizedBox(height: 24),

            /// -------------------------------
            /// START WORKOUT BUTTON
            /// -------------------------------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: () async {
                  final result = await Navigator.push<WorkoutResult>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TodaysWorkoutPage(),
                    ),
                  );

                  if (result != null) {
                    setState(() => lastWorkout = result);
                  }
                },
                child: Text(
                  'Start Workout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------------------
/// UI COMPONENTS (UNCHANGED)
/// -------------------------------
class _MainStatsCard extends StatelessWidget {
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;
  final Color shadowColor;

  const _MainStatsCard({
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.red.shade400,
            child: const Icon(Icons.fitness_center, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text('You', style: TextStyle(color: textColor, fontSize: 16)),
          const SizedBox(height: 6),
          const Text(
            '41,406',
            style: TextStyle(
              color: Colors.red,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('Steps Today', style: TextStyle(color: subTextColor)),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;
  final Color shadowColor;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionTitle({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final String title;
  final String duration;
  final String calories;
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;
  final Color shadowColor;

  const _ExerciseTile({
    required this.title,
    required this.duration,
    required this.calories,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_run, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  '$duration • $calories',
                  style: TextStyle(color: subTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

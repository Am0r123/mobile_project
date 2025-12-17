import 'package:flutter/material.dart';
import 'package:mobile_project/services/workout_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int step = 0;
  bool isLoading = false;

  final ageCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();

  String availability = '';
  String goal = '';

  void next() {
    if (step < 3) setState(() => step++);
  }

  void back() {
    if (step > 0) setState(() => step--);
  }

  Future<void> submit() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      final age = int.parse(ageCtrl.text);
      final weight = double.parse(weightCtrl.text);
      final height = double.parse(heightCtrl.text);

      await prefs.setBool('setupDone', true);
      await prefs.setInt('age', age);
      await prefs.setDouble('weight', weight);
      await prefs.setDouble('height', height);
      await prefs.setString('availability', availability);
      await prefs.setString('goal', goal);

      final plan = await WorkoutAIService.generateWeeklyPlan(
        age: age,
        weight: weight,
        height: height,
        goal: goal,
        availability: availability,
      );

      for (var day in plan) {
        await prefs.setStringList(
          'workout_${day.day}',
          day.exercises
            .map((e) =>
                '${e.name}|${e.minutes}|${e.caloriesPerMinute}|${e.gifKey}')
            .toList(),
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WorkoutPage()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate workout plan 😢\n$e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black87;
    final fieldColor = isDark ? Colors.grey[800]! : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: step / 3,
                color: Colors.red,
                backgroundColor: isDark ? Colors.white24 : Colors.black12,
              ),
              const SizedBox(height: 30),
              Expanded(child: _buildStep(textColor, fieldColor)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (step > 0)
                    ElevatedButton(
                      onPressed: isLoading ? null : back,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text('Back'),
                    ),
                  ElevatedButton(
                    onPressed: isLoading ? null : (step == 3 ? submit : next),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(120, 45),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(step == 3 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(Color textColor, Color fieldColor) {
    switch (step) {
      case 0:
        return _inputStep(textColor, fieldColor);
      case 1:
        return _availabilityStep(textColor);
      case 2:
        return _goalStep(textColor);
      default:
        return Center(
          child: Text(
            'Ready to Start 💪',
            style: TextStyle(color: textColor, fontSize: 22),
          ),
        );
    }
  }

  Widget _inputStep(Color textColor, Color fieldColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('About You'),
        _field('Age', ageCtrl, fieldColor, textColor),
        _field('Weight (kg)', weightCtrl, fieldColor, textColor),
        _field('Height (cm)', heightCtrl, fieldColor, textColor),
      ],
    );
  }

  Widget _availabilityStep(Color textColor) {
    return _choiceStep(
      'Availability',
      ['Morning', 'Afternoon', 'Evening', 'Night', 'Flexible'],
      (v) => availability = v,
      textColor,
    );
  }

  Widget _goalStep(Color textColor) {
    return _choiceStep(
      'Goal',
      [
        'Weight Loss',
        'Maintain Weight',
        'Muscle Gain',
        'Maintain Muscle',
        'Increase Steps'
      ],
      (v) => goal = v,
      textColor,
    );
  }

  Widget _choiceStep(
    String title,
    List<String> options,
    Function(String) onSelect,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(title),
        ...options.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => setState(() => onSelect(e)),
              child: Text(e),
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    Color fillColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

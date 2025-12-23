import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_project/main.dart';
import 'package:mobile_project/services/workout_ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupPage extends ConsumerStatefulWidget {
  const SetupPage({super.key});

  @override
  ConsumerState<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends ConsumerState<SetupPage> {
  int step = 0;
  bool isLoading = false;

  final ageCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final heightCtrl = TextEditingController();

  String availability = '';
  String goal = '';

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image picked: ${image.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void next() {
    if (step == 0) {
      if (ageCtrl.text.isEmpty || weightCtrl.text.isEmpty || heightCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }
    }
    if (step == 1 && availability.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your availability')),
        );
        return;
    }

    if (step < 3) setState(() => step++);
  }

  void back() {
    if (step > 0) setState(() => step--);
  }

  Future<void> submit() async {
    if (goal.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a goal')),
        );
        return;
    }

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

      final plan = await WorkoutGeminiAIService.generateWeeklyPlan(
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
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating plan: $e'),
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
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (step + 1) / 4,
                color: Colors.red,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 30),
              
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStepContent(isDark),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (step > 0)
                      TextButton(
                        onPressed: isLoading ? null : back,
                        child: const Text('Back', style: TextStyle(color: Colors.grey)),
                      )
                    else 
                      const SizedBox(), 
                      
                    ElevatedButton(
                      onPressed: isLoading ? null : (step == 2 ? submit : next),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20, width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : Text(step == 2 ? 'Generate Plan' : 'Next', 
                                 style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(bool isDark) {
    Color textColor = isDark ? Colors.white : Colors.black87;
    Color fieldColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    switch (step) {
      case 0:
        return _inputStep(textColor, fieldColor);
      case 1:
        return _availabilityStep(textColor);
      case 2:
        return _goalStep(textColor);
      default:
        return const SizedBox();
    }
  }

  Widget _inputStep(Color textColor, Color fieldColor) {
    return SingleChildScrollView(
      key: const ValueKey(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('Tell us about you'),
          _field('Age', ageCtrl, fieldColor, textColor),
          _field('Weight (kg)', weightCtrl, fieldColor, textColor),
          _field('Height (cm)', heightCtrl, fieldColor, textColor),
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt, color: Colors.red),
              label: Text('Import Imbody (optional)', style: TextStyle(color: textColor)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _availabilityStep(Color textColor) {
    return _choiceStep(
      key: 1,
      title: 'When can you workout?',
      options: ['Morning', 'Afternoon', 'Evening', 'Night', 'Flexible'],
      currentSelection: availability, 
      onSelect: (val) => setState(() => availability = val),
      textColor: textColor,
    );
  }

  Widget _goalStep(Color textColor) {
    return _choiceStep(
      key: 2,
      title: 'What is your main goal?',
      options: [
        'Weight Loss',
        'Maintain Weight',
        'Muscle Gain',
        'Maintain Muscle',
        'Increase Steps'
      ],
      currentSelection: goal,
      onSelect: (val) => setState(() => goal = val),
      textColor: textColor,
    );
  }

  Widget _choiceStep({
    required int key,
    required String title,
    required List<String> options,
    required String currentSelection,
    required Function(String) onSelect,
    required Color textColor,
  }) {
    return Column(
      key: ValueKey(key),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(title),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final option = options[i];
              final isSelected = option == currentSelection;

              return InkWell(
                onTap: () => onSelect(option),
                borderRadius: BorderRadius.circular(15),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.grey.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : textColor,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.white)
                      else
                        Icon(Icons.circle_outlined, color: Colors.grey.withOpacity(0.5)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController ctrl, Color fillColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
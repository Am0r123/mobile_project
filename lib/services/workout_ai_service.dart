import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
final apiKey = dotenv.env['API_KEY']!;

class WorkoutGeminiAIService {
  static final String _apiKey = apiKey;
  
  static const String _apiUrl = 
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent';
  static Future<List<DailyWorkout>> generateWeeklyPlan({
    required int age,
    required double weight,
    required double height,
    required String goal,
    required String availability,
  }) async {
    final prompt = '''
      You are a professional fitness coach.
      Create a 7-day workout plan as JSON ONLY.
      User details: Age: $age, Weight: $weight kg, Height: $height cm, Goal: $goal, Availability: $availability
      
      Rules:
      - Each day has 2–4 exercises
      - Each exercise must include: name, minutes, caloriesPerMinute, gifKey (snake_case)
      - gifKey examples: push_up, squat, plank, jumping_jacks, lunges, jogging
      
      Respond with PURE JSON only. No markdown formatting.
      JSON format example:
      [
        {
          "day": "Monday",
          "exercises": [
            { "name": "Push Ups", "minutes": 10, "caloriesPerMinute": 7, "gifKey": "push_up" }
          ]
        }
      ]
    ''';

    final response = await http.post(
      Uri.parse('$_apiUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ],
        "generationConfig": {
          "responseMimeType": "application/json"
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI request failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    
    String content = data['candidates'][0]['content']['parts'][0]['text'];
    
    content = content.replaceAll('```json', '').replaceAll('```', '').trim();

    final List<dynamic> jsonPlan = jsonDecode(content);

    return jsonPlan.map((dayData) {
      return DailyWorkout(
        day: dayData['day'],
        exercises: (dayData['exercises'] as List).map((ex) {
          return Exercise(
            name: ex['name'],
            minutes: ex['minutes'],
            caloriesPerMinute: (ex['caloriesPerMinute'] as num).toInt(),
            gifKey: ex['gifKey'],
          );
        }).toList(),
      );
    }).toList();
  }
}
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/workout_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
final apiKey = dotenv.env['OPENAI_API_KEY']!;

class WorkoutAIService {
  static final String _apiKey = apiKey;
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';

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
User details:
- Age: $age
- Weight: $weight kg
- Height: $height cm
- Goal: $goal
- Availability: $availability

Rules:
- Each day has 2–4 exercises
- Each exercise must include:
  - name
  - minutes
  - caloriesPerMinute
  - gifKey (snake_case identifier)

gifKey examples:
push_up, squat, plank, jumping_jacks, lunges, jogging

Respond with PURE JSON only.

JSON format:
[
  {
    "day": "Monday",
    "exercises": [
      {
        "name": "Push Ups",
        "minutes": 10,
        "caloriesPerMinute": 7,
        "gifKey": "push_up"
      }
    ]
  }
]
''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': 'You generate workout plans.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.6,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI request failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    String content = data['choices'][0]['message']['content'];
    content = content.replaceAll('```json', '');
    content = content.replaceAll('```', '');
    content = content.trim();


    final List<dynamic> jsonPlan = jsonDecode(content);

    return jsonPlan.map((dayData) {
      return DailyWorkout(
        day: dayData['day'],
        exercises: (dayData['exercises'] as List).map((ex) {
          return Exercise(
            name: ex['name'],
            minutes: ex['minutes'],
            caloriesPerMinute: ex['caloriesPerMinute'],
            gifKey: ex['gifKey'],
          );
        }).toList(),
      );
    }).toList();
  }
}

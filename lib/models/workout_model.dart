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

  int get calories => minutes * caloriesPerMinute;
}

class DailyWorkout {
  final String day;
  final List<Exercise> exercises;

  DailyWorkout({
    required this.day,
    required this.exercises,
  });
}

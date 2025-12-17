class Exercise {
  final String name;
  final int minutes;
  final int caloriesPerMinute;

  Exercise({
    required this.name,
    required this.minutes,
    required this.caloriesPerMinute,
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

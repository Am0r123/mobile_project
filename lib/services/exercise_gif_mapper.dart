class ExerciseGifMapper {
  static const Map<String, String> gifMap = {
    'push_up': 'https://media.giphy.com/media/XreQmk7ETCak0/giphy.gif',
    'squat': 'https://media.giphy.com/media/3o7btPCcdNniyf0ArS/giphy.gif',
    'plank': 'https://media.giphy.com/media/l0MYt5jPR6QX5pnqM/giphy.gif',
    'jumping_jacks': 'https://media.giphy.com/media/l0MYB8Ory7Hqefo9a/giphy.gif',
    'lunges': 'https://media.giphy.com/media/26tPoyDhjiJ2g7rEs/giphy.gif',
    'jogging': 'https://media.giphy.com/media/3o6Zt6ML6BklcajjsA/giphy.gif',
  };

  static String getGif(String key) {
    return gifMap[key] ??
        'https://media.giphy.com/media/3o7TKtnuHOHHUjR38Y/giphy.gif';
  }
}

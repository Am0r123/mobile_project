class ExerciseGifMapper {
  static const Map<String, String> gifMap = {
    'push_up': 'https://cdn.dribbble.com/userupload/27842844/file/original-5c27e096d7556ed03f087defeadac560.gif',
    'squat': 'https://cdn.dribbble.com/userupload/27842844/file/original-5c27e096d7556ed03f087defeadac560.gif',
    'plank': 'https://cdn.dribbble.com/userupload/27842844/file/original-5c27e096d7556ed03f087defeadac560.gif',
    'jumping_jacks': 'https://cdn.dribbble.com/userupload/27842844/file/original-5c27e096d7556ed03f087defeadac560.gif',
    'lunges': 'https://cdn.dribbble.com/userupload/27842844/file/original-5c27e096d7556ed03f087defeadac560.gif',
    'jogging': 'https://cdn.dribbble.com/userupload/27842844/file/original-5c27e096d7556ed03f087defeadac560.gif',
  };

  static String getGif(String key) {
    return gifMap[key] ??
        'https://cdn.dribbble.com/userupload/27842844/file/original-5c27e096d7556ed03f087defeadac560.gif';
  }
}

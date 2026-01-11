class ExerciseGifMapper {
  static const Map<String, String> gifMap = {
    'push_up': 'https://cdn.dribbble.com/userupload/27842844/file/original-5c27e096d7556ed03f087defeadac560.gif',
    'squat': 'https://wellnessed.com/wp-content/uploads/2022/12/how-to-do-squats.gif',
    'plank': 'https://hw.qld.gov.au/wp-content/uploads/2015/07/05_M_WIP03-Plank-push-up.gif',
    'jumping_jacks': 'https://cdn.dribbble.com/userupload/23995967/file/original-b7327e47be94975940e98b26277e5ead.gif',
    'lunges': 'https://wellnessed.com/wp-content/uploads/2023/04/how-to-do-jumping-lunges.gif',
    'jogging': 'https://cdn.dribbble.com/userupload/31879798/file/original-c464a45b9c3a1c1731c3359f9303fed0.gif',
  };

  static String getGif(String key) {
    return gifMap[key] ??
        'https://cdn.dribbble.com/userupload/27842844/file/original-5c27e096d7556ed03f087defeadac560.gif';
  }
}

const String _kDefaultGoalImage = 'assets/images/ادخار.png';

const Map<String, String> _goalImageMap = {
  'البيت': 'assets/images/بيت.png',
  'السيارة': 'assets/images/سيارة.png',
  'الدراسة': 'assets/images/دراسة.png',
  'الزواج': 'assets/images/زواج.png',
  'السفر': 'assets/images/سفر.png',
  'الجهاز': 'assets/images/لابتوب.png',
  'الادخار': 'assets/images/ادخار.png',
  'اخرى': 'assets/images/اخرى.png',
  'Apartment': 'assets/images/بيت.png',
  'Car': 'assets/images/سيارة.png',
  'Education': 'assets/images/دراسة.png',
  'Wedding': 'assets/images/زواج.png',
  'Travel': 'assets/images/سفر.png',
  'Laptop': 'assets/images/لابتوب.png',
  'Savings': 'assets/images/ادخار.png',
  'Other': 'assets/images/اخرى.png',
};

String getGoalImage(String title) {
  for (final entry in _goalImageMap.entries) {
    if (title.contains(entry.key)) return entry.value;
  }
  return _kDefaultGoalImage;
}

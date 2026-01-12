class MoodEntry {
  final DateTime date;
  final String mood; // 'happy', 'neutral', 'sad', 'stressed', 'angry'
  final int value; // 1 to 5

  MoodEntry({required this.date, required this.mood, required this.value});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'mood': mood,
        'value': value,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      date: DateTime.parse(json['date']),
      mood: json['mood'],
      value: json['value'],
    );
  }
}

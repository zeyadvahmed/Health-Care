class DailyMood {
  final String id;
  final String mood;
  final String date;
 
  DailyMood({
    required this.id,
    required this.mood,
    required this.date,
  });
 
  Map<String, dynamic> toMap() => {
        'id': id,
        'mood': mood,
        'date': date,
      };
 
  factory DailyMood.fromMap(Map<String, dynamic> map) => DailyMood(
        id: map['id'],
        mood: map['mood'],
        date: map['date'],
      );
}
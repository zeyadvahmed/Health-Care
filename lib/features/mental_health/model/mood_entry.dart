class MoodEntry {
  final String id;
  final String mood;
  final String note;
  final String date;
 
  MoodEntry({
    required this.id,
    required this.mood,
    required this.note,
    required this.date,
  });
 
  Map<String, dynamic> toMap() => {
        'id': id,
        'mood': mood,
        'note': note,
        'date': date,
      };
 
  factory MoodEntry.fromMap(Map<String, dynamic> map) => MoodEntry(
        id: map['id'],
        mood: map['mood'],
        note: map['note'],
        date: map['date'],
      );
}
class GuidedExercise {
  String id;
  String name;
  String type;
  int durationSeconds;

  GuidedExercise({
    required this.id,
    required this.name,
    required this.type,
    required this.durationSeconds,
  });

  toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'duration_seconds': durationSeconds,
    };
  }

  factory GuidedExercise.fromMap(Map<String, dynamic> map) {
    return GuidedExercise(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      durationSeconds: map['duration_seconds'],
    );
  }
}

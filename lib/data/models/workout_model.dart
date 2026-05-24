class WorkoutModel {

  final int? id;
  final String title;
  final String duration;
  final String calories;

  WorkoutModel({
    this.id,
    required this.title,
    required this.duration,
    required this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'calories': calories,
    };
  }

  factory WorkoutModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return WorkoutModel(
      id: map['id'],
      title: map['title'],
      duration: map['duration'],
      calories: map['calories'],
    );
  }
}
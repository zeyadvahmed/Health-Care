// lib/models/daily_goal.dart

class DailyGoal {
  final int? id;
  final double targetCalories;


  const DailyGoal({
    this.id,
    this.targetCalories = 2000,
  
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'target_calories': targetCalories,

    };
  }

  factory DailyGoal.fromMap(Map<String, dynamic> map) {
    return DailyGoal(
      id: map['id'],
      targetCalories: map['target_calories'],
  
    );
  }
}

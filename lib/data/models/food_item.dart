// lib/models/food_item.dart

class FoodItem {
  final int? id;
  final String name;
  final double calories;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final String date; // yyyy-MM-dd


  FoodItem({
    this.id,
    required this.name,
    required this.calories,
    required this.mealType,
    required this.date,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'meal_type': mealType,
      'date': date,

    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      mealType: map['meal_type'],
      date: map['date'],

    );
  }

  FoodItem copyWith({
    int? id,
    String? name,
    double? calories,
    String? mealType,
    String? date,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      mealType: mealType ?? this.mealType,
      date: date ?? this.date,

    );
  }
}

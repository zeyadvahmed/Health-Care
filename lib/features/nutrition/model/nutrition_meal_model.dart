class NutritionMealModel {
  String id;
  String name;  
  int calories;

  NutritionMealModel({
    required this.id,
    required this.name,
    required this.calories,
  });

  factory NutritionMealModel.fromMap(Map<String, dynamic> map) {
    return NutritionMealModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      calories: map['calories'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
    };
  }
}
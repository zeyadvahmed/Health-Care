
class NutritionState {}

class NutritionInitialState extends NutritionState {
  // You can add properties to hold the state of your nutrition data
  // For example, you might want to hold a list of meals, loading status, etc.
}

class NutritionLoadingState extends NutritionState {}

class NutritionSuccessState extends NutritionState {

  NutritionSuccessState();
}



class AddNutritionLoadingState extends NutritionState {}

class AddNutritionSuccessState extends NutritionState {

}
// ============================================================
// validators.dart
// Form validation functions used across all screens.
//
// Usage:
//   TextFormField(
//     validator: Validators.validateEmail,
//   )
//
// Rules:
//   - Every function returns null if the value is valid
//   - Every function returns an error String if invalid
//   - Flutter automatically shows the error String under the field
//   - Never write validation logic directly inside screen files
// ============================================================

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 3) {
      return 'Full name must be at least 3 characters';
    }
    return null;
  }

  static String? validateWorkoutName(String? value) {
    // Used in: CreateWorkoutScreen
    if (value == null || value.trim().isEmpty) {
      return 'Workout name is required';
    }
    if (value.trim().length < 3) {
      return 'Workout name must be at least 3 characters';
    }
    return null;
  }

  static String? validateExerciseName(String? value) {
    // Used in: AddExerciseScreen
    if (value == null || value.trim().isEmpty) {
      return 'Exercise name is required';
    }
    if (value.trim().length < 3) {
      return 'Exercise name must be at least 3 characters';
    }
    return null;
  }

  static String? validateWeight(String? value) {
    // Used in: AddExerciseScreen weight field
    if (value == null || value.trim().isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Enter a valid number';
    }
    if (weight < 0) {
      return 'Weight cannot be negative';
    }
    if (weight > 1000) {
      return 'Enter a realistic weight value';
    }
    return null;
  }

  static String? validateSets(String? value) {
    // Used in: AddExerciseScreen sets field
    if (value == null || value.trim().isEmpty) {
      return 'Sets is required';
    }
    final sets = int.tryParse(value);
    if (sets == null) {
      return 'Enter a valid number';
    }
    if (sets <= 0) {
      return 'Sets must be at least 1';
    }
    if (sets > 100) {
      return 'Enter a realistic sets value';
    }
    return null;
  }

  static String? validateReps(String? value) {
    // Used in: AddExerciseScreen reps field
    if (value == null || value.trim().isEmpty) {
      return 'Reps is required';
    }
    final reps = int.tryParse(value);
    if (reps == null) {
      return 'Enter a valid number';
    }
    if (reps <= 0) {
      return 'Reps must be at least 1';
    }
    if (reps > 100) {
      return 'Enter a realistic reps value';
    }
    return null;
  }

  static String? validateAge(String? value) {
    // Used in: ProfileScreen personal details edit
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Enter a valid number';
    }
    if (age < 10 || age > 100) {
      return 'Enter a realistic age between 10 and 100';
    }
    return null;
  }

  static String? validateHeight(String? value) {
    // Used in: ProfileScreen personal details edit
    if (value == null || value.trim().isEmpty) {
      return 'Height is required';
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Enter a valid number';
    }
    if (height < 50 || height > 250) {
      return 'Enter a realistic height in cm';
    }
    return null;
  }

  static String? validateBodyWeight(String? value) {
    // Used in: ProfileScreen personal details edit
    if (value == null || value.trim().isEmpty) {
      return 'Weight is required';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Enter a valid number';
    }
    if (weight < 20 || weight > 300) {
      return 'Enter a realistic weight in kg';
    }
    return null;
  }

  static String? validateWaterGoal(String? value) {
    // Used in: ProfileScreen daily goals edit
    if (value == null || value.trim().isEmpty) {
      return 'Water goal is required';
    }
    final goal = double.tryParse(value);
    if (goal == null) {
      return 'Enter a valid number';
    }
    if (goal <= 0) {
      return 'Water goal must be greater than 0';
    }
    if (goal > 10) {
      return 'Enter a realistic water goal (max 10L)';
    }
    return null;
  }


  static String? validateFoodName(String? value) {
    // Used in: Add Food bottom sheet in NutritionScreen
    if (value == null || value.trim().isEmpty) {
      return 'Food name is required';
    }
    return null;
  }

  static String? validateCalories(String? value) {
    // Used in: Add Food bottom sheet in NutritionScreen
    if (value == null || value.trim().isEmpty) {
      return 'Calories is required';
    }
    final calories = int.tryParse(value);
    if (calories == null) {
      return 'Enter a valid number';
    }
    if (calories < 0) {
      return 'Calories cannot be negative';
    }
    if (calories > 5000) {
      return 'Enter a realistic calories value';
    }
    return null;
  }

  static String? validateMedicationName(String? value) {
    // Used in: AddMedicationScreen
    if (value == null || value.trim().isEmpty) {
      return 'Medication name is required';
    }
    if (value.trim().length < 2) {
      return 'Enter a valid medication name';
    }
    return null;
  }

  static String? validateDosage(String? value) {
    // Used in: AddMedicationScreen
    if (value == null || value.trim().isEmpty) {
      return 'Dosage is required';
    }
    return null;
  }
}





// ============================================================
// app_strings.dart
// All static text strings used across the SparkSteel app.
//
// Usage:
//   Text(AppStrings.appName)
//   hint: AppStrings.emailHint
//
// Rules:
//   - Never write raw strings directly in widgets
//   - Always use AppStrings.x instead
//   - Dynamic strings → use inline interpolation
//     example: 'Welcome, ${user.name}'  (NOT here)
// ============================================================

class AppStrings {
  // ── App Identity ───────────────────────────────────────────
  static const String appFname = 'Spark';
  static const String appLname = 'Steel';
  static const String appTagline = 'your personal health companion';

  // ── Splash ─────────────────────────────────────────────────
  static const String initializing = 'Initializing';

  // ── Login Screen ───────────────────────────────────────────
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Log in to track your health journey';
  static const String loginButton = 'Login';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Doesn't have account? ";
  static const String signUpLink = 'Sign Up';
  static const String orSignInWith = 'Or sign in with';
  static const String termsText = 'By logging, you agree to our ';
  static const String termsLink = 'Terms & Conditions';
  static const String andText = ' and ';
  static const String privacyLink = 'Privacy Policy';

  // ── Register Screen ────────────────────────────────────────
  static const String registerTitle = 'Create Account';
  static const String registerSubtitle =
      'Sign up now and start exploring all that our app has to offer. We\'re excited to welcome you to our community!';
  static const String createAccount = 'Create Account';
  static const String alreadyAccount = 'Already have account? ';
  static const String logInLink = 'Log In';

  // ── Input Hints ────────────────────────────────────────────
  static const String emailHint = 'Email';
  static const String passwordHint = 'Password';
  static const String fullNameHint = 'Full Name';
  static const String confirmPasswordHint = 'Confirm Password';

  // ── Validation Errors ──────────────────────────────────────
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String nameRequired = 'Name is required';
  static const String passwordsNoMatch = 'Passwords do not match';

  // ── Home Screen ────────────────────────────────────────────
  static const String welcomePrefix = 'Welcome, ';
  static const String homeSubtitle = "Let's hit your goals today!";
  static const String dailyMood = 'Daily Mood';
  static const String howAreYouFeeling = 'How are you feeling today?';
  static const String waterIntake = 'Water Intake';
  static const String todaysWorkout = "Today's Workout";
  static const String explore = 'Explore';

  // ── Workout Screens ────────────────────────────────────────
  static const String workouts = 'Workouts';
  static const String predefinedWorkouts = 'Predefined Workouts';
  static const String myWorkouts = 'My Workouts';
  static const String createWorkout = 'Create Workout';
  static const String workoutInfo = 'Workout Information';
  static const String workoutNameHint = 'e.g. Morning Push Day';
  static const String descriptionHint = 'Add focus note or specific goals...';
  static const String difficultyLabel = 'Difficulty Level';
  static const String durationLabel = 'Duration';
  static const String exercisesLabel = 'Exercises';
  static const String addExercise = '+ Add Exercise';
  static const String saveWorkout = 'Save Workout';
  static const String estimatedDuration = 'ESTIMATED DURATION';
  static const String addExerciseTitle = 'Add Exercise';
  static const String exerciseNameHint = 'e.g. Incline Dumbbell Press';
  static const String muscleGroupLabel = 'Muscle Group';
  static const String selectCategory = 'Select Category';
  static const String setsLabel = 'Sets';
  static const String repsLabel = 'Reps';
  static const String weightLabel = 'Weight';
  static const String notesHint = 'Enter technique focus or equipment setup...';
  static const String notesLabel = 'Notes (Optional)';
  static const String saveExercise = 'Save Exercise';
  static const String workoutOverview = 'Workout Overview';
  static const String exerciseList = 'Exercise List';
  static const String readyToStart = 'Ready to start?';
  static const String sessionEstimate =
      'This session is estimated to take 45-60 minutes based on your performance.';
  static const String startWorkout = 'Start Workout';
  static const String upcomingBadge = 'UPCOMING';
  static const String activeSession = 'Active Session';
  static const String finishButton = 'Finish';
  static const String workoutProgress = 'Workout Progress';
  static const String restTimer = 'Rest Timer';
  static const String secondsLeft = 'Seconds Left';
  static const String resetButton = 'Reset';
  static const String skipButton = 'Skip';
  static const String workoutSummary = 'Workout Summary';
  static const String workoutComplete = 'Workout Complete';
  static const String saveAndExit = 'Save & Exit';
  static const String durationStat = 'Duration';
  static const String volumeStat = 'Volume';
  static const String exercisesStat = 'Exercises';
  static const String caloriesStat = 'Calories';
  static const String workoutHistory = 'Workouts History';
  static const String recentWorkouts = 'Recent Workouts';
  static const String viewDetails = 'View Details';
  static const String startButton = 'Start';
  static const String editButton = 'Edit';

  // ── Nutrition Screen ───────────────────────────────────────
  static const String nutritionPlan = 'Nutrition Plan';
  static const String dailyProgress = 'Daily Progress';
  static const String kcalRemaining = 'kcal remaining';
  static const String proteins = 'PROTEINS';
  static const String carbs = 'CARBS';
  static const String fats = 'FATS';
  static const String todaysMeals = "Today's Meals";
  static const String breakfast = 'Breakfast';
  static const String lunch = 'Lunch';
  static const String dinner = 'Dinner';
  static const String snacks = 'Snacks';
  static const String addFood = '+ Add Food';
  static const String addFoodTitle = 'Add Food';
  static const String foodNameHint = 'e.g. Grilled Chicken Breast';
  static const String foodNameLabel = 'Food Name';
  static const String caloriesLabel = 'Calories';
  static const String noItemsAdded = 'No items added yet';

  // ── Hydration Screen ───────────────────────────────────────
  static const String hydrationTracker = 'Hydration Tracker';
  static const String goalLabel = 'Goal: ';
  static const String hydrationLevel = 'Hydration Level';
  static const String remaining = 'Remaining';
  static const String addWater = 'Add Water';
  static const String todaysHistory = "Today's History";
  static const String ml250 = '250ml';
  static const String ml500 = '500ml';

  // ── Mental Health Screen ───────────────────────────────────
  static const String mentalHealth = 'Mental Health';
  static const String moodHistory = 'Mood History';
  static const String last7Days = 'Last 7 days';
  static const String dailyReflection = 'Daily Reflection';
  static const String reflectionHint = 'What in your mind today?';
  static const String saveNote = 'Save Note';
  static const String guidedExercises = 'Guided Exercises';
  static const String dailyTips = 'Daily Tips';
  static const String viewAll = 'View All';
  static const String moodHappy = 'Happy';
  static const String moodCalm = 'Calm';
  static const String moodTired = 'Tired';
  static const String moodStressed = 'Stressed';

  // ── Medical Screen ─────────────────────────────────────────
  static const String medicalTracker = 'Medical Tracker';
  static const String medications = 'Medications';
  static const String addMedication = 'Add Medication';
  static const String medicationNameHint = 'e.g. Ibuprofen';
  static const String medicationName = 'Medication Name';
  static const String typeLabel = 'Type';
  static const String dosageLabel = 'Dosage';
  static const String dosageHint = 'e.g. 200mg';
  static const String frequencyLabel = 'Sets';
  static const String onceDaily = 'Once daily';
  static const String twiceDaily = 'Twice daily';
  static const String everyXHours = 'Every X hours';
  static const String scheduleTime = 'Schedule Time';
  static const String addTime = '+ Add Time';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String saveButton = 'Save';

  // ── Progress Screen ────────────────────────────────────────
  static const String progress = 'Progress';
  static const String workoutProgressTitle = 'Workout Progress';
  static const String thisWeek = 'This Week';
  static const String totalWorkouts = 'Total Workouts';
  static const String activityTrends = 'Activity Trends';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String nutritionProgress = 'Nutrition Progress';
  static const String avgDailyIntake = 'Avg Daily Intake';
  static const String adherence = 'Adherence';
  static const String hydrationProgress = 'Hydration Progress';
  static const String weeklyPerformance = 'Weekly Performance';
  static const String mentalHealthTitle = 'Mental Health';
  static const String modeTrend = 'Mode Trend';

  // ── Activity Screen ────────────────────────────────────────
  static const String activity = 'Activity';
  static const String currentProgress = 'Current Progress';
  static const String dailyChallenges = 'Daily Challenges';
  static const String friendsLeaderboard = 'Friends Leaderboard';
  static const String congratulations = 'Congratulations!';
  static const String levelUpMessage = 'You have reached the next level';
  static const String levelUpSubtitle =
      'Keep up the great work on your daily healthy milestones';
  static const String collectContinue = 'Collect & Continue';
  static const String xpEarned = 'XP earned';
  static const String nextLevel = 'Next level: ';

  // ── Profile Screen ─────────────────────────────────────────
  static const String profileTitle = 'Profile';
  static const String personalDetails = 'Personal Details';
  static const String dailyGoals = 'Daily Goals';
  static const String preferences = 'Preferences';
  static const String darkMode = 'Dark Mode';
  static const String language = 'Language';
  static const String workoutHistoryLink = 'Workout History';
  static const String logout = 'Logout';
  static const String edit = 'Edit';
  static const String ageLabel = 'Age';
  static const String weightLabel2 = 'Weight';
  static const String heightLabel = 'Height';
  static const String caloriesGoal = 'Calories Goal';
  static const String waterGoal = 'Water Goal';

  // ── Chatbot Screen ─────────────────────────────────────────
  static const String chatBot = 'Chat Bot';
  static const String messageHint = 'Type a message ...';

  // ── General / Reusable ─────────────────────────────────────
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  static const String loading = 'Loading...';
  static const String noDataYet = 'No data yet';
  static const String somethingWrong = 'Something went wrong';
  static const String tryAgain = 'Try again';
  static const String noInternet = 'No internet connection';
  static const String syncing = 'Syncing data...';
  static const String syncDone = 'All data synced';
}

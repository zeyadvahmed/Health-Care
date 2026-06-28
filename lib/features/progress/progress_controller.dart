import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressData {
  final int avgDailyCalories;
  final int nutritionAdherence;
  final List<int> workoutTrend;
  final List<int> hydrationTrend;

  const ProgressData({
    required this.avgDailyCalories,
    required this.nutritionAdherence,
    required this.workoutTrend,
    required this.hydrationTrend,
  });

  factory ProgressData.empty() {
    return const ProgressData(
      avgDailyCalories: 0,
      nutritionAdherence: 0,
      workoutTrend: [0, 0, 0, 0, 0, 0, 0],
      hydrationTrend: [0, 0, 0, 0, 0, 0, 0],
    );
  }
}

class ProgressController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<ProgressData> loadProgressData(String uid) async {
    if (uid.isEmpty) return ProgressData.empty();

    final now = DateTime.now();
    final weekStart = _startOfWeek(now);
    final weekEnd = weekStart.add(const Duration(days: 7));

    final sessionsFuture =
        _db.collection('User/$uid/workout_sessions').get();
    final foodFuture = _db.collection('User/$uid/food_items').get();
    final hydrationFuture =
        _db.collection('User/$uid/hydration_entries').get();
    final goalFuture =
        _db.collection('User/$uid/daily_goals').doc('default').get();

    final results = await Future.wait<Object?>([
      sessionsFuture,
      foodFuture,
      hydrationFuture,
      goalFuture,
    ]);

    final sessions = (results[0] as QuerySnapshot<Map<String, dynamic>>).docs;
    final foods = (results[1] as QuerySnapshot<Map<String, dynamic>>).docs;
    final hydration =
        (results[2] as QuerySnapshot<Map<String, dynamic>>).docs;
    final goalDoc = results[3] as DocumentSnapshot<Map<String, dynamic>>;

    final workoutTrend = List<int>.filled(7, 0);

    for (final doc in sessions) {
      final data = doc.data();
      final date = _dateValue(data['endTime']) ?? _dateValue(data['startTime']);
      if (date == null) continue;

      if (!date.isBefore(weekStart) && date.isBefore(weekEnd)) {
        workoutTrend[date.weekday - 1]++;
      }
    }

    final caloriesByDay = <String, double>{};
    for (final doc in foods) {
      final data = doc.data();
      final date = _dateString(data['date']);
      if (date == null) continue;

      final parsed = DateTime.tryParse(date);
      if (parsed == null ||
          parsed.isBefore(weekStart) ||
          !parsed.isBefore(weekEnd)) {
        continue;
      }

      caloriesByDay[date] =
          (caloriesByDay[date] ?? 0) + _doubleValue(data['calories']);
    }

    final activeFoodDays = caloriesByDay.values.where((v) => v > 0).length;
    final avgDailyCalories = activeFoodDays == 0
        ? 0
        : (caloriesByDay.values.reduce((a, b) => a + b) / activeFoodDays)
            .round();

    final targetCalories = _doubleValue(
      goalDoc.data()?['target_calories'],
      fallback: 2000,
    );
    final nutritionAdherence = targetCalories <= 0
        ? 0
        : ((avgDailyCalories / targetCalories) * 100).clamp(0, 100).round();

    final hydrationTrend = List<int>.filled(7, 0);
    for (final doc in hydration) {
      final data = doc.data();
      final date = _dateValue(data['timestamp']);
      if (date == null ||
          date.isBefore(weekStart) ||
          !date.isBefore(weekEnd)) {
        continue;
      }

      hydrationTrend[date.weekday - 1] += _intValue(data['amountMl']);
    }

    return ProgressData(
      avgDailyCalories: avgDailyCalories,
      nutritionAdherence: nutritionAdherence,
      workoutTrend: workoutTrend,
      hydrationTrend: hydrationTrend,
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final clean = DateTime(date.year, date.month, date.day);
    return clean.subtract(Duration(days: clean.weekday - 1));
  }

  DateTime? _dateValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  String? _dateString(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      final date = value.toDate();
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
    return value.toString();
  }

  int _intValue(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _doubleValue(dynamic value, {double fallback = 0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

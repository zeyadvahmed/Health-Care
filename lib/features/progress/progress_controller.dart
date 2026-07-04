import 'dart:async';

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

  String _workoutSessionsPath(String uid) => 'User/$uid/workout_sessions';
  String _foodItemsPath(String uid) => 'User/$uid/food_items';
  String _hydrationEntriesPath(String uid) => 'User/$uid/hydration_entries';
  String _dailyGoalsPath(String uid) => 'User/$uid/daily_goals';

  Stream<QuerySnapshot<Map<String, dynamic>>> workoutSessionsStream(String uid) {
    if (uid.isEmpty) return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    return _db.collection(_workoutSessionsPath(uid)).snapshots();
  }

  Stream<List<int>> workoutTrendStream(String uid) {
    if (uid.isEmpty) return Stream<List<int>>.value(List<int>.filled(7, 0));

    return workoutSessionsStream(uid).map((snapshot) {
      final weekStart = _weekStart();
      final weekEnd = weekStart.add(const Duration(days: 7));
      final trend = List<int>.filled(7, 0);

      for (final doc in snapshot.docs) {
        final date = _dateValue(doc.data()['endTime']) ?? _dateValue(doc.data()['startTime']);
        if (date == null) continue;
        if (!date.isBefore(weekStart) && date.isBefore(weekEnd)) {
          trend[date.weekday - 1]++;
        }
      }

      return trend;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> foodItemsStream(String uid) {
    if (uid.isEmpty) return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    return _db.collection(_foodItemsPath(uid)).snapshots();
  }

  Stream<int> avgDailyCaloriesStream(String uid) {
    if (uid.isEmpty) return Stream<int>.value(0);

    return foodItemsStream(uid).map((snapshot) {
      final weekStart = _weekStart();
      final weekEnd = weekStart.add(const Duration(days: 7));
      final caloriesByDay = <String, double>{};

      for (final doc in snapshot.docs) {
        final dateStr = _dateString(doc.data()['date']);
        if (dateStr == null) continue;

        final parsed = DateTime.tryParse(dateStr);
        if (parsed == null || parsed.isBefore(weekStart) || !parsed.isBefore(weekEnd)) {
          continue;
        }

        caloriesByDay[dateStr] =
            (caloriesByDay[dateStr] ?? 0) + _doubleValue(doc.data()['calories']);
      }

      final activeFoodDays = caloriesByDay.values.where((v) => v > 0).length;
      if (activeFoodDays == 0) return 0;
      return (caloriesByDay.values.reduce((a, b) => a + b) / activeFoodDays).round();
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> dailyGoalStream(String uid) {
    if (uid.isEmpty) return Stream<DocumentSnapshot<Map<String, dynamic>>>.empty();
    return _db.collection(_dailyGoalsPath(uid)).doc('default').snapshots();
  }

  Stream<int> nutritionAdherenceStream(String uid) {
    if (uid.isEmpty) return Stream<int>.value(0);

    final controller = StreamController<int>.broadcast();
    int avgCalories = 0;
    double targetCalories = 2000;
    bool hasAvg = false;
    bool hasGoal = false;

    void emitAdherence() {
      if (!hasAvg || !hasGoal) return;
      final adherence = targetCalories <= 0
          ? 0
          : ((avgCalories / targetCalories) * 100).clamp(0, 100).round();
      controller.add(adherence);
    }

    final avgSub = avgDailyCaloriesStream(uid).listen((value) {
      avgCalories = value;
      hasAvg = true;
      emitAdherence();
    });

    final goalSub = dailyGoalStream(uid).listen((snapshot) {
      targetCalories = _doubleValue(snapshot.data()?['target_calories'], fallback: 2000);
      hasGoal = true;
      emitAdherence();
    });

    controller.onCancel = () async {
      await avgSub.cancel();
      await goalSub.cancel();
      await controller.close();
    };

    return controller.stream;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> hydrationEntriesStream(String uid) {
    if (uid.isEmpty) return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    return _db.collection(_hydrationEntriesPath(uid)).snapshots();
  }

  Stream<List<int>> hydrationTrendStream(String uid) {
    if (uid.isEmpty) return Stream<List<int>>.value(List<int>.filled(7, 0));

    return hydrationEntriesStream(uid).map((snapshot) {
      final weekStart = _weekStart();
      final weekEnd = weekStart.add(const Duration(days: 7));
      final trend = List<int>.filled(7, 0);

      for (final doc in snapshot.docs) {
        final date = _dateValue(doc.data()['timestamp']);
        if (date == null || date.isBefore(weekStart) || !date.isBefore(weekEnd)) {
          continue;
        }
        trend[date.weekday - 1] += _intValue(doc.data()['amountMl']);
      }

      return trend;
    });
  }

  DateTime _weekStart() {
    final now = DateTime.now();
    final clean = DateTime(now.year, now.month, now.day);
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

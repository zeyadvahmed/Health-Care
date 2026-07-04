import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressData {
  final int avgDailyCalories;
  final List<int> workoutTrend;
  final List<int> hydrationTrend;

  const ProgressData({
    required this.avgDailyCalories,
    required this.workoutTrend,
    required this.hydrationTrend,
  });

  factory ProgressData.empty() {
    return const ProgressData(
      avgDailyCalories: 0,
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
  

  Stream<QuerySnapshot<Map<String, dynamic>>> workoutSessionsStream(String uid) {
    if (uid.isEmpty) return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    return _db.collection(_workoutSessionsPath(uid)).snapshots();
  }

  Stream<List<int>> workoutTrendStream(String uid) {
    if (uid.isEmpty) return Stream<List<int>>.value(List<int>.filled(7, 0));
  
    return _db
        .collection(_workoutSessionsPath(uid))
        .orderBy('endTime', descending: true)
        .limit(7)
        .snapshots()
        .map((snapshot) {
      // Each doc represents one session; map to 1, then reverse to chronological order
      final raw = snapshot.docs.map<int>((doc) => 1).toList();
      final values = raw.reversed.toList();
      while (values.length < 7) values.insert(0, 0);
      return values;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> foodItemsStream(String uid) {
    if (uid.isEmpty) return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    return _db.collection(_foodItemsPath(uid)).snapshots();
  }

  Stream<int> avgDailyCaloriesStream(String uid) {
    if (uid.isEmpty) return Stream<int>.value(0);
    // Simplified: average calories of the last 7 food items
    return _db
        .collection(_foodItemsPath(uid))
        .orderBy('date', descending: true)
        .limit(7)
        .snapshots()
        .map((snapshot) {
      final vals = snapshot.docs.map<int>((doc) {
        final raw = doc.data()['calories'];
        return raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '') ?? 0;
      }).toList();
      if (vals.isEmpty) return 0;
      return (vals.reduce((a, b) => a + b) / vals.length).round();
    });
  }



  Stream<QuerySnapshot<Map<String, dynamic>>> hydrationEntriesStream(String uid) {
    if (uid.isEmpty) return Stream<QuerySnapshot<Map<String, dynamic>>>.empty();
    return _db.collection(_hydrationEntriesPath(uid)).snapshots();
  }

  Stream<List<int>> hydrationTrendStream(String uid) {
    if (uid.isEmpty) return Stream<List<int>>.value(List<int>.filled(7, 0));
    
    return _db
        .collection(_hydrationEntriesPath(uid))
        .orderBy('timestamp', descending: true)
        .limit(7)
        .snapshots()
        .map((snapshot) {
      
      final raw = snapshot.docs.map<int>((doc) {
        final data = doc.data();
        final amt = data['amountMl'];
        
        return int.tryParse(amt.toString()) ?? 0;
      }).toList();

      
      return raw;
    });
  }

  
}

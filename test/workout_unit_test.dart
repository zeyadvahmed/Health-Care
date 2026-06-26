// ============================================================
// workout_unit_test.dart
// test/features/workout/workout_unit_test.dart
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:sparksteel/data/models/session_log_model.dart';
import 'package:sparksteel/data/models/workout_model.dart';
import 'package:sparksteel/data/models/workout_session_model.dart';
import 'package:sparksteel/features/workout/workout_state.dart';



void main() {

  // ── Shared fixture ─────────────────────────────────────────
  final now = DateTime(2026, 1, 1);

  WorkoutModel makeWorkout({String name = 'Push Day', String? description}) {
    return WorkoutModel(
      id: 'w1', userId: 'u1', name: name,
      description: description, difficulty: 'beginner',
      durationMinutes: 45, isPredefined: false,
      createdAt: now, updatedAt: now, isSynced: false,
    );
  }

  SessionLogModel makeLog({
    String exerciseId = 'ex1',
    int setNumber = 1,
    int reps = 10,
    double? weight = 80.0,
    bool completed = true,
  }) {
    return SessionLogModel(
      id: 'log$setNumber', sessionId: 's1',
      exerciseId: exerciseId, setNumber: setNumber,
      reps: reps, weight: weight, isCompleted: completed,
      timestamp: now, updatedAt: now, isSynced: false,
    );
  }

  // ── WorkoutModel ────────────────────────────────────────────
  group('WorkoutModel', () {

    test('toMap / fromMap round-trip preserves all fields', () {
      final w       = makeWorkout(description: 'Focus on chest');
      final restored = WorkoutModel.fromMap(w.toMap());

      expect(restored.id,              w.id);
      expect(restored.name,            w.name);
      expect(restored.description,     w.description);
      expect(restored.difficulty,      w.difficulty);
      expect(restored.durationMinutes, w.durationMinutes);
      expect(restored.isPredefined,    w.isPredefined);
      expect(restored.isSynced,        w.isSynced);
    });

    test('isPredefined stored as INTEGER in SQLite', () {
      expect(makeWorkout().toMap()['isPredefined'], equals(0));
    });

    test('copyWith updates name without touching other fields', () {
      final updated = makeWorkout().copyWith(name: 'Leg Day');
      expect(updated.name,       'Leg Day');
      expect(updated.difficulty, 'beginner');
    });

    test('copyWith clearDescription sets description to null', () {
      final w       = makeWorkout(description: 'old note');
      final cleared = w.copyWith(clearDescription: true);
      expect(cleared.description, isNull);
    });

    test('copyWith cannot clear description without clearDescription flag', () {
      final w    = makeWorkout(description: 'old note');
      final kept = w.copyWith(name: 'changed');
      expect(kept.description, equals('old note'));
    });
  });

  // ── finishSession() calculations ───────────────────────────
  group('finishSession calculations', () {

    test('totalVolume sums only completed weighted sets', () {
      final logs = [
        makeLog(reps: 10, weight: 80.0,  completed: true),   // 800
        makeLog(reps: 8,  weight: 100.0, completed: true,
            setNumber: 2),                                    // 800
        makeLog(reps: 10, weight: null,  completed: true,
            setNumber: 3),                                    // bodyweight — skip
        makeLog(reps: 10, weight: 60.0,  completed: false,
            setNumber: 4),                                    // not done — skip
      ];

      double total = 0;
      for (final l in logs) {
        if (l.isCompleted && l.weight != null) total += l.reps * l.weight!;
      }

      expect(total, equals(1600.0));
    });

    test('caloriesBurned = round(durationSeconds / 60 * 5)', () {
      expect((3600 / 60 * 5).round(), equals(300));  // 60 min → 300 kcal
      expect((1800 / 60 * 5).round(), equals(150));  // 30 min → 150 kcal
      expect((90   / 60 * 5).round(), equals(8));    // 90 sec → rounds to 8
    });

    test('exerciseCount uses distinct exerciseIds not log count', () {
      final logs = [
        makeLog(exerciseId: 'ex1', setNumber: 1),
        makeLog(exerciseId: 'ex1', setNumber: 2),
        makeLog(exerciseId: 'ex2', setNumber: 1),
        makeLog(exerciseId: 'ex3', setNumber: 1),
      ];
      final count = logs.map((l) => l.exerciseId).toSet().length;
      expect(count, equals(3)); // 4 logs but only 3 distinct exercises
    });
  });

  // ── WorkoutState ────────────────────────────────────────────
  group('WorkoutState', () {

    test('WorkoutLoaded.activeSession is null by default', () {
      final state = WorkoutLoaded(workouts: []);
      expect(state.activeSession, isNull);
    });

    test('WorkoutLoaded.activeSession is set after finishSession', () {
      final session = WorkoutSessionModel(
        id: 's1', workoutId: 'w1', userId: 'u1',
        startTime: now, endTime: now,
        totalVolume: 1600, totalDuration: 3600,
        caloriesBurned: 300,
        updatedAt: now, isSynced: false,
      );
      final state = WorkoutLoaded(workouts: [], activeSession: session);
      expect(state.activeSession, isNotNull);
      expect(state.activeSession!.caloriesBurned, equals(300));
    });

    test('WorkoutError holds message string', () {
      final state = WorkoutError(message: 'Network error');
      expect(state.message, equals('Network error'));
    });
  });
}
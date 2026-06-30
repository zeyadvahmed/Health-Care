import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityChallengeModel {
  final String id;
  final String userId;

  // Challenge metadata
  final String title;
  final String description;
  final String type;        // hydration | nutrition | workout | meditation | medication

  // Progress tracking
  final int target;         // e.g. 4 (drink 4 glasses)
  final int currentProgress;// e.g. 2 (drank 2 so far)

  // Reward
  final int xpReward;       // XP awarded on completion
  final bool completed;
  final bool rewardClaimed; // prevents double XP award

  // Timestamps
  final DateTime challengeDate; // date this challenge belongs to (midnight)
  final DateTime? completedAt;
  final DateTime updatedAt;

  // Sync
  final bool isSynced;

  ActivityChallengeModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.currentProgress = 0,
    required this.xpReward,
    this.completed = false,
    this.rewardClaimed = false,
    required this.challengeDate,
    this.completedAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  double get progress =>
      target <= 0 ? 0.0 : (currentProgress / target).clamp(0.0, 1.0);

  String get subtitle {
    if (completed) return 'Completed ✓';
    if (currentProgress == 0) return 'Not started yet';
    return '$currentProgress / $target done';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'target': target,
      'currentProgress': currentProgress,
      'xpReward': xpReward,
      'completed': completed ? 1 : 0,
      'rewardClaimed': rewardClaimed ? 1 : 0,
      'challengeDate': challengeDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory ActivityChallengeModel.fromMap(Map<String, dynamic> map) {
    return ActivityChallengeModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      target: map['target'],
      currentProgress: map['currentProgress'] ?? 0,
      xpReward: map['xpReward'],
      completed: map['completed'] == 1,
      rewardClaimed: map['rewardClaimed'] == 1,
      challengeDate: DateTime.parse(map['challengeDate']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      updatedAt: DateTime.parse(map['updatedAt']),
      isSynced: map['isSynced'] == 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'target': target,
      'currentProgress': currentProgress,
      'xpReward': xpReward,
      'completed': completed,
      'rewardClaimed': rewardClaimed,
      'challengeDate': Timestamp.fromDate(challengeDate),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  factory ActivityChallengeModel.fromFirestore(Map<String, dynamic> map) {
    return ActivityChallengeModel(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      target: map['target'],
      currentProgress: map['currentProgress'] ?? 0,
      xpReward: map['xpReward'],
      completed: map['completed'] ?? false,
      rewardClaimed: map['rewardClaimed'] ?? false,
      challengeDate: (map['challengeDate'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  ActivityChallengeModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? type,
    int? target,
    int? currentProgress,
    int? xpReward,
    bool? completed,
    bool? rewardClaimed,
    DateTime? challengeDate,
    DateTime? completedAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return ActivityChallengeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      target: target ?? this.target,
      currentProgress: currentProgress ?? this.currentProgress,
      xpReward: xpReward ?? this.xpReward,
      completed: completed ?? this.completed,
      rewardClaimed: rewardClaimed ?? this.rewardClaimed,
      challengeDate: challengeDate ?? this.challengeDate,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
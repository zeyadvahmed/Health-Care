// ============================================================
// user_model.dart
// Represents a user account and personal profile data.
//
// Usage:
//   UserModel user = UserModel.fromMap(map);       // from SQLite
//   UserModel user = UserModel.fromFirestore(map); // from Firestore
//   map = user.toMap();                            // save to SQLite
//   map = user.toFirestore();                      // push to Firestore
//   user = user.copyWith(name: 'New Name');        // update one field
//
// Rules:
//   - id is the SQLite primary key (UUID string)
//   - uid is the Firebase Auth UID — different from id
//   - isSynced stored as INTEGER 0/1 in SQLite, bool in Firestore
//   - DateTimes stored as ISO 8601 strings in SQLite
//   - caloriesGoal defaults to 2000, waterGoal defaults to 2500
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;
  final int? age;
  final double? weight;
  final double? height;
  final int caloriesGoal;
  final int waterGoal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  UserModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.age,
    this.weight,
    this.height,
    this.caloriesGoal = 2000,
    this.waterGoal = 2500,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  // ----------------------------------------------------------
  // toMap()
  // Converts this model to a Map for inserting/updating SQLite.
  // Booleans → INTEGER (1/0), DateTimes → ISO 8601 string.
  // ----------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'age': age,
      'weight': weight,
      'height': height,
      'caloriesGoal': caloriesGoal,
      'waterGoal': waterGoal,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  // ----------------------------------------------------------
  // fromMap()
  // Builds a UserModel from a SQLite row map.
  // Called when reading the user from the local database.
  // ----------------------------------------------------------
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      age: map['age'],
      weight: map['weight'],
      height: map['height'],
      caloriesGoal: map['caloriesGoal'] ?? 2000,
      waterGoal: map['waterGoal'] ?? 2500,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isSynced: map['isSynced'] == 1,
    );
  }

  // ----------------------------------------------------------
  // toFirestore()
  // Converts this model to a Map for pushing to Firestore.
  // DateTimes → Firestore Timestamp, isSynced always true here.
  // ----------------------------------------------------------
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'uid': uid,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'age': age,
      'weight': weight,
      'height': height,
      'caloriesGoal': caloriesGoal,
      'waterGoal': waterGoal,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isSynced': true,
    };
  }

  // ----------------------------------------------------------
  // fromFirestore()
  // Builds a UserModel from a Firestore document map.
  // Called during cloud sync to restore user data.
  // ----------------------------------------------------------
  factory UserModel.fromFirestore(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profileImageUrl: map['profileImageUrl'],
      age: map['age'],
      weight: map['weight'],
      height: map['height'],
      caloriesGoal: map['caloriesGoal'] ?? 2000,
      waterGoal: map['waterGoal'] ?? 2500,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isSynced: true,
    );
  }

  // ----------------------------------------------------------
  // copyWith()
  // Returns a new UserModel with only the specified fields changed.
  // Used by profile_controller when updating name, weight, goals etc.
  // ----------------------------------------------------------
  UserModel copyWith({
    String? id,
    String? uid,
    String? name,
    String? email,
    String? profileImageUrl,
    int? age,
    double? weight,
    double? height,
    int? caloriesGoal,
    int? waterGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      waterGoal: waterGoal ?? this.waterGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
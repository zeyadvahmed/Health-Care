import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final FirebaseFirestore
      _firestore =
      FirebaseFirestore.instance;

  Future<void> createUser({

    required String uid,

    required String email,

  }) async {

    await _firestore
        .collection('users')
        .doc(uid)
        .set({

      'uid': uid,

      'email': email,

      'createdAt':
          Timestamp.now(),
    });
  }
}
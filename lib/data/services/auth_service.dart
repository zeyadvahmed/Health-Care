import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // REGISTER
  Future<void> register({

    required String name,

    required String email,

    required String password,

  }) async {

    final credential =
        await _auth
            .createUserWithEmailAndPassword(

      email: email,

      password: password,
    );

    await FirebaseFirestore.instance

        .collection('User')

        .doc(
          credential.user!.uid,
        )

        .set({

      'uid':
          credential.user!.uid,

      'name': name,

      'email': email,
    });
  }

  // LOGIN
  Future<void> login({

    required String email,

    required String password,

  }) async {

    await _auth
        .signInWithEmailAndPassword(

      email: email,

      password: password,
    );
  }

  // LOGOUT
  Future<void> logout()
      async {

    await _auth.signOut();
  }

  // CURRENT USER
  User? get currentUser =>
      _auth.currentUser;
}
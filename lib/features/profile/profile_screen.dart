import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/services/auth_service.dart';

import '../../data/local/database_helper.dart';

import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {

  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  final dbHelper =
      DatabaseHelper.instance;

  Map<String, dynamic>? data;

  @override
  void initState() {

    super.initState();

    loadUser();
  }

  Future<void> loadUser() async {

    final user =
        FirebaseAuth.instance.currentUser;

    final firestoreData =
        await FirebaseFirestore.instance

            .collection('User')

            .doc(user!.uid)

            .get();

    data =
        firestoreData.data();

    data!['age'] ??= '21';

    data!['weight'] ??= '55';

    data!['height'] ??= '160';

    data!['waterGoal'] ??= '2.5';

    data!['caloriesGoal'] ??= '2400';

    await dbHelper
        .insertUserIfNotExists({

      'name':
          data!['name'],

      'uid':
          user.uid,

      'email':
          data!['email'],

      'age':
          data!['age'],

      'weight':
          data!['weight'],

      'height':
          data!['height'],

      'waterGoal':
          data!['waterGoal'],

      'caloriesGoal':
          data!['caloriesGoal'],
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    final authService =
        AuthService();

    if (data == null) {

      return const Scaffold(

        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F5F5,
      ),

      body: SingleChildScrollView(

        child: Column(

          children: [

            Stack(

              clipBehavior:
                  Clip.none,

              children: [

                Container(

                  height: 260,

                  width:
                      double.infinity,

                  decoration:
                      const BoxDecoration(

                    color:
                        Color(
                      0xFF1E88FF,
                    ),
                  ),

                  child: const SafeArea(

                    child: Center(

                      child: Text(

                        'Profile',

                        style: TextStyle(

                          color:
                              Colors.white,

                          fontSize: 36,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(

                  bottom: -70,

                  left: 0,

                  right: 0,

                  child: Center(

                    child: Stack(

                      children: [

                        const CircleAvatar(

                          radius: 70,

                          backgroundColor:
                              Colors.white,

                          child: CircleAvatar(

                            radius: 64,

                            backgroundColor:
                                Color(
                              0xFFD9CDEB,
                            ),
                          ),
                        ),

                        Positioned(

                          bottom: 6,

                          right: 6,

                          child: Container(

                            padding:
                                const EdgeInsets.all(
                              8,
                            ),

                            decoration:
                                const BoxDecoration(

                              color:
                                  Colors.white,

                              shape:
                                  BoxShape.circle,
                            ),

                            child: const Icon(

                              Icons.edit,

                              color:
                                  Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 90,
            ),

            Text(

              data!['name'],

              style:
                  const TextStyle(

                fontSize: 34,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(

              data!['email'],

              style:
                  const TextStyle(

                color:
                    Colors.grey,

                fontSize: 18,
              ),
            ),

            const SizedBox(
              height: 35,
            ),

            sectionTitle(),

            const SizedBox(
              height: 18,
            ),

            detailsCard(),

            const SizedBox(
              height: 30,
            ),

            sectionTitleGoals(),

            const SizedBox(
              height: 18,
            ),

            goalsCard(),

            const SizedBox(
              height: 35,
            ),

            Padding(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: InkWell(

                onTap: () async {

                  await authService
                      .logout();

                  Navigator.pushAndRemoveUntil(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          LoginScreen(),
                    ),

                    (route) => false,
                  );
                },

                child: Container(

                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 20,
                  ),

                  decoration:
                      BoxDecoration(

                    color:
                        const Color(
                      0xFFFFEEEE,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                  ),

                  child: const Row(

                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      Icon(

                        Icons.logout,

                        color:
                            Colors.red,
                      ),

                      SizedBox(
                        width: 10,
                      ),

                      Text(

                        'Logout',

                        style: TextStyle(

                          color:
                              Colors.red,

                          fontSize: 28,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle() {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          const Text(

            'Personal Details',

            style:
                TextStyle(

              fontSize: 30,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          InkWell(

            onTap: () {

              editDialog();
            },

            child: const Text(

              'Edit',

              style: TextStyle(

                color:
                    Colors.blue,

                fontWeight:
                    FontWeight.bold,

                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void editDialog() {

    final ageController =
        TextEditingController(
      text: data!['age'],
    );

    final weightController =
        TextEditingController(
      text: data!['weight'],
    );

    final heightController =
        TextEditingController(
      text: data!['height'],
    );

    final waterController =
        TextEditingController(
      text: data!['waterGoal'],
    );

    final caloriesController =
        TextEditingController(
      text: data!['caloriesGoal'],
    );

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title: const Text(
            'Edit Profile',
          ),

          content:
              SingleChildScrollView(

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                TextField(
                  controller:
                      ageController,
                ),

                TextField(
                  controller:
                      weightController,
                ),

                TextField(
                  controller:
                      heightController,
                ),

                TextField(
                  controller:
                      waterController,
                ),

                TextField(
                  controller:
                      caloriesController,
                ),
              ],
            ),
          ),

          actions: [

            ElevatedButton(

              onPressed: () async {

                final users =
                    await dbHelper
                        .getUsers();

                final userId =
                    users.first['id'];

                await dbHelper
                    .updateUser({

                  'name':
                      data!['name'],

                  'email':
                      data!['email'],

                  'age':
                      ageController.text,

                  'weight':
                      weightController.text,

                  'height':
                      heightController.text,

                  'waterGoal':
                      waterController.text,

                  'caloriesGoal':
                      caloriesController.text,

                }, userId);

                setState(() {

                  data!['age'] =
                      ageController.text;

                  data!['weight'] =
                      weightController.text;

                  data!['height'] =
                      heightController.text;

                  data!['waterGoal'] =
                      waterController.text;

                  data!['caloriesGoal'] =
                      caloriesController.text;
                });

                Navigator.pop(
                  context,
                );
              },

              child: const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget sectionTitleGoals() {

    return const Padding(

      padding:
          EdgeInsets.symmetric(
        horizontal: 24,
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [

          Text(

            'Daily Goals',

            style: TextStyle(

              fontSize: 30,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(

            'Edit',

            style: TextStyle(

              color:
                  Colors.blue,

              fontWeight:
                  FontWeight.bold,

              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget detailsCard() {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          vertical: 28,
        ),

        decoration:
            BoxDecoration(

          color:
              const Color(
            0xFFDDEAF7,
          ),

          borderRadius:
              BorderRadius.circular(
            24,
          ),
        ),

        child: Row(

          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,

          children: [

            detailItem(
              'Age',
              '${data!['age']} yrs',
            ),

            const verticalDivider(),

            detailItem(
              'Weight',
              '${data!['weight']} kg',
            ),

            const verticalDivider(),

            detailItem(
              'Height',
              '${data!['height']} cm',
            ),
          ],
        ),
      ),
    );
  }

  Widget goalsCard() {

    return Padding(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),

      child: Container(

        padding:
            const EdgeInsets.symmetric(
          vertical: 28,
        ),

        decoration:
            BoxDecoration(

          color:
              const Color(
            0xFFDDEAF7,
          ),

          borderRadius:
              BorderRadius.circular(
            24,
          ),
        ),

        child: Row(

          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,

          children: [

            detailItem(
              'Calories Goal',
              '${data!['caloriesGoal']} kcal',
            ),

            const verticalDivider(),

            detailItem(
              'Water Goal',
              '${data!['waterGoal']} L',
            ),
          ],
        ),
      ),
    );
  }
}

class detailItem
    extends StatelessWidget {

  final String title;
  final String value;

  const detailItem(

    this.title,
    this.value, {

    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        Text(
          title,
        ),

        const SizedBox(
          height: 10,
        ),

        Text(

          value,

          style:
              const TextStyle(

            fontSize: 22,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class verticalDivider
    extends StatelessWidget {

  const verticalDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: 1,

      height: 65,

      color:
          Colors.black12,
    );
  }
}

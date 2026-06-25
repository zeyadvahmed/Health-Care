import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/services/auth_service.dart';

import '../../data/database/database_helper.dart';

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
      DatabaseHelper();

  Map<String, dynamic>? data;

  @override
  void initState() {

    super.initState();

    loadUser();
  }

Future<void> loadUser() async {

  try {

    final user = FirebaseAuth.instance.currentUser;

    final firestoreData =
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user!.uid)
            .get();

    if (!firestoreData.exists || firestoreData.data() == null) {

      final localUsers = await dbHelper.getUsers();

      if (localUsers.isNotEmpty) {
        data = localUsers.first;
      } else {
        data = {
          'name': '',
          'email': user.email ?? '',
          'age': 21,
          'weight': 55.0,
          'height': 160.0,
          'waterGoal': 2.5,
          'caloriesGoal': 2400,
        };
        await dbHelper.insertUserIfNotExists(data!);
      }

    } else {

      data = firestoreData.data()!;

      data!['age'] ??= 21;
      data!['weight'] ??= 55.0;
      data!['height'] ??= 160.0;
      data!['waterGoal'] ??= 2.5;
      data!['caloriesGoal'] ??= 2400;

      await dbHelper.insertUserIfNotExists({
        'name': data!['name'],
        'email': data!['email'],
        'age': data!['age'],
        'weight': data!['weight'],
        'height': data!['height'],
        'waterGoal': data!['waterGoal'],
        'caloriesGoal': data!['caloriesGoal'],
      });
    }

  } catch (e) {
    debugPrint('loadUser error: $e');
    final localUsers = await dbHelper.getUsers();
    if (localUsers.isNotEmpty) {
      data = localUsers.first;
    } else {
      data = {
        'name': '',
        'email': FirebaseAuth.instance.currentUser?.email ?? '',
        'age': 21,
        'weight': 55.0,
        'height': 160.0,
        'waterGoal': 2.5,
        'caloriesGoal': 2400,
      };
    }
  }

  if (!mounted) return;
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

                  child: const Center(

                    child: CircleAvatar(

                      radius: 70,

                      backgroundColor: Colors.white,

                      child: CircleAvatar(

                        radius: 64,

                        backgroundColor: Color(0xFFD9CDEB),

                        child: Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 90,
            ),

            Text(

              data!['name'] ?? '',

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

              data!['email'] ?? '',

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

  final navigator = Navigator.of(context);

  await authService.logout();

  navigator.pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => LoginScreen(),
    ),
    (route) => false,
  );
},

  child: Container(

    width: double.infinity,

    padding: const EdgeInsets.symmetric(
      vertical: 20,
    ),

    decoration: BoxDecoration(
      color: const Color(0xFFFFEEEE),
      borderRadius: BorderRadius.circular(24),
    ),

    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.logout,
          color: Colors.red,
        ),
        SizedBox(width: 10),
        Text(
          'Logout',
          style: TextStyle(
            color: Colors.red,
            fontSize: 28,
            fontWeight: FontWeight.bold,
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

    final nameController =
    TextEditingController(
  text: data!['name'],
);

       final emailController =
    TextEditingController(
  text: data!['email'],
);

    final ageController =
        TextEditingController(
      text: data!['age'].toString(),
    );

    final weightController =
        TextEditingController(
      text: data!['weight'].toString(),
    );

    final heightController =
        TextEditingController(
      text: data!['height'].toString(),
    );

    final waterController =
        TextEditingController(
      text: data!['waterGoal'].toString(),
    );

    final caloriesController =
        TextEditingController(
      text: data!['caloriesGoal'].toString(),
    );

    showDialog(

      context: context,

      builder: (_) {

        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {

        return AlertDialog(

          title: const Text(
            'Edit Profile',
          ),

          content:
              SingleChildScrollView(

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

                 children: [TextField(
            controller: nameController,
   decoration: const InputDecoration(
    labelText: 'Name',
  ),
),

const SizedBox(height: 10),

TextField(
  controller: emailController,
  readOnly: true,
  decoration: const InputDecoration(
    labelText: 'Email',
  ),
),

const SizedBox(height: 10),

                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                  ),
                ),

                TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                  ),
                ),

                TextField(
                  controller: heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Height',
                  ),
                ),

                TextField(
                  controller: waterController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Water Goal',
                  ),
                ),

                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories Goal',
                  ),
                ),
              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            ElevatedButton(

              onPressed: isSaving ? null : () async {

                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name is required')),
                  );
                  return;
                }

                if (int.tryParse(ageController.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Age must be a valid number')),
                  );
                  return;
                }

                if (double.tryParse(weightController.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Weight must be a valid number')),
                  );
                  return;
                }

                if (double.tryParse(heightController.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Height must be a valid number')),
                  );
                  return;
                }

                if (double.tryParse(waterController.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Water Goal must be a valid number')),
                  );
                  return;
                }

                if (int.tryParse(caloriesController.text) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calories Goal must be a valid number')),
                  );
                  return;
                }

                try {
                  setDialogState(() => isSaving = true);

                  final users = await dbHelper.getUsers();

                  if (users.isNotEmpty) {
                    final userId = users.first['id'];
                    await dbHelper.updateUser({
                      'name': nameController.text,
                      'email': data!['email'],
                      'age': int.parse(ageController.text),
                      'weight': double.parse(weightController.text),
                      'height': double.parse(heightController.text),
                      'waterGoal': double.parse(waterController.text),
                      'caloriesGoal': int.parse(caloriesController.text),
                    }, userId);
                  } else {
                    await dbHelper.insertUserIfNotExists({
                      'name': nameController.text,
                      'email': data!['email'],
                      'age': int.parse(ageController.text),
                      'weight': double.parse(weightController.text),
                      'height': double.parse(heightController.text),
                      'waterGoal': double.parse(waterController.text),
                      'caloriesGoal': int.parse(caloriesController.text),
                    });
                  }

                  // Sync to Firestore
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance
                      .collection('User')
                      .doc(user!.uid)
                      .set({
                    'name': nameController.text,
                    'age': int.parse(ageController.text),
                    'weight': double.parse(weightController.text),
                    'height': double.parse(heightController.text),
                    'waterGoal': double.parse(waterController.text),
                    'caloriesGoal': int.parse(caloriesController.text),
                  }, SetOptions(merge: true));

                  setState(() {
                    data!['name'] = nameController.text;
                    data!['age'] = int.parse(ageController.text);
                    data!['weight'] = double.parse(weightController.text);
                    data!['height'] = double.parse(heightController.text);
                    data!['waterGoal'] = double.parse(waterController.text);
                    data!['caloriesGoal'] = int.parse(caloriesController.text);
                  });

                  if (mounted) Navigator.pop(context);

                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving: ${e.toString()}')),
                    );
                  }
                } finally {
                  if (mounted) setDialogState(() => isSaving = false);
                }
              },

              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        );
          },
        );
      },
    );
  }

  Widget sectionTitleGoals() {

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

            'Daily Goals',

            style: TextStyle(

              fontSize: 30,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          InkWell(

            onTap: () => editDialog(),

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

            DetailItem(
              'Age',
              '${int.tryParse(data!['age'].toString()) ?? 0} yrs',
            ),

            const VerticalDivider(),

            DetailItem(
              'Weight',
              '${(double.tryParse(data!['weight'].toString()) ?? 0).toStringAsFixed(1)} kg',
            ),

            const VerticalDivider(),

            DetailItem(
              'Height',
              '${(double.tryParse(data!['height'].toString()) ?? 0).toStringAsFixed(1)} cm',
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

            DetailItem(
              'Calories Goal',
              '${int.tryParse(data!['caloriesGoal'].toString()) ?? 0} kcal',
            ),

            const VerticalDivider(),

            DetailItem(
              'Water Goal',
              '${(double.tryParse(data!['waterGoal'].toString()) ?? 0).toStringAsFixed(1)} L',
            ),
          ],
        ),
      ),
    );
  }
}

class DetailItem extends StatelessWidget {

  final String title;
  final String value;

  const DetailItem(
    this.title,
    this.value, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class VerticalDivider extends StatelessWidget {

  const VerticalDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: 1,

      height: 65,

      color: Colors.black12,
    );
  }
}
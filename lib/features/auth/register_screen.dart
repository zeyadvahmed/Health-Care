import 'package:flutter/material.dart';

import '../../main_nav_screen.dart';

import '../../data/services/auth_service.dart';

import '../../shared/widgets/custom_snackbar.dart';

class RegisterScreen
    extends StatelessWidget {

  RegisterScreen({
    super.key,
  });

  final TextEditingController
      nameController =
      TextEditingController();

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  final TextEditingController
      confirmPasswordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFF062B57,
      ),

      body: SafeArea(

        child: Column(

          children: [

            const SizedBox(
              height: 35,
            ),

            Container(

              width: 120,

              height: 120,

              decoration:
                  BoxDecoration(

                color:
                    Colors.blue,

                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),

              child: const Icon(

                Icons.show_chart,

                color:
                    Colors.white,

                size: 60,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            RichText(

              text: const TextSpan(

                children: [

                  TextSpan(

                    text: 'Spark',

                    style: TextStyle(

                      color:
                          Colors.white,

                      fontSize: 34,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  TextSpan(

                    text: 'Steal',

                    style: TextStyle(

                      color:
                          Colors.blue,

                      fontSize: 34,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 35,
            ),

            Expanded(

              child: Container(

                width: double.infinity,

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 35,
                ),

                decoration:
                    const BoxDecoration(

                  color:
                      Color(0xFFF3F3F3),

                  borderRadius:
                      BorderRadius.only(

                    topLeft:
                        Radius.circular(
                      45,
                    ),

                    topRight:
                        Radius.circular(
                      45,
                    ),
                  ),
                ),

                child: SingleChildScrollView(

                  child: Column(

                    children: [

                      const Text(

                        'Create Account',

                        style: TextStyle(

                          color:
                              Colors.blue,

                          fontSize: 36,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      const Text(

                        'Register to continue',

                        style: TextStyle(

                          color:
                              Colors.black54,

                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(
                        height: 35,
                      ),

                      textField(

                        controller:
                            nameController,

                        hint:
                            'Full Name',

                        isPassword:
                            false,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      textField(

                        controller:
                            emailController,

                        hint:
                            'Email',

                        isPassword:
                            false,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      textField(

                        controller:
                            passwordController,

                        hint:
                            'Password',

                        isPassword:
                            true,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      textField(

                        controller:
                            confirmPasswordController,

                        hint:
                            'Confirm Password',

                        isPassword:
                            true,
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      registerButton(
                        context,
                      ),

                      const SizedBox(
                        height: 40,
                      ),

                      Row(

                        children: [

                          Expanded(
                            child: Divider(),
                          ),

                          Padding(

                            padding:
                                const EdgeInsets.symmetric(
                              horizontal:
                                  12,
                            ),

                            child: Text(
                              'Or sign up with',
                            ),
                          ),

                          Expanded(
                            child: Divider(),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 35,
                      ),

                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          socialButton(
                            'G',
                          ),

                          const SizedBox(
                            width: 25,
                          ),

                          socialButton(
                            'f',
                          ),

                          const SizedBox(
                            width: 25,
                          ),

                          socialButton(
                            '',
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 45,
                      ),

                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          const Text(
                            'Already have account ? ',
                          ),

                          GestureDetector(

                            onTap: () {

                              Navigator.pop(
                                context,
                              );
                            },

                            child: const Text(

                              'Login',

                              style: TextStyle(

                                color:
                                    Colors.blue,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget textField({

    required TextEditingController
        controller,

    required String hint,

    required bool isPassword,
  }) {

    return TextField(

      controller:
          controller,

      obscureText:
          isPassword,

      decoration:
          InputDecoration(

        hintText: hint,

        filled: true,

        fillColor:
            const Color(
          0xFFE4E4E4,
        ),

        border:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          borderSide:
              BorderSide.none,
        ),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  Widget registerButton(
    BuildContext context,
  ) {

    return SizedBox(

      width: double.infinity,

      height: 65,

      child: ElevatedButton(

        style:
            ElevatedButton.styleFrom(

          backgroundColor:
              Colors.blue,

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
        ),

        onPressed: () async {

          if (passwordController.text !=
              confirmPasswordController
                  .text) {

            CustomSnackbar.show(

              context,

              'Passwords do not match',
            );

            return;
          }

          try {

            await authService.register(

              name:
                  nameController.text
                      .trim(),

              email:
                  emailController.text
                      .trim(),

              password:
                  passwordController.text
                      .trim(),
            );

            Navigator.pushReplacement(

              context,

              MaterialPageRoute(

                builder: (_) =>
                    const MainNavScreen(),
              ),
            );

          } catch (e) {

            CustomSnackbar.show(

              context,

              e.toString(),
            );
          }
        },

        child: const Text(

          'Register',

          style: TextStyle(

            color:
                Colors.white,

            fontSize: 28,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget socialButton(
    String text,
  ) {

    return Container(

      width: 65,

      height: 65,

      decoration:
          BoxDecoration(

        color:
            const Color(
          0xFFE4E4E4,
        ),

        shape:
            BoxShape.circle,
      ),

      child: Center(

        child: Text(

          text,

          style: const TextStyle(

            fontSize: 28,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
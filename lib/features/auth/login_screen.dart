import 'package:flutter/material.dart';

import '../../main_nav_screen.dart';

import '../../data/services/auth_service.dart';

import '../../shared/widgets/custom_snackbar.dart';

import 'register_screen.dart';

class LoginScreen
    extends StatelessWidget {

  LoginScreen({
    super.key,
  });

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      passwordController =
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
              height: 30,
            ),

            Container(

              width: 100,

              height: 100,

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

                size: 48,
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

                      fontSize: 28,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  TextSpan(

                    text: 'Steal',

                    style: TextStyle(

                      color:
                          Colors.blue,

                      fontSize: 28,

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

                        'Welcome Back',

                        style: TextStyle(

                          color:
                              Colors.blue,

                          fontSize: 28,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      const Text(

                        'Log in to track your health journey',

                        style: TextStyle(

                          color:
                              Colors.black54,

                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(
                        height: 24,
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
                        height: 22,
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
                        height: 15,
                      ),

                      Align(

                        alignment:
                            Alignment.centerRight,

                        child: Text(

                          'Forget Password?',

                          style: TextStyle(

                            color:
                                Colors.blue,

                            fontSize: 18,

                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      loginButton(
                        context,
                      ),

                      const SizedBox(
                        height: 45,
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
                              'Or sign in with',
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
                        height: 50,
                      ),

                      const Text(

                        'By logging, you agree to our Terms & Conditions and PrivacyPolicy.',

                        textAlign:
                            TextAlign.center,

                        style: TextStyle(

                          color:
                              Colors.black54,

                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      Row(

                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          const Text(
                            "Doesn’t have account ? ",
                          ),

                          GestureDetector(

                            onTap: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder: (_) =>
                                      RegisterScreen(),
                                ),
                              );
                            },

                            child: const Text(

                              'Sign Up',

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
          horizontal: 18,
          vertical: 14,
        ),
      ),
    );
  }

  Widget loginButton(
    BuildContext context,
  ) {

    return SizedBox(

      width: double.infinity,

      height: 55,

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

          try {

            await authService.login(

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

              'Invalid Email or Password',
            );
          }
        },

        child: const Text(

          'Login',

          style: TextStyle(

            color:
                Colors.white,

            fontSize: 20,

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

      width: 55,

      height: 55,

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

            fontSize: 24,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class SplashScreen
    extends StatefulWidget {

  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  double progress = 0;

  @override
  void initState() {

    super.initState();

    startLoading();
  }

  void startLoading() {

    Timer.periodic(

      const Duration(
        milliseconds: 80,
      ),

      (timer) {

        setState(() {

          progress += 2;
        });

        if (progress >= 100) {

          timer.cancel();

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  LoginScreen(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFF062B57,
      ),

      body: Padding(

        padding:
            const EdgeInsets.symmetric(
          horizontal: 30,
        ),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const Spacer(),

            Container(

              width: 140,

              height: 140,

              decoration:
                  BoxDecoration(

                color:
                    Colors.blue,

                borderRadius:
                    BorderRadius.circular(
                  35,
                ),
              ),

              child: const Icon(

                Icons.show_chart,

                color:
                    Colors.white,

                size: 70,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            RichText(

              text: const TextSpan(

                children: [

                  TextSpan(

                    text: 'Spark',

                    style: TextStyle(

                      color:
                          Colors.white,

                      fontSize: 38,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  TextSpan(

                    text: 'Steal',

                    style: TextStyle(

                      color:
                          Colors.blue,

                      fontSize: 38,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(

              'your personal health companion',

              style: TextStyle(

                color:
                    Colors.white70,

                fontSize: 18,

                letterSpacing: 1,
              ),
            ),

            const Spacer(),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

              children: [

                const Text(

                  'Initializing',

                  style: TextStyle(

                    color:
                        Colors.white,

                    fontSize: 20,
                  ),
                ),

                Text(

                  '${progress.toInt()}%',

                  style: const TextStyle(

                    color:
                        Colors.blue,

                    fontSize: 28,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            ClipRRect(

              borderRadius:
                  BorderRadius.circular(
                20,
              ),

              child: LinearProgressIndicator(

                value:
                    progress / 100,

                minHeight: 10,

                backgroundColor:
                    Colors.black26,

                valueColor:
                    const AlwaysStoppedAnimation(
                  Colors.blue,
                ),
              ),
            ),

            const SizedBox(
              height: 70,
            ),
          ],
        ),
      ),
    );
  }
}
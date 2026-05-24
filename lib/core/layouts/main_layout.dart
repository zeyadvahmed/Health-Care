import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {

  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Padding(
          padding:
              const EdgeInsets.all(20),

          child: child,
        ),
      ),
    );
  }
}
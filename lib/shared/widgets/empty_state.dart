import 'package:flutter/material.dart';

class EmptyState
    extends StatelessWidget {

  final String title;

  final IconData icon;

  const EmptyState({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Center(

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,

            size: 70,

            color: Colors.grey,
          ),

          const SizedBox(
            height: 16,
          ),

          Text(
            title,

            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
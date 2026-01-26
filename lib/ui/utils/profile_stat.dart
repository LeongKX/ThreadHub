import 'package:flutter/material.dart';

class ProfileStat extends StatelessWidget {
  final String label;
  final int count;

  const ProfileStat({super.key, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label),
      ],
    );
  }
}

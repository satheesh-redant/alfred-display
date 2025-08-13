import 'package:flutter/material.dart';

class StatusCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;

  const StatusCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Image.asset(
            imagePath,
            height: 150,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
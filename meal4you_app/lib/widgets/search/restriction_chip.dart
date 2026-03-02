import 'package:flutter/material.dart';

class RestrictionChip extends StatelessWidget {
  final String label;

  const RestrictionChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 157, 0, 255).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color.fromARGB(255, 157, 0, 255).withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color.fromARGB(255, 157, 0, 255),
        ),
      ),
    );
  }
}

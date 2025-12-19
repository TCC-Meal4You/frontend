import 'package:flutter/material.dart';

class RestrictionChip extends StatelessWidget {
  final String restriction;

  const RestrictionChip({super.key, required this.restriction});

  MaterialColor _getColorFromString(String text) {
    final hash = text.hashCode;
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.indigo,
      Colors.blue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lime,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final cor = _getColorFromString(restriction);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        restriction,
        style: TextStyle(
          fontSize: 12,
          color: cor[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RestrictionChip extends StatelessWidget {
  final String restriction;
  final int seed;
  const RestrictionChip({super.key, required this.restriction, this.seed = 0});

  MaterialColor _getColorFromString(String text) {
    final normalized = text.trim().toLowerCase();
    var hash = 2166136261;
    for (final codeUnit in normalized.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    hash = (hash ^ (seed * 31)) & 0x7fffffff;
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
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final cor = _getColorFromString(restriction);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
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

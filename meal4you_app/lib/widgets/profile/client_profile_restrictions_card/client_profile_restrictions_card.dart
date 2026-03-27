import 'package:flutter/material.dart';

class ClientProfileRestrictionsCard extends StatelessWidget {
  final List<String> restricoes;

  const ClientProfileRestrictionsCard({super.key, required this.restricoes});

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Restricoes Alimentares',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${restricoes.length} restricoes ativas',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (restricoes.isEmpty)
            const Text(
              'Nenhuma restricao cadastrada',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: restricoes.map((restricao) {
                final cor = _getColorFromString(restricao);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: cor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    restricao,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      // ignore: deprecated_member_use
                      color: cor[700],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

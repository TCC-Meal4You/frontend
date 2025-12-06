import 'package:flutter/material.dart';

class RestricaoChip extends StatelessWidget {
  final String restricao;

  const RestricaoChip({super.key, required this.restricao});

  @override
  Widget build(BuildContext context) {
    Color corIcone;
    IconData icone;

    switch (restricao.toLowerCase()) {
      case 'vegano':
        corIcone = Colors.green.shade700;
        icone = Icons.eco;
        break;
      case 'vegetariano':
        corIcone = Colors.lightGreen.shade700;
        icone = Icons.local_florist;
        break;
      case 'sem glúten':
      case 'sem gluten':
        corIcone = Colors.orange.shade700;
        icone = Icons.grain;
        break;
      case 'sem lactose':
        corIcone = Colors.blue.shade700;
        icone = Icons.water_drop;
        break;
      default:
        corIcone = Colors.grey.shade600;
        icone = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: corIcone),
          const SizedBox(width: 6),
          Text(
            restricao,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

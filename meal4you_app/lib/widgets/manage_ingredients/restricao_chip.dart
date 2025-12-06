import 'package:flutter/material.dart';

class RestricaoChip extends StatelessWidget {
  final String restricao;

  const RestricaoChip({super.key, required this.restricao});

  @override
  Widget build(BuildContext context) {
    Color corFundo;
    Color corTexto;

    switch (restricao.toLowerCase()) {
      case 'vegano':
        corFundo = Colors.green.withValues(alpha: 0.2);
        corTexto = Colors.green.shade800;
        break;
      case 'vegetariano':
        corFundo = Colors.lightGreen.withValues(alpha: 0.2);
        corTexto = Colors.lightGreen.shade800;
        break;
      case 'sem glúten':
      case 'sem gluten':
        corFundo = Colors.orange.withValues(alpha: 0.2);
        corTexto = Colors.orange.shade800;
        break;
      case 'sem lactose':
        corFundo = Colors.blue.withValues(alpha: 0.2);
        corTexto = Colors.blue.shade800;
        break;
      default:
        corFundo = Colors.grey.withValues(alpha: 0.2);
        corTexto = Colors.grey.shade800;
    }

    return Chip(
      label: Text(restricao),
      backgroundColor: corFundo,
      labelStyle: TextStyle(fontSize: 11, color: corTexto),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

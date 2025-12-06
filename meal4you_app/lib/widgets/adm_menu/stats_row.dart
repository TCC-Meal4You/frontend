import 'package:flutter/material.dart';
import 'package:meal4you_app/widgets/adm_menu/stat_card.dart';

class StatsRow extends StatelessWidget {
  final int totalRefeicoes;
  final int refeicoesDisponiveis;
  final int refeicoesIndisponiveis;

  const StatsRow({
    super.key,
    required this.totalRefeicoes,
    required this.refeicoesDisponiveis,
    required this.refeicoesIndisponiveis,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StatCard(
          title: 'Total de Pratos',
          value: totalRefeicoes.toString(),
          color: Colors.purple,
        ),
        StatCard(
          title: 'Disponíveis',
          value: refeicoesDisponiveis.toString(),
          color: Colors.green,
        ),
        StatCard(
          title: 'Indisponíveis',
          value: refeicoesIndisponiveis.toString(),
          color: Colors.red,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meal4you_app/widgets/profile/client_profile_counter/client_profile_counter.dart';

class ClientProfileStatsRow extends StatelessWidget {
  final int numRestricoes;
  final int numFavoritos;
  final int numAvaliacoes;

  const ClientProfileStatsRow({
    super.key,
    required this.numRestricoes,
    required this.numFavoritos,
    required this.numAvaliacoes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ClientProfileCounter(title: 'Restricoes', count: numRestricoes),
        ClientProfileCounter(title: 'Favoritos', count: numFavoritos),
        ClientProfileCounter(title: 'Avaliacoes', count: numAvaliacoes),
      ],
    );
  }
}

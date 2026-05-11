import 'package:flutter/material.dart';
import 'package:meal4you_app/widgets/profile/client_profile_counter/client_profile_counter.dart';

class ClientProfileStatsRow extends StatelessWidget {
  final int numRestricoes;
  final int numFavoritos;
  final int numAvaliacoes;
  final bool isLoading;
  const ClientProfileStatsRow({
    super.key,
    required this.numRestricoes,
    required this.numFavoritos,
    required this.numAvaliacoes,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ClientProfileCounter(
          title: 'Restricoes',
          count: numRestricoes,
          isLoading: isLoading,
        ),
        ClientProfileCounter(
          title: 'Favoritos',
          count: numFavoritos,
          isLoading: isLoading,
        ),
        ClientProfileCounter(
          title: 'Avaliacoes',
          count: numAvaliacoes,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

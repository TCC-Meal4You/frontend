import 'package:flutter/material.dart';
import 'package:meal4you_app/screens/descricoes_cliente_adm/descricoes_cliente_adm.dart';

void main() {
  runApp(const Meal4You());
}

class Meal4You extends StatelessWidget {
  const Meal4You({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal4You',
      theme: ThemeData.dark().copyWith(),
      debugShowCheckedModeBanner: false,
      home: const DescricaoCliente(),
    );
  }
}

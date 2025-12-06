import 'package:flutter/material.dart';

class IngredientEmptyState extends StatelessWidget {
  const IngredientEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Nenhum ingrediente cadastrado',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "+" para criar seu primeiro ingrediente',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

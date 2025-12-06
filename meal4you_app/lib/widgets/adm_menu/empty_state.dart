import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Nenhum prato cadastrado ainda',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "+" para criar seu primeiro prato',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class IngredientEmptyState extends StatelessWidget {
  const IngredientEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  // ignore: deprecated_member_use
                  const Color(0xFF0FE687).withOpacity(0.1),
                  // ignore: deprecated_member_use
                  const Color(0xFF0FE687).withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                // ignore: deprecated_member_use
                color: const Color(0xFF0FE687).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.restaurant,
              size: 80,
              color: Color(0xFF0FE687),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum ingrediente cadastrado',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Toque no botão "+" para adicionar seu primeiro ingrediente',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

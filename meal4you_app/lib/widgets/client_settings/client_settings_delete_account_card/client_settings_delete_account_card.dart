import 'package:flutter/material.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_base_card/client_settings_base_card.dart';

class ClientSettingsDeleteAccountCard extends StatelessWidget {
  final VoidCallback onDelete;

  const ClientSettingsDeleteAccountCard({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ClientSettingsBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.delete_outline, color: Color(0xFFF04438), size: 20),
              SizedBox(width: 8),
              Text(
                'Deletar Conta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Deletar sua conta irá remover permanentemente todos os seus dados, incluindo favoritos e avaliações.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF04438),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Colors.red, width: 1.5),
              ),
              icon: const Icon(Icons.delete_forever_outlined),
              label: const Text(
                'Deletar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

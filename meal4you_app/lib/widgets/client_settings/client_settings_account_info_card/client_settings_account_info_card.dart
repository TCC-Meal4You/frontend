import 'package:flutter/material.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_base_card/client_settings_base_card.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_info_label/client_settings_info_label.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_section_header/client_settings_section_header.dart';

class ClientSettingsAccountInfoCard extends StatelessWidget {
  const ClientSettingsAccountInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClientSettingsBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClientSettingsSectionHeader(
            icon: Icons.account_circle_outlined,
            iconColor: Color(0xFF9D00FF),
            title: 'Informações da Conta',
          ),
          SizedBox(height: 18),
          ClientSettingsInfoLabel(text: 'Tipo de Conta'),
          SizedBox(height: 4),
          Text(
            'Cliente',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

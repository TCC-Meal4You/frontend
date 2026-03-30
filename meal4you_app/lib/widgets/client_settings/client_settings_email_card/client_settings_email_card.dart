import 'package:flutter/material.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_base_card/client_settings_base_card.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_section_header/client_settings_section_header.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_social_login_info_box/client_settings_social_login_info_box.dart';

class ClientSettingsEmailCard extends StatelessWidget {
  final bool isLoading;
  final String email;
  final bool isSocialLogin;

  const ClientSettingsEmailCard({
    super.key,
    required this.isLoading,
    required this.email,
    required this.isSocialLogin,
  });

  @override
  Widget build(BuildContext context) {
    return ClientSettingsBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ClientSettingsSectionHeader(
            icon: Icons.mail_outline,
            iconColor: Color(0xFF17C783),
            title: 'Email',
            actionLabel: 'Alterar',
          ),
          const SizedBox(height: 12),
          Text(
            isLoading ? 'Carregando...' : email,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          if (isSocialLogin) ...[
            const SizedBox(height: 8),
            const ClientSettingsSocialLoginInfoBox(
              message:
                  'Você entrou com o Google. Não é possível alterar o e-mail.',
            ),
          ],
        ],
      ),
    );
  }
}

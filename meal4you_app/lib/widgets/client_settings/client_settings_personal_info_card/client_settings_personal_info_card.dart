import 'package:flutter/material.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_base_card/client_settings_base_card.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_info_label/client_settings_info_label.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_section_header/client_settings_section_header.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_social_login_info_box/client_settings_social_login_info_box.dart';

class ClientSettingsPersonalInfoCard extends StatelessWidget {
  final bool isLoading;
  final String nome;
  final bool isSocialLogin;
  final String passwordText;
  final bool isPasswordVisible;
  final bool hasPassword;
  final VoidCallback onTogglePassword;

  const ClientSettingsPersonalInfoCard({
    super.key,
    required this.isLoading,
    required this.nome,
    required this.isSocialLogin,
    required this.passwordText,
    required this.isPasswordVisible,
    required this.hasPassword,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return ClientSettingsBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ClientSettingsSectionHeader(
            icon: Icons.person_outline,
            iconColor: Color(0xFF17C783),
            title: 'Informações Pessoais',
            actionLabel: 'Editar',
          ),
          const SizedBox(height: 20),
          const ClientSettingsInfoLabel(text: 'Nome'),
          const SizedBox(height: 8),
          Text(
            isLoading ? 'Carregando...' : nome,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          const ClientSettingsInfoLabel(text: 'Senha'),
          const SizedBox(height: 8),
          if (isSocialLogin)
            const ClientSettingsSocialLoginInfoBox(
              message:
                  'Você entrou com o Google. Não é possível alterar a senha.',
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isLoading ? 'Carregando...' : passwordText,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
                IconButton(
                  onPressed: hasPassword ? onTogglePassword : null,
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

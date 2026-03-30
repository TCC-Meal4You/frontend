import 'package:flutter/material.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_base_card/client_settings_base_card.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_info_label/client_settings_info_label.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_section_header/client_settings_section_header.dart';
import 'package:meal4you_app/widgets/client_settings/client_settings_social_login_info_box/client_settings_social_login_info_box.dart';

class ClientSettingsPersonalInfoCard extends StatelessWidget {
  final bool isLoading;
  final String nome;
  final bool isSocialLogin;
  final bool isEditing;
  final bool isSaving;
  final String passwordText;
  final bool isPasswordVisible;
  final bool hasPassword;
  final bool obscurePasswordField;
  final TextEditingController nomeController;
  final TextEditingController senhaController;
  final VoidCallback onEditTap;
  final VoidCallback onTogglePassword;
  final VoidCallback onTogglePasswordField;
  final VoidCallback onSaveChanges;

  const ClientSettingsPersonalInfoCard({
    super.key,
    required this.isLoading,
    required this.nome,
    required this.isSocialLogin,
    required this.isEditing,
    required this.isSaving,
    required this.passwordText,
    required this.isPasswordVisible,
    required this.hasPassword,
    required this.obscurePasswordField,
    required this.nomeController,
    required this.senhaController,
    required this.onEditTap,
    required this.onTogglePassword,
    required this.onTogglePasswordField,
    required this.onSaveChanges,
  });

  @override
  Widget build(BuildContext context) {
    return ClientSettingsBaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClientSettingsSectionHeader(
            icon: Icons.person_outline,
            iconColor: const Color(0xFF17C783),
            title: 'Informações Pessoais',
            actionLabel: isEditing ? 'Cancelar' : 'Editar',
            actionIcon: isEditing ? Icons.close : Icons.edit_outlined,
            onActionTap: onEditTap,
          ),
          const SizedBox(height: 20),
          const ClientSettingsInfoLabel(text: 'Nome'),
          const SizedBox(height: 8),
          if (isEditing)
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                hintText: 'Digite seu nome',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 157, 0, 255),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            )
          else
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
          else if (isEditing)
            TextField(
              controller: senhaController,
              obscureText: obscurePasswordField,
              decoration: InputDecoration(
                hintText: 'Digite a nova senha',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 157, 0, 255),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePasswordField
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: onTogglePasswordField,
                ),
              ),
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
          if (isEditing) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onSaveChanges,
                icon: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  isSaving ? 'Salvando...' : 'Salvar Alterações',
                  style: const TextStyle(fontSize: 17),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 15, 230, 135),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

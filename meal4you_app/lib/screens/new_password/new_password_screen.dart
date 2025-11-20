import 'package:flutter/material.dart';
import 'package:meal4you_app/screens/confirm_password_code/confirm_password_code_screen.dart';
import 'package:meal4you_app/providers/password_reset/password_reset_provider.dart';
import 'package:provider/provider.dart';

class NewPasswordScreen extends StatefulWidget {
  final bool isAdm;

  const NewPasswordScreen({super.key, required this.isAdm});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<PasswordResetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Nova Senha")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Digite a nova senha:"),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Nova senha"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                flow.saveNewPassword(passwordController.text.trim());

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ConfirmPasswordCodeScreen(isAdm: widget.isAdm),
                  ),
                );
              },
              child: const Text("Confirmar senha"),
            ),
          ],
        ),
      ),
    );
  }
}

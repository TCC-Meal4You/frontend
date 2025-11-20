import 'package:flutter/material.dart';
import 'package:meal4you_app/screens/new_password/new_password_screen.dart';
import 'package:meal4you_app/services/password_reset_flow/password_reset_flow_service.dart';
import 'package:provider/provider.dart';

class SendPasswordCodeScreen extends StatefulWidget {
  final bool isAdm;

  const SendPasswordCodeScreen({super.key, required this.isAdm});

  @override
  State<SendPasswordCodeScreen> createState() => _SendPasswordCodeScreenState();
}

class _SendPasswordCodeScreenState extends State<SendPasswordCodeScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<PasswordResetFlowService>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Redefinir Senha")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text("Digite o e-mail para redefinir sua senha:"),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "E-mail"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  flow.saveEmail(emailController.text.trim());

                  bool ok = await flow.sendCode(widget.isAdm);

                  if (ok) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewPasswordScreen(isAdm: widget.isAdm),
                      ),
                    );
                  }
                },
                child: const Text("Enviar código"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meal4you_app/services/password_reset_flow/password_reset_flow_service.dart';
import 'package:provider/provider.dart';

class ConfirmPasswordCodeScreen extends StatefulWidget {
  final bool isAdm;

  const ConfirmPasswordCodeScreen({super.key, required this.isAdm});

  @override
  State<ConfirmPasswordCodeScreen> createState() => _ConfirmPasswordCodeScreenState();
}

class _ConfirmPasswordCodeScreenState extends State<ConfirmPasswordCodeScreen> {
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<PasswordResetFlowService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Confirmar Código")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Digite o código que enviamos:"),
            const SizedBox(height: 12),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: "Código"),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                bool ok = await flow.confirmResetCode(
                  codeController.text,
                  widget.isAdm,
                );

                if (ok) {
                  Navigator.pushReplacementNamed(
                    context,
                    widget.isAdm ? "/admLogin" : "/clientLogin",
                  );
                }
              },
              child: const Text("Confirmar"),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                flow.sendCode(widget.isAdm);
              },
              child: const Text("Reenviar código"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meal4you_app/providers/password_reset/password_reset_provider.dart';
import 'package:provider/provider.dart';

class ConfirmPasswordCodeScreen extends StatefulWidget {
  final bool isAdm;

  const ConfirmPasswordCodeScreen({super.key, required this.isAdm});

  @override
  State<ConfirmPasswordCodeScreen> createState() =>
      _ConfirmPasswordCodeScreenState();
}

class _ConfirmPasswordCodeScreenState extends State<ConfirmPasswordCodeScreen> {
  final TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<PasswordResetProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Código de verificação",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF7B3AED),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    "Digite o código enviado ao seu e-mail.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: codeController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: "Código",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool ok = await flow.confirmResetCode(
                          codeController.text.trim(),
                          widget.isAdm,
                        );

                        if (ok) {
                          Navigator.pushReplacementNamed(
                            context,
                            widget.isAdm ? "/admLogin" : "/clientLogin",
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF7B3AED),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Confirmar",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        flow.sendCode(widget.isAdm);
                      },
                      child: const Text(
                        "Reenviar código",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF7B3AED),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
  bool isLoading = false;

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
                    "Digite o código enviado ao seu e-mail para concluir a redefinição de senha.",
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
                      onPressed: isLoading
                          ? null
                          : () async {
                              String code = codeController.text.trim();
                              if (code.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "O código não pode estar vazio.",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() => isLoading = true);

                              bool ok = await flow.confirmResetCode(
                                code,
                                widget.isAdm,
                              );

                              setState(() => isLoading = false);

                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Senha alterada com sucesso!",
                                    ),
                                    backgroundColor: Color.fromARGB(255, 157, 0, 255),
                                  ),
                                );

                                await Future.delayed(
                                  const Duration(milliseconds: 400),
                                );

                                Navigator.pushReplacementNamed(
                                  context,
                                  widget.isAdm ? "/admLogin" : "/clientLogin",
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Código inválido. Tente novamente ou solicite um novo código.",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
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
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Código reenviado para o e-mail."),
                            backgroundColor: Color(0xFF7B3AED),
                          ),
                        );
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

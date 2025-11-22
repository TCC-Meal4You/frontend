import 'package:flutter/material.dart';
import 'package:meal4you_app/screens/new_password/new_password_screen.dart';
import 'package:meal4you_app/providers/password_reset/password_reset_provider.dart';
import 'package:provider/provider.dart';

class SendPasswordCodeScreen extends StatefulWidget {
  final bool isAdm;

  const SendPasswordCodeScreen({super.key, required this.isAdm});

  @override
  State<SendPasswordCodeScreen> createState() => _SendPasswordCodeScreenState();
}

class _SendPasswordCodeScreenState extends State<SendPasswordCodeScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false; // 🔥 controle de loading

  @override
  Widget build(BuildContext context) {
    final flow = Provider.of<PasswordResetProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                const Text(
                  "Redefinição de Senha",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7B3AED),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Digite o e-mail associado à sua conta. Enviaremos um código que servirá para confirmar a redefinição de sua senha.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),

                const SizedBox(height: 32),

                TextField(
                  controller: emailController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: "E-mail",
                    labelStyle: const TextStyle(color: Colors.black54),
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
                            String email = emailController.text.trim();

                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Digite um e-mail válido."),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            flow.saveEmail(email);
                            bool ok = await flow.sendCode(widget.isAdm);

                            setState(() => isLoading = false);

                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Código enviado com sucesso!"),
                                  backgroundColor: Color.fromARGB(255, 157, 0, 255),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      NewPasswordScreen(isAdm: widget.isAdm),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Este e-mail não está registrado.",
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B3AED),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Enviar código",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

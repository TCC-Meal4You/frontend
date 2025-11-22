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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                const Text(
                  "Definir nova senha",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7B3AED),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Sua nova senha deve ser forte e segura.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),

                const SizedBox(height: 30),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: "Nova senha",
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B3AED),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Continuar",
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

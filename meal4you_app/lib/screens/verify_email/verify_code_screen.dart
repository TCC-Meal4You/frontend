import 'package:flutter/material.dart';
import 'package:meal4you_app/services/email_verification/verify_email_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  final VerifyEmailService _verifyEmailService =
      VerifyEmailService(baseUrl: 'https://backend-production-7a83.up.railway.app');

  void _onCodeChanged(String value) {
    setState(() {
      _isButtonEnabled = value.length == 6;
    });
  }

  Future<void> _confirmCode() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('register_email')!;
      final nome = prefs.getString('register_nome')!;
      final senha = prefs.getString('register_senha')!;
      final isAdmin = prefs.getBool('register_isAdmin')!;

      final codigo = _codeController.text.trim();

      await _verifyEmailService.confirmCode(
        email: email,
        nome: nome,
        senha: senha,
        codigo: codigo,
        isAdmin: isAdmin,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      Navigator.pushReplacementNamed(
        context,
        isAdmin ? '/createAdmRestaurant' : '/restrictionsChoice',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Verificar Código"),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 15, 230, 135),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Digite o código de 6 dígitos enviado para seu e-mail:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _codeController,
                onChanged: _onCodeChanged,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "000000",
                  counterText: "",
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isButtonEnabled && !_isLoading ? _confirmCode : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled
                      ? const Color.fromARGB(255, 15, 230, 135)
                      : Colors.grey,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Continuar",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

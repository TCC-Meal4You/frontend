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
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  bool _isButtonEnabled = false;
  bool _isLoading = false;
  bool _isResendLoading = false;

  final VerifyEmailService _verifyEmailService = VerifyEmailService(
    baseUrl: 'https://backend-production-7a83.up.railway.app',
  );

  @override
  void dispose() {
    _codeController.dispose();
    for (var controller in _digitControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();

    _codeController.text = _digitControllers.map((e) => e.text).join();
    setState(() {
      _isButtonEnabled = _codeController.text.length == 6;
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResendLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('register_email')!;
      final isAdmin = prefs.getBool('register_isAdmin')!;

      await _verifyEmailService.sendVerificationCode(
        email: email,
        isAdmin: isAdmin,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código reenviado com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código inválido ou expirado. Detalhes: $e')),
      );
    } finally {
      if (mounted) setState(() => _isResendLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Verificação de E-mail',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7B3AED),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Digite o código enviado para o e-mail:',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              FutureBuilder<String?>(
                future: SharedPreferences.getInstance().then(
                  (prefs) => prefs.getString('register_email'),
                ),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.w400,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45,
                    height: 55,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextField(
                      controller: _digitControllers[index],
                      focusNode: _focusNodes[index],
                      onChanged: (value) => _onDigitChanged(index, value),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF7B3AED),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled && !_isLoading
                      ? _confirmCode
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B3AED),
                    disabledBackgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Autenticar",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: !_isResendLoading ? _resendCode : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 15, 230, 135),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: _isResendLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.black87,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Reenviar Código",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

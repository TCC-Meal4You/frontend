import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meal4you_app/services/email_verification/verify_email_service.dart';
import 'package:meal4you_app/services/login/adm_login_service.dart';
import 'package:meal4you_app/services/login/client_login_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meal4you_app/utils/formatter/paste_code_formatter.dart';

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
    baseUrl: 'https://backend-production-9aaf.up.railway.app',
  );

  @override
  void dispose() {
    _codeController.dispose();
    for (var c in _digitControllers) {
      c.dispose();
    }
    for (var n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _handlePastedCode(String fullCode) {
    for (int i = 0; i < 6; i++) {
      _digitControllers[i].text = fullCode[i];
    }

    _codeController.text = fullCode;

    FocusScope.of(context).unfocus();

    setState(() => _isButtonEnabled = true);
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) return;

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

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

      Map<String, dynamic> loginResponse;

      if (isAdmin) {
        loginResponse = await AdmLoginService.loginAdm(
          email: email,
          senha: senha,
        );
      } else {
        loginResponse = await ClientLoginService.loginClient(
          email: email,
          senha: senha,
        );
      }

      final token = loginResponse['token'] ?? loginResponse['accessToken'];
      if (token != null) {
        await UserTokenSaving.saveCurrentUserEmail(email);
        await UserTokenSaving.saveToken(token);
        await UserTokenSaving.saveUserPassword(senha);

        final userData = <String, dynamic>{
          ...Map<String, dynamic>.from(loginResponse),
          'email': email,
          'userType': isAdmin ? 'adm' : 'client',
          'isAdm': isAdmin,
        };
        await UserTokenSaving.saveUserData(userData);

        print('✅ REGISTRO - Email salvo: $email');
        print('✅ REGISTRO - Token salvo');
        print(
          '✅ REGISTRO - UserData salvo com userType: ${isAdmin ? "adm" : "client"}',
        );
        print('✅ REGISTRO - UserData completo: $userData');
      }

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
        const SnackBar(
          content: Text('Código reenviado com sucesso!'),
          backgroundColor: Color.fromARGB(255, 157, 0, 255),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao reenviar: $e')));
    } finally {
      if (mounted) setState(() => _isResendLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
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

                      onChanged: (v) => _onDigitChanged(index, v),

                      inputFormatters: [
                        PasteCodeFormatter(onCodeComplete: _handlePastedCode),
                        FilteringTextInputFormatter.digitsOnly,
                      ],

                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.1,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
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
                    backgroundColor: const Color.fromARGB(255, 15, 230, 135),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

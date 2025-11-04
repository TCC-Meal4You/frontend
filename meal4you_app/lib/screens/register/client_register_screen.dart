import 'package:flutter/material.dart';
import 'package:meal4you_app/controllers/textfield/register_controllers.dart';
import 'package:meal4you_app/models/user_type.dart';
import 'package:meal4you_app/services/email_verification/verify_email_service.dart';
import 'package:meal4you_app/widgets/client_register_forms_icon.dart';
import 'package:meal4you_app/widgets/custom_text_field.dart';
import 'package:meal4you_app/widgets/social_login_and_register.dart';
import 'package:meal4you_app/widgets/submit_button.dart';
import 'package:meal4you_app/widgets/login_redirect_text.dart';
import 'package:meal4you_app/widgets/or_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientRegisterScreen extends StatefulWidget {
  const ClientRegisterScreen({super.key});

  @override
  State<ClientRegisterScreen> createState() => _ClientRegisterScreenState();
}

class _ClientRegisterScreenState extends State<ClientRegisterScreen> {
  bool _isLoading = false;
  final VerifyEmailService _verifyEmailService = VerifyEmailService(
    baseUrl: 'https://backend-production-7a83.up.railway.app',
  );

  Future<void> _sendCode() async {
    if (RegisterControllers.senhaController.text !=
        RegisterControllers.confirmarSenhaController.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("As senhas não conferem!")));
      return;
    }

    setState(() => _isLoading = true);

    final email = RegisterControllers.emailController.text.trim();
    final nome = RegisterControllers.nomeController.text;
    final senha = RegisterControllers.senhaController.text.trim();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('register_email', email);
      await prefs.setString('register_nome', nome);
      await prefs.setString('register_senha', senha);
      await prefs.setBool('register_isAdmin', false);

      await _verifyEmailService.sendVerificationCode(
        email: email,
        isAdmin: false,
      );

      if (!mounted) return;
      Navigator.pushNamed(context, '/verifyCode');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao enviar código: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Stack(
              children: [
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 15, 230, 135),
                        Color.fromARGB(255, 157, 0, 255),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 120,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          RichText(
                            text: const TextSpan(
                              text: 'MEAL',
                              style: TextStyle(
                                fontSize: 50,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 4, 128, 73),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: '4',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 157, 0, 255),
                                  ),
                                ),
                                TextSpan(
                                  text: 'YOU',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'c  o  m  i  d  a    c  o  n  s  c  i  e  n  t  e',
                            style: TextStyle(
                              color: Color.fromARGB(255, 87, 86, 86),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 25),
                          const Text(
                            'CADASTRO',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),

                          const SocialLoginAndRegister(),
                          const SizedBox(height: 10),
                          const OrDivider(),

                          const SizedBox(height: 10),

                          CustomTextField(
                            controller: RegisterControllers.nomeController,
                            label: "Nome...",
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: RegisterControllers.emailController,
                            label: "Email...",
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: RegisterControllers.senhaController,
                            label: "Senha...",
                            obscure: true,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller:
                                RegisterControllers.confirmarSenhaController,
                            label: "Confirmar Senha...",
                            obscure: true,
                          ),

                          const SizedBox(height: 20),

                          SubmitButton(
                            isLoading: _isLoading,
                            onPressed: _sendCode,
                          ),

                          const SizedBox(height: 15),

                          const LoginRedirectText(userType: UserType.adm),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                const ClientRegisterFormsIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

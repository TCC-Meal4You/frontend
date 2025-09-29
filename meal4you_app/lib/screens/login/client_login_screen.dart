import 'package:flutter/material.dart';
import 'package:meal4you_app/controllers/login_controllers.dart';
import 'package:meal4you_app/screens/profile/client_profile_screen.dart';
import 'package:meal4you_app/services/login/client_login_service.dart';
import 'package:meal4you_app/widgets/custom_text_field.dart';
import 'package:meal4you_app/widgets/client_login_forms_icon.dart';
import 'package:meal4you_app/widgets/or_divider.dart';
import 'package:meal4you_app/widgets/register_redirect_text.dart';
import 'package:meal4you_app/widgets/social_buttons_row.dart';
import 'package:meal4you_app/widgets/submit_button.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  bool _isLoading = false;

  Future<void> _loginClient() async {
    final email = LoginControllers.emailController.text.trim();
    final senha = LoginControllers.senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Preencha email e senha")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ClientLoginService.loginClient(
        email: email,
        senha: senha,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login realizado: ${response['email'] ?? email}"),
        ),
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ClientProfileScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao logar: $e")));
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
                        Color.fromARGB(255, 157, 0, 255),
                        Color.fromARGB(255, 15, 230, 135),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 120),
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
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: LoginControllers.emailController,
                            label: "Email...",
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: LoginControllers.senhaController,
                            label: "Senha...",
                            obscure: true,
                          ),

                          const SizedBox(height: 25),

                          SubmitButton(
                            isLoading: _isLoading,
                            onPressed: _loginClient,
                            buttonText: "Logar",
                          ),

                          const SizedBox(height: 20),

                          const RegisterRedirectText(
                            registerUserType: RegisterUserType.client,
                          ),

                          const SizedBox(height: 20),

                          const OrDivider(),

                          const SizedBox(height: 10),

                          const SocialButtonsRow(),
                        ],
                      ),
                    ),
                  ],
                ),
                const ClientLoginFormsIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

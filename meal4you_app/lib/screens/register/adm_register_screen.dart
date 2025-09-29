import 'package:flutter/material.dart';
import 'package:meal4you_app/controllers/client_register_controllers.dart';
import 'package:meal4you_app/screens/profile/adm_profile_screen.dart';
import 'package:meal4you_app/services/register/adm_register_service.dart';
import 'package:meal4you_app/widgets/adm_register_forms_icon.dart';
import 'package:meal4you_app/widgets/custom_text_field.dart';
import 'package:meal4you_app/widgets/login_redirect_text.dart';
import 'package:meal4you_app/widgets/or_divider.dart';
import 'package:meal4you_app/widgets/social_buttons_row.dart';
import 'package:meal4you_app/widgets/submit_button.dart';

class AdmRegisterScreen extends StatefulWidget {
  const AdmRegisterScreen({super.key});

  @override
  State<AdmRegisterScreen> createState() => _AdmRegisterScreenState();
}

class _AdmRegisterScreenState extends State<AdmRegisterScreen> {
  bool _isLoading = false;

  Future<void> _registerAdm() async {
    if (RegisterControllers.senhaController.text !=
        RegisterControllers.confirmarSenhaController.text) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("As senhas não conferem!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AdmRegisterService.registerAdm(
        nome: RegisterControllers.nomeController.text,
        email: RegisterControllers.emailController.text,
        senha: RegisterControllers.senhaController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cadastro realizado: ${response['email']}")),
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdmProfileScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro ao cadastrar: $e")));
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
                          const SizedBox(height: 5),

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
                            onPressed: _registerAdm,
                          ),

                          const SizedBox(height: 20),

                          const LoginRedirectText(userType: UserType.adm),

                          const SizedBox(height: 20),

                          const OrDivider(),

                          const SizedBox(height: 10),

                          const SocialButtonsRow(),
                        ],
                      ),
                    ),
                  ],
                ),
                const AdmRegisterFormsIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

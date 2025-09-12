import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal4you_app/screens/register/register_screen.dart';
import 'package:meal4you_app/widgets/forms_icon_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                          SizedBox(
                            height: 60,
                            width: 350,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Email...',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 60,
                            width: 350,
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Senha...',
                                fillColor: Colors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                4,
                                128,
                                73,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              fixedSize: const Size(350, 50),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'Entrar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          RichText(
                            text: TextSpan(
                              text: 'Ainda não possui uma conta? ',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Cadastrar',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 157, 0, 255),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  thickness: 2,
                                  color: Colors.black,
                                  indent: 40,
                                  endIndent: 0,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),

                                child: const Text(
                                  'OU',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  thickness: 2,
                                  color: Colors.black,
                                  indent: 0,
                                  endIndent: 40,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.google,
                                  color: Colors.red,
                                  size: 32,
                                ),
                                onPressed: null,
                              ),
                              IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.facebook,
                                  color: Colors.blue,
                                  size: 32,
                                ),
                                onPressed: null,
                              ),
                              IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.microsoft,
                                  color: Colors.green,
                                  size: 32,
                                ),
                                onPressed: null,
                              ),
                              IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.apple,
                                  color: Colors.black,
                                  size: 32,
                                ),
                                onPressed: null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const FormsIconClient(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
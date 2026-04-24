import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal4you_app/controllers/logout_handlers/client_logout_handler.dart';
import 'package:meal4you_app/services/user_restriction/user_restriction_service.dart';
import 'package:meal4you_app/widgets/navigation/client_bottom_navigation_bar.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final ClientLogoutHandler _clientlogoutHandler = ClientLogoutHandler();
  List<String> _restricoes = [];
  bool _loadingRestricoes = true;

  @override
  void initState() {
    super.initState();
    _carregarRestricoes();
  }

  Future<void> _carregarRestricoes() async {
    try {
      final nomesRestricoes = await UserRestrictionService.buscarRestricoes();

      if (!mounted) return;
      setState(() {
        _restricoes = nomesRestricoes.isNotEmpty
            ? nomesRestricoes
            : ['Nenhuma restrição'];
        _loadingRestricoes = false;
      });
    } catch (e) {
      print('Erro ao carregar restrições: $e');
      if (!mounted) return;
      setState(() {
        _restricoes = ['Erro ao carregar'];
        _loadingRestricoes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFFCF9FF),
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 157, 0, 255),
                        Color.fromARGB(255, 15, 230, 135),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'MEAL4YOU',
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 27,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'c  o  m  i  d  a    c  o  n  s  c  i  e  n  t  e',
                                  style: TextStyle(
                                    fontFamily: 'Ubuntu',
                                    fontSize: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () => _clientlogoutHandler
                                  .showLogoutDialog(context),
                              icon: const FaIcon(
                                FontAwesomeIcons.rightFromBracket,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Bem-vindo!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _loadingRestricoes
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Column(
                              children: [
                                const Text(
                                  'Buscando opções para:',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    fontFamily: 'Ubuntu',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _restricoes.join(', '),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Ubuntu',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const ClientBottomNavigationBar(
            currentIndex: 0,
          ),
        ),
      ),
    );
  }
}

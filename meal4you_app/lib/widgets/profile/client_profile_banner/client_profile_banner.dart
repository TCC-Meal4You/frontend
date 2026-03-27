import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClientProfileBanner extends StatelessWidget {
  final bool isLoading;
  final String initial;
  final String emailText;
  final VoidCallback onLogout;

  const ClientProfileBanner({
    super.key,
    required this.isLoading,
    required this.initial,
    required this.emailText,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  onPressed: onLogout,
                  icon: const FaIcon(
                    FontAwesomeIcons.rightFromBracket,
                    color: Colors.white,
                  ),
                  tooltip: 'Sair',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.3),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.3,
                      ),
                    )
                  : Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Ubuntu',
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Meu Perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Ubuntu',
            ),
          ),
          Text(
            emailText,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontFamily: 'Ubuntu',
            ),
          ),
        ],
      ),
    );
  }
}

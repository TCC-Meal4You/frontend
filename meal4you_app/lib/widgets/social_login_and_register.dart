import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLoginAndRegister extends StatelessWidget {
  const SocialLoginAndRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 55,
          width: 340,
          child: ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                // ignore: deprecated_member_use
                side: BorderSide(
                  // ignore: deprecated_member_use
                  color: Colors.red.withOpacity(0.5),
                ),
              ),
              elevation: 1,
            ),
            icon: FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 32),
            label: Text(
              'Entrar com Google',
              style: TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

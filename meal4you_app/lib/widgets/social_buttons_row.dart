import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialButtonsRow extends StatelessWidget {
  const SocialButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        IconButton(
          icon: FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 32),
          onPressed: null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue, size: 32),
          onPressed: null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.microsoft, color: Colors.green, size: 32),
          onPressed: null,
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.apple, color: Colors.black, size: 32),
          onPressed: null,
        ),
      ],
    );
  }
}

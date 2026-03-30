import 'package:flutter/material.dart';

class ClientSettingsInfoLabel extends StatelessWidget {
  final String text;

  const ClientSettingsInfoLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

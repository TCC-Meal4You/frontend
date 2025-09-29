import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String? buttonText;
  final Color? buttonColor;

  const SubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.buttonText,
    this.buttonColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = buttonColor ?? const Color.fromARGB(255, 157, 0, 255);
    final String text = buttonText ?? 'Cadastrar';

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        fixedSize: const Size(350, 50),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
    );
  }
}

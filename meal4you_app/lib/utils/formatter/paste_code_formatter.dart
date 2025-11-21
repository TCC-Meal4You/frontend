import 'package:flutter/services.dart';

class PasteCodeFormatter extends TextInputFormatter {
  final void Function(String) onCodeComplete;

  PasteCodeFormatter({required this.onCodeComplete});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > 1) {
      final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

      if (digits.length == 6) {
        onCodeComplete(digits);

        return TextEditingValue(
          text: digits,
          selection: TextSelection.collapsed(offset: digits.length),
        );
      }

      return oldValue;
    }

    return newValue;
  }
}

import 'package:flutter/material.dart';
import 'package:meal4you_app/services/password_reset/reset_password_service.dart';

class PasswordResetProvider extends ChangeNotifier {
  String? email;
  String? newPassword;

  final ResetPasswordService resetService = ResetPasswordService();

  void saveEmail(String value) {
    email = value;
    notifyListeners();
  }

  void saveNewPassword(String value) {
    newPassword = value;
    notifyListeners();
  }

  Future<bool> sendCode(bool isAdm) async {
    if (email == null) return false;

    return await resetService.sendResetCode(email!, isAdm);
  }

  Future<bool> confirmResetCode(String code, bool isAdm) async {
    if (email == null || newPassword == null) return false;

    return await resetService.confirmResetPassword(
      email: email!,
      newPassword: newPassword!,
      code: code,
      isAdm: isAdm,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meal4you_app/widgets/navigation/profile_choice_back_button.dart';

class AdmRegisterFormsIcon extends StatelessWidget {
  const AdmRegisterFormsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      left: 0,
      right: 0,
      child: Center(child: const ProfileChoiceBackButton()),
    );
  }
}

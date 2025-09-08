import 'package:flutter/material.dart';

class FormsIcon extends StatelessWidget {
  const FormsIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 8),
            ],
          ),
          child: const Icon(
            Icons.fastfood,
            size: 40,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ClientSettingsSectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? actionLabel;

  const ClientSettingsSectionHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222222),
            ),
          ),
        ),
        if (actionLabel != null)
          Row(
            children: [
              const Icon(
                Icons.edit_outlined,
                size: 16,
                color: Color(0xFF222222),
              ),
              const SizedBox(width: 6),
              Text(
                actionLabel!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

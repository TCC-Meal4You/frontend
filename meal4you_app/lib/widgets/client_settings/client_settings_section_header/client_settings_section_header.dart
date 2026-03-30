import 'package:flutter/material.dart';

class ClientSettingsSectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;

  const ClientSettingsSectionHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.actionLabel,
    this.actionIcon,
    this.onActionTap,
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
          TextButton.icon(
            onPressed: onActionTap,
            icon: Icon(
              actionIcon ?? Icons.edit_outlined,
              size: 18,
              color: const Color(0xFF222222),
            ),
            label: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }
}

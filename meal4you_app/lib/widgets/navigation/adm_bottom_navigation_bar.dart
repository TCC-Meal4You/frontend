import 'package:flutter/material.dart';

class AdmBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const AdmBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF0FE687),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.store_mall_directory_outlined),
          label: 'Restaurante',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Perfil',
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;

        final routeName = switch (index) {
          0 => '/admRestaurantHome',
          1 => '/admProfile',
          _ => null,
        };

        if (routeName == null) return;
        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }
}

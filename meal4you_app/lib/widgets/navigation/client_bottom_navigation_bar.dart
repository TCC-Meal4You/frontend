import 'package:flutter/material.dart';

class ClientBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const ClientBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color.fromARGB(255, 157, 0, 255),
      unselectedItemColor: const Color(0xFF475467),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Buscar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Favoritos',
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
          0 => '/clientHome',
          1 => '/searchRestaurantAndDish',
          2 => '/clientFavorites',
          3 => '/clientProfile',
          _ => null,
        };

        if (routeName == null) return;
        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }
}

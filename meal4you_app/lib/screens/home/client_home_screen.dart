import 'package:flutter/material.dart';
import 'package:meal4you_app/screens/search_restaurant_and_dish/search_restaurant_and_dish_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home do Cliente'),
      ),
      body: const Center(
        child: Text('Bem-vindo à Home do Cliente!'),
      ),
       bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: const Color.fromARGB(255, 157, 0, 255),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Buscar',
              ),
            ],
            currentIndex: 0,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/searchRestaurantAndDish');
              } else if (index == 1) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return const SearchRestaurantAndDishScreen();
                    },
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                  ),
                );
              }
            },
          ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal4you_app/controllers/logout_handlers/adm_logout_handler.dart';
import 'package:meal4you_app/providers/restaurant/restaurant_provider.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/widgets/restaurant_management_buttons/restaurant_management_buttons.dart';
import 'package:provider/provider.dart';

class AdmRestaurantHomeScreen extends StatefulWidget {
  const AdmRestaurantHomeScreen({super.key});

  @override
  State<AdmRestaurantHomeScreen> createState() =>
      _AdmRestaurantHomeScreenState();
}

class _AdmRestaurantHomeScreenState extends State<AdmRestaurantHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    final email = await UserTokenSaving.getUserEmail();
    if (email == null) return;

    final restaurantData = await UserTokenSaving.getRestaurantDataForUser(
      email,
    );

    if (restaurantData != null && mounted) {
      final provider = Provider.of<RestaurantProvider>(context, listen: false);

      provider.updateRestaurant(
        id: restaurantData['id'] ?? 0,
        name: restaurantData['nome'] ?? '',
        description: restaurantData['descricao'] ?? '',
        isActive: restaurantData['ativo'] ?? false,
        foodTypes: (restaurantData['tipoComida'] != null)
            ? restaurantData['tipoComida']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
            : [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final admLogoutHandler = AdmLogoutHandler();
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    final String name = restaurantProvider.name.isNotEmpty
        ? restaurantProvider.name
        : 'Sem nome';
    final String description = restaurantProvider.description.isNotEmpty
        ? restaurantProvider.description
        : 'Sem descrição';
    final List<String> foodTypes = restaurantProvider.foodTypes.isNotEmpty
        ? restaurantProvider.foodTypes
        : [];

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9FF),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 190,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 157, 0, 255),
                      Color.fromARGB(255, 15, 230, 135),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'MEAL4YOU',
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 27,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'c  o  m  i  d  a    c  o  n  s  c  i  e  n  t  e',
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () =>
                                admLogoutHandler.showLogoutDialog(context),
                            icon: const FaIcon(
                              FontAwesomeIcons.rightFromBracket,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Painel do Restaurante',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontFamily: 'Ubuntu',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Ubuntu',
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.info_outline,
                                color: Colors.deepPurple,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Informações do Restaurante',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tipos de Comida',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: -4,
                            children: foodTypes.isEmpty
                                ? const [
                                    Text(
                                      'Nenhum tipo selecionado',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ]
                                : foodTypes
                                      .map(
                                        (type) => Chip(
                                          label: Text(type),
                                          backgroundColor: Colors.grey.shade200,
                                          labelStyle: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      )
                                      .toList(),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            description,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gerenciar Restaurante',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RestaurantManagementButtons(
                      icon: Icons.restaurant_menu_outlined,
                      // ignore: deprecated_member_use
                      color: Colors.purpleAccent.withOpacity(0.15),
                      iconColor: Colors.purple,
                      title: 'Gerenciar Cardápio',
                      onTap: () {
                        Navigator.pushNamed(context, '/admMenu');
                      },
                    ),
                    RestaurantManagementButtons(
                      icon: Icons.eco_outlined,
                      // ignore: deprecated_member_use
                      color: Colors.greenAccent.withOpacity(0.15),
                      iconColor: Colors.green,
                      title: 'Gerenciar Ingredientes',
                      onTap: () {},
                    ),
                    RestaurantManagementButtons(
                      icon: Icons.chat_bubble_outline,
                      // ignore: deprecated_member_use
                      color: Color.fromARGB(255, 255, 170, 0).withOpacity(0.15),
                      iconColor: const Color.fromARGB(255, 255, 170, 0),
                      title: 'Avaliações e Comentários',
                      onTap: () {
                        Navigator.pushNamed(context, '/ratingsAndComments');
                      },
                    ),
                    RestaurantManagementButtons(
                      icon: Icons.settings_outlined,
                      // ignore: deprecated_member_use
                      color: Colors.blueAccent.withOpacity(0.15),
                      iconColor: Colors.blue,
                      title: 'Configurações',
                      onTap: () {
                        Navigator.pushNamed(context, '/restaurantSettings');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.store_mall_directory_outlined),
              label: 'Restaurante',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Meu Perfil',
            ),
          ],
          currentIndex: 0,
          onTap: (index) {},
        ),
      ),
    );
  }
}

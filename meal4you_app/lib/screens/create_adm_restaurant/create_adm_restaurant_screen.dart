import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal4you_app/controllers/logout_handlers/adm_logout_handler.dart';
import 'package:meal4you_app/providers/restaurant_provider.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/services/register_restaurant/register_restaurant_service.dart';
import 'package:provider/provider.dart';

class CreateAdmRestaurantScreen extends StatefulWidget {
  const CreateAdmRestaurantScreen({super.key});

  @override
  State<CreateAdmRestaurantScreen> createState() =>
      _CreateAdmRestaurantScreenState();
}

class _CreateAdmRestaurantScreenState extends State<CreateAdmRestaurantScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  bool _isActive = false;

  final Map<String, bool> _foodTypes = {
    "Brasileira": false,
    "Italiana": false,
    "Japonesa": false,
    "Mexicana": false,
    "Indiana": false,
    "Árabe": false,
    "Francesa": false,
    "Vegetariana": false,
    "Vegana": false,
    "Hambúrguer": false,
    "Pizza": false,
    "Sushi": false,
    "Churrasco": false,
    "Frutos do Mar": false,
    "Comida Saudável": false,
    "Fast Food": false,
    "Doces e Sobremesas": false,
    "Lanches": false,
    "Cafeteria": false,
  };

  @override
  void initState() {
    super.initState();
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    nameController = TextEditingController(text: restaurantProvider.name);
    descriptionController = TextEditingController(
      text: restaurantProvider.description,
    );
    _isActive = restaurantProvider.isActive;

    for (var food in restaurantProvider.foodTypes) {
      if (_foodTypes.containsKey(food)) {
        _foodTypes[food] = true;
      }
    }
  }

  void resetForm() {
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    restaurantProvider.resetRestaurant();

    nameController.clear();
    descriptionController.clear();
    _isActive = false;

    for (var key in _foodTypes.keys) {
      _foodTypes[key] = false;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final admLogoutHandler = AdmLogoutHandler();

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              Container(
                height: 190,
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
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
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
                      'Configuração inicial',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Crie seu Restaurante',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Configure as informações básicas do seu restaurante',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: 350,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 217, 217, 217),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          color: Color.fromARGB(255, 15, 230, 135),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Informações do Restaurante",
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Nome do Restaurante *",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameController,
                      onChanged: (value) =>
                          restaurantProvider.updateName(value),
                      decoration: InputDecoration(
                        hintText: "Ex: Cantinho da Vovó",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Descrição *",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: descriptionController,
                      onChanged: (value) =>
                          restaurantProvider.updateDescription(value),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            "Descreva seu restaurante, especialidades, ambiente...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text(
                        "Ativar visibilidade: seu restaurante ficará visível para todos os clientes.\nVocê pode alterar isso depois.",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      value: _isActive,
                      activeThumbColor: const Color.fromARGB(255, 15, 230, 135),
                      onChanged: (value) async {
                        bool activate = value;
                        if (value == true && !_isActive) {
                          final shouldActivate = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text(
                                "Atenção!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Ubuntu',
                                ),
                              ),
                              content: const Text(
                                "Se você ativar agora, seu restaurante ficará visível "
                                "para os clientes, mesmo sem pratos, ingredientes ou cardápio configurado.",
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 14,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    "Cancelar",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 157, 0, 255),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      15,
                                      230,
                                      135,
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "Ativar mesmo assim",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                          activate = shouldActivate ?? false;
                        }

                        setState(() => _isActive = activate);
                        restaurantProvider.updateIsActive(_isActive);
                      },
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Tipos de Comida * (selecione pelo menos um)",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: -8,
                      children: _foodTypes.keys.map((food) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              checkColor: WidgetStateProperty.all(Colors.white),
                            ),
                          ),
                          child: SizedBox(
                            width: 145,
                            child: CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                food,
                                style: const TextStyle(fontSize: 13),
                              ),
                              value: _foodTypes[food],
                              onChanged: (value) {
                                setState(() {
                                  _foodTypes[food] = value ?? false;
                                });
                                final selected = _foodTypes.entries
                                    .where((e) => e.value)
                                    .map((e) => e.key)
                                    .toList();
                                restaurantProvider.updateFoodTypes(selected);
                              },
                              activeColor: const Color.fromARGB(
                                255,
                                15,
                                230,
                                135,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final selected = _foodTypes.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .toList();

                          if (nameController.text.isEmpty ||
                              descriptionController.text.isEmpty ||
                              selected.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Preencha todos os campos obrigatórios.",
                                ),
                              ),
                            );
                            return;
                          }

                          final token = await UserTokenSaving.getToken();
                          if (token == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Token não encontrado. Faça login novamente.",
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            final restaurantData =
                                await RegisterRestaurantService.registerRestaurant(
                                  name: nameController.text,
                                  description: descriptionController.text,
                                  isActive: _isActive,
                                  foodTypes: selected,
                                  token: token,
                                );

                            final newRestaurantId =
                                restaurantData['idRestaurante'] ??
                                restaurantData['id'];

                            restaurantProvider.updateRestaurant(
                              id: newRestaurantId,
                              name: nameController.text,
                              description: descriptionController.text,
                              isActive: _isActive,
                              foodTypes: selected,
                            );

                            await UserTokenSaving.saveRestaurantId(
                              newRestaurantId,
                            );
                            await UserTokenSaving.saveRestaurantDataForCurrentUser(
                              {
                                'idRestaurante': newRestaurantId,
                                'nome': nameController.text,
                                'descricao': descriptionController.text,
                                'ativo': _isActive,
                                'tipoComida': selected,
                              },
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Restaurante criado com sucesso!",
                                ),
                              ),
                            );

                            Navigator.pushNamed(context, '/admRestaurantHome');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Erro ao criar restaurante: $e"),
                              ),
                            );
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color.fromARGB(
                            255,
                            15,
                            230,
                            135,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Criar Restaurante",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'Após criar seu restaurante, você poderá adicionar pratos ao cardápio '
                  'e gerenciar ingredientes para atender às preferências dos clientes.',
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

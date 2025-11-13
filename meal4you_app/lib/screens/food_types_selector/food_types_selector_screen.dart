import 'package:flutter/material.dart';
import 'package:meal4you_app/providers/restaurant_provider.dart';
import 'package:meal4you_app/services/update_restaurant/update_restaurant_service.dart';
import 'package:provider/provider.dart';

class FoodTypeSelectorScreen extends StatefulWidget {
  final int restaurantId;
  const FoodTypeSelectorScreen({super.key, required this.restaurantId});

  @override
  State<FoodTypeSelectorScreen> createState() => _FoodTypeSelectorScreenState();
}

class _FoodTypeSelectorScreenState extends State<FoodTypeSelectorScreen> {
  final List<String> availableTypes = [
    "Brasileira",
    "Italiana",
    "Japonesa",
    "Mexicana",
    "Indiana",
    "Árabe",
    "Francesa",
    "Vegetariana",
    "Vegana",
    "Hambúrguer",
    "Pizza",
    "Sushi",
    "Churrasco",
    "Frutos do Mar",
    "Comida Saudável",
    "Fast Food",
    "Doces e Sobremesas",
    "Lanches",
    "Cafeteria",
  ];

  late List<String> selectedTypes;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    selectedTypes = List<String>.from(provider.foodTypes);
  }

  Future<void> _saveSelection() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    provider.updateFoodTypes(selectedTypes);

    try {
      await UpdateRestaurantService.updateRestaurant(provider: provider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tipos de comida atualizados com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Selecionar Tipos de Comida"),
          backgroundColor: const Color.fromARGB(255, 15, 230, 135),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView.builder(
          itemCount: availableTypes.length,
          itemBuilder: (context, index) {
            final type = availableTypes[index];
            final isSelected = selectedTypes.contains(type);

            return Column(
              children: [
                CheckboxListTile(
                  title: Text(type),
                  value: isSelected,
                  activeColor: const Color.fromARGB(255, 15, 230, 135),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedTypes.add(type);
                      } else {
                        selectedTypes.remove(type);
                      }
                    });
                  },
                ),
                if (index < availableTypes.length - 1)
                  const Divider(height: 1, color: Colors.grey, indent: 16, endIndent: 16),
              ],
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _saveSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 15, 230, 135),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Salvar",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

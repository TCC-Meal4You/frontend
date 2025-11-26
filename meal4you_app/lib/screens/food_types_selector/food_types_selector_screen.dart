import 'package:flutter/material.dart';
import 'package:meal4you_app/providers/restaurant/restaurant_provider.dart';
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
    final initiallySelected = List<String>.from(
      Provider.of<RestaurantProvider>(context, listen: false).foodTypes,
    );
    final availableToSelect = availableTypes
        .where((type) => !initiallySelected.contains(type))
        .toList();

    final newlyAdded = selectedTypes
        .where((type) => !initiallySelected.contains(type))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black87,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (newlyAdded.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Selecionados:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: newlyAdded.map((type) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 157, 0, 255),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.deepPurple.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                type,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedTypes.remove(type);
                                  });
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                  ],

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: availableToSelect.map((type) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTypes.add(type);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            type,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 15, 230, 135),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Salvar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

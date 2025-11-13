import 'package:flutter/material.dart';
import 'package:meal4you_app/providers/restaurant_provider.dart';
import 'package:meal4you_app/screens/food_types_selector/food_types_selector_screen.dart';
import 'package:meal4you_app/services/restaurant_delete/restaurant_delete_service.dart';
import 'package:meal4you_app/services/update_restaurant/update_restaurant_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:provider/provider.dart';

class RestaurantSettingsScreen extends StatefulWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  State<RestaurantSettingsScreen> createState() =>
      _RestaurantSettingsScreenState();
}

class _RestaurantSettingsScreenState extends State<RestaurantSettingsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);

    await Future.delayed(const Duration(milliseconds: 50));

    final restaurantData =
        await UserTokenSaving.getRestaurantDataForCurrentUser();

    if (restaurantData != null) {
      final id = restaurantData['idRestaurante'] ?? restaurantData['id'] ?? 0;
      print("🧾 [SettingsScreen] ID carregado do storage: $id");

      provider.updateRestaurant(
        id: id,
        name: restaurantData['nome'] ?? '',
        description: restaurantData['descricao'] ?? '',
        location: restaurantData['localizacao'] ?? '',
        isActive: restaurantData['ativo'] ?? false,
        foodTypes: restaurantData['tipoComida'] != null
            ? (restaurantData['tipoComida'] is List
                  ? List<String>.from(restaurantData['tipoComida'])
                  : restaurantData['tipoComida']
                        .toString()
                        .split(',')
                        .map((e) => e.trim())
                        .toList())
            : [],
      );

      nameController.text = provider.name;
      descriptionController.text = provider.description;
      locationController.text = provider.location;
    } else {
      print(
        "⚠️ [SettingsScreen] Nenhum dado de restaurante encontrado no storage.",
      );
    }
  }

  Future<void> _updateBasicInfo() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);

    try {
      await UpdateRestaurantService.updateRestaurant(provider: provider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Informações atualizadas com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _updateActiveStatus(bool newValue) async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    provider.updateIsActive(newValue);

    try {
      await UpdateRestaurantService.updateRestaurant(provider: provider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Status atualizado para ${newValue ? 'Ativo' : 'Inativo'}",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _openFoodTypeSelector() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          FoodTypeSelectorScreen(restaurantId: provider.id ?? 0),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RestaurantProvider>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          title: const Text(
            'Configurações do Restaurante',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Informações Básicas",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        onChanged: (value) => provider.updateName(value),
                        decoration: const InputDecoration(
                          labelText: "Nome do Restaurante *",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        onChanged: (value) => provider.updateDescription(value),
                        decoration: const InputDecoration(
                          labelText: "Descrição *",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        onChanged: (value) => provider.updateLocation(value),
                        decoration: const InputDecoration(
                          labelText: "Localização *",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _updateBasicInfo,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          "Salvar Alterações",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            15,
                            230,
                            135,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Card de status
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Status do Restaurante",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              "Visibilidade no App\nSeu restaurante está ativo e visível para clientes.",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Switch(
                            value: provider.isActive,
                            onChanged: _updateActiveStatus,
                            activeThumbColor: const Color.fromARGB(
                              255,
                              15,
                              230,
                              135,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tipos de Comida",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          provider.foodTypes.isNotEmpty
                              ? provider.foodTypes.join(", ")
                              : "Nenhum tipo de comida cadastrado",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _openFoodTypeSelector,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            15,
                            230,
                            135,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                        child: const Text(
                          "Alterar Tipos de Comida",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Deletar meu Restaurante",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Ao deletar seu restaurante, perderá todos os dados e informações relacionadas ao mesmo. Pense bem, pois não há como reverter essa decisão.",
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
  onPressed: () async {
    final provider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    final TextEditingController confirmationController =
        TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmação"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Digite o nome do restaurante para confirmar a exclusão:",
            ),
            const SizedBox(height: 8),
            TextField(controller: confirmationController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              "Deletar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await RestaurantDeleteService.deleteRestaurant(
          restaurantId: provider.id ?? 0,
          nomeConfirmacao: confirmationController.text.trim(),
        );

        await UserTokenSaving.clearRestaurantDataForCurrentUser();
        await UserTokenSaving.clearRestaurantId();

        provider.resetRestaurant();

        nameController.clear();
        descriptionController.clear();
        locationController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Restaurante deletado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/createAdmRestaurant',
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao deletar: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    padding: const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 16,
    ),
  ),
  child: const Text(
    "Deletar",
    style: TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.bold,
    ),
  ),
),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

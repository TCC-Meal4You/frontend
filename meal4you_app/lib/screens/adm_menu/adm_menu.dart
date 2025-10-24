import 'package:flutter/material.dart';

class AdmMenuScreen extends StatefulWidget {
  const AdmMenuScreen({super.key});

  @override
  State<AdmMenuScreen> createState() => _AdmMenuScreenState();
}

class _AdmMenuScreenState extends State<AdmMenuScreen> {
  List<Map<String, dynamic>> dishes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Gerenciar Cardápio',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushNamed(context, '/admRestaurantHome');
          },
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 15, 230, 135),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              // TODO: abrir tela de adicionar prato
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Adicionar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatsRow(),
            const SizedBox(height: 16),
            Expanded(
              child: dishes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: dishes.length,
                      itemBuilder: (context, index) {
                        final dish = dishes[index];
                        return _buildDishCard(dish, index);
                      },
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
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Total de Pratos', '5', Colors.purple),
        _buildStatCard('Disponíveis', '4', Colors.green),
        _buildStatCard('Indisponíveis', '1', Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishCard(Map<String, dynamic> dish, int index) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        dish['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dish['category'],
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.purple),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          dishes.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dish['description'],
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            Text(
              'R\$ ${dish['price'].toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (dish['tags'] as List<String>)
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: const TextStyle(fontSize: 12),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 4),
            Text(
              'Ingredientes: ${dish['ingredients'].join(', ')}',
              style: TextStyle(color: Colors.grey[800], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Disponível para pedidos'),
                Switch(
                  value: dish['available'],
                  onChanged: (value) {
                    setState(() {
                      dishes[index]['available'] = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Nenhum prato cadastrado ainda',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em “Adicionar” para criar seu primeiro prato',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

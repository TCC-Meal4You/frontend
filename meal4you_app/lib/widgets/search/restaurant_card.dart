import 'package:flutter/material.dart';
import 'package:meal4you_app/models/restaurante_response_dto.dart';
import 'package:meal4you_app/widgets/search/restriction_chip.dart';

class RestaurantCard extends StatelessWidget {
  final RestauranteResponseDTO restaurant;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final compatibilidade = _calcularCompatibilidade();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              if (compatibilidade != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      compatibilidade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      restaurant.favorito
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: restaurant.favorito
                          ? Colors.red
                          : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (restaurant.avaliacaoMedia != null)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            restaurant.avaliacaoMedia!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.tipoComida,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (restaurant.tempoEntrega != null) ...[
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.tempoEntrega!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                    if (restaurant.distancia != null) ...[
                      if (restaurant.tempoEntrega != null)
                        const SizedBox(width: 12),
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${restaurant.distancia!.toStringAsFixed(1)} km',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _buildRestrictionChips(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _calcularCompatibilidade() {
    return '100% compatível';
  }

  List<Widget> _buildRestrictionChips() {
    final tipos = restaurant.tipoComida
        .split(',')
        .map((e) => e.trim())
        .toList();
    return tipos.map((tipo) => RestrictionChip(label: tipo)).toList();
  }
}

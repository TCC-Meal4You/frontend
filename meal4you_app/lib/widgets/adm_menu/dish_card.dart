import 'package:flutter/material.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/widgets/adm_menu/restricao_chip.dart';

class DishCard extends StatefulWidget {
  final MealResponseDTO refeicao;
  final int index;
  final Function(MealResponseDTO) onEdit;
  final Future<bool> Function(int, VoidCallback) onDelete;
  final Function(int, bool) onToggleAvailability;

  const DishCard({
    super.key,
    required this.refeicao,
    required this.index,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  State<DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<DishCard> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    if (_isDeleting) return;

    try {
      final success = await widget.onDelete(widget.refeicao.idRefeicao, () {
        if (mounted) {
          setState(() => _isDeleting = true);
        }
      });

      if (!success && mounted) {
        setState(() => _isDeleting = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.refeicao.nome,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
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
                          widget.refeicao.tipo,
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
                      onPressed: () => widget.onEdit(widget.refeicao),
                    ),
                    _isDeleting
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _handleDelete,
                          ),
                  ],
                ),
              ],
            ),
            if (widget.refeicao.descricao != null &&
                widget.refeicao.descricao!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.refeicao.descricao!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              'R\$ ${widget.refeicao.preco.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.refeicao.ingredientes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.refeicao.ingredientes
                    .expand((ingrediente) => ingrediente.restricoes)
                    .toSet()
                    .map((restricao) => RestricaoChip(restricao: restricao))
                    .toList(),
              ),
              const SizedBox(height: 4),
              Text(
                'Ingredientes: ${widget.refeicao.ingredientes.map((i) => i.nome).join(', ')}',
                style: TextStyle(color: Colors.grey[800], fontSize: 13),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Disponível para pedidos'),
                Switch(
                  value: widget.refeicao.disponivel,
                  onChanged: (value) => widget.onToggleAvailability(
                    widget.refeicao.idRefeicao,
                    value,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

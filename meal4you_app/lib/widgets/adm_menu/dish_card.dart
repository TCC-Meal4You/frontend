import 'package:flutter/material.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/widgets/adm_menu/restriction_chip.dart';

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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.refeicao.nome,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.refeicao.tipo,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.refeicao.descricao != null &&
                          widget.refeicao.descricao!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            widget.refeicao.descricao!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF0FE687),
                          size: 22,
                        ),
                        onPressed: () => widget.onEdit(widget.refeicao),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _isDeleting
                        ? Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 22,
                              ),
                              onPressed: _handleDelete,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'R\$ ${widget.refeicao.preco.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0FE687),
              ),
            ),
            if (widget.refeicao.ingredientes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.refeicao.ingredientes
                    .expand((ingrediente) => ingrediente.restricoes)
                    .toSet()
                    .map((restriction) => RestrictionChip(restriction: restriction))
                    .toList(),
              ),
              const SizedBox(height: 8),
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
                  activeThumbColor: const Color(0xFF0FE687),
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

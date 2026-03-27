import 'package:flutter/material.dart';
import 'package:meal4you_app/models/restriction_response_dto.dart';
import 'package:meal4you_app/services/restriction/restriction_service.dart';
import 'package:meal4you_app/services/user_restriction/user_restriction_service.dart';

class ClientRestrictionsModal extends StatefulWidget {
  final List<String> restricoesAtuais;
  final VoidCallback onRestrictionsSaved;

  const ClientRestrictionsModal({
    super.key,
    required this.restricoesAtuais,
    required this.onRestrictionsSaved,
  });

  @override
  State<ClientRestrictionsModal> createState() =>
      _ClientRestrictionsModalState();
}

class _ClientRestrictionsModalState extends State<ClientRestrictionsModal> {
  List<RestrictionResponseDTO> _restricoesDisponiveis = [];
  Set<int> _restricoesSelecionadas = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _carregarRestricoes();
  }

  Future<void> _carregarRestricoes() async {
    try {
      final restricoes = await RestrictionService.listarRestricoes();

      if (!mounted) return;
      setState(() {
        _restricoesDisponiveis = restricoes;
        _restricoesSelecionadas = {
          for (final restricao in restricoes)
            if (widget.restricoesAtuais.contains(restricao.nome))
              restricao.idRestricao,
        };
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar restricoes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _salvarRestricoes() async {
    setState(() => _isSaving = true);
    try {
      await UserRestrictionService.atualizarRestricoes(
        _restricoesSelecionadas.toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Restricoes atualizadas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onRestrictionsSaved();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar restricoes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleRestricao(int idRestricao) {
    setState(() {
      if (_restricoesSelecionadas.contains(idRestricao)) {
        _restricoesSelecionadas.remove(idRestricao);
      } else {
        _restricoesSelecionadas.add(idRestricao);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Restricoes Alimentares',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _restricoesDisponiveis.isEmpty
                      ? const Center(
                          child: Text('Nenhuma restricao disponivel'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _restricoesDisponiveis.length,
                          itemBuilder: (context, index) {
                            final restricao = _restricoesDisponiveis[index];
                            final isSelected = _restricoesSelecionadas.contains(
                              restricao.idRestricao,
                            );

                            return CheckboxListTile(
                              title: Text(
                                restricao.nome,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: isSelected,
                              activeColor: const Color(0xFF0FE687),
                              onChanged: (_) {
                                _toggleRestricao(restricao.idRestricao);
                              },
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            );
                          },
                        ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0FE687),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSaving ? null : _salvarRestricoes,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Salvar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

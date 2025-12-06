import 'package:flutter/material.dart';
import 'package:meal4you_app/models/ingredient_request_dto.dart';
import 'package:meal4you_app/models/ingredient_response_dto.dart';
import 'package:meal4you_app/models/restriction_response_dto.dart';
import 'package:meal4you_app/services/ingredient/ingredient_service.dart';
import 'package:meal4you_app/services/restriction/restriction_service.dart';

class ManageIngredientsScreen extends StatefulWidget {
  const ManageIngredientsScreen({super.key});

  @override
  State<ManageIngredientsScreen> createState() =>
      _ManageIngredientsScreenState();
}

class _ManageIngredientsScreenState extends State<ManageIngredientsScreen> {
  List<IngredientResponseDTO> ingredientes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarIngredientes();
  }

  Future<void> _carregarIngredientes() async {
    setState(() => isLoading = true);
    try {
      final lista = await IngredientService.listarMeusIngredientes().timeout(
        const Duration(seconds: 10),
      );
      if (mounted) {
        setState(() {
          ingredientes = lista;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        if (!e.toString().contains('Nenhum ingrediente encontrado')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar ingredientes: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmarDeletar(int id, String nome) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Ingrediente'),
        content: Text(
          'Tem certeza que deseja deletar "$nome"? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deletar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await IngredientService.deletarIngrediente(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingrediente deletado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          _carregarIngredientes();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao deletar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _mostrarModalAdicionarIngrediente() async {
    final nomeController = TextEditingController();
    List<RestrictionResponseDTO> restricoes = [];
    List<int> restricoesSelecionadas = [];
    bool isLoadingRestricoes = true;
    bool isSaving = false;

    try {
      restricoes = await RestrictionService.listarRestricoes();
      isLoadingRestricoes = false;
    } catch (e) {
      isLoadingRestricoes = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar restrições: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0FE687),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.restaurant, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Adicionar Ingrediente',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nome do Ingrediente *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nomeController,
                        decoration: InputDecoration(
                          hintText: 'Ex: Tomate',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Restrições Alimentares (opcional)',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isLoadingRestricoes)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (restricoes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            border: Border.all(color: Colors.blue.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Nenhuma restrição alimentar cadastrada no sistema ainda. O ingrediente será cadastrado sem restrições.',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: restricoes.map((restricao) {
                            final isSelected = restricoesSelecionadas.contains(
                              restricao.idRestricao,
                            );
                            return CheckboxListTile(
                              title: Text(restricao.nome),
                              value: isSelected,
                              activeColor: const Color(0xFF0FE687),
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value == true) {
                                    restricoesSelecionadas.add(
                                      restricao.idRestricao,
                                    );
                                  } else {
                                    restricoesSelecionadas.remove(
                                      restricao.idRestricao,
                                    );
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final modalContext = context;

                            if (nomeController.text.isEmpty) {
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor, informe o nome do ingrediente',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            setModalState(() {
                              isSaving = true;
                            });

                            try {
                              final dto = IngredientRequestDTO(
                                nome: nomeController.text,
                                restricoesIds: restricoesSelecionadas,
                              );

                              await IngredientService.cadastrarIngrediente(dto);

                              if (mounted) {
                                await _carregarIngredientes();
                                Navigator.pop(modalContext);
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Ingrediente cadastrado com sucesso!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() {
                                isSaving = false;
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(modalContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao cadastrar: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FE687),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Adicionar Ingrediente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestricaoChip(String restricao) {
    Color corFundo;
    Color corTexto;

    switch (restricao.toLowerCase()) {
      case 'vegano':
        corFundo = Colors.green.withValues(alpha: 0.2);
        corTexto = Colors.green.shade800;
        break;
      case 'vegetariano':
        corFundo = Colors.lightGreen.withValues(alpha: 0.2);
        corTexto = Colors.lightGreen.shade800;
        break;
      case 'sem glúten':
      case 'sem gluten':
        corFundo = Colors.orange.withValues(alpha: 0.2);
        corTexto = Colors.orange.shade800;
        break;
      case 'sem lactose':
        corFundo = Colors.blue.withValues(alpha: 0.2);
        corTexto = Colors.blue.shade800;
        break;
      default:
        corFundo = Colors.grey.withValues(alpha: 0.2);
        corTexto = Colors.grey.shade800;
    }

    return Chip(
      label: Text(restricao),
      backgroundColor: corFundo,
      labelStyle: TextStyle(fontSize: 11, color: corTexto),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildIngredienteCard(IngredientResponseDTO ingrediente) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ingrediente.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmarDeletar(
                    ingrediente.idIngrediente,
                    ingrediente.nome,
                  ),
                ),
              ],
            ),
            if (ingrediente.restricoes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: ingrediente.restricoes
                    .map((restricao) => _buildRestricaoChip(restricao))
                    .toList(),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                'Nenhuma restrição alimentar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
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
          const Icon(Icons.restaurant, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Nenhum ingrediente cadastrado',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "Adicionar" para criar seu primeiro ingrediente',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gerenciar Ingredientes',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${ingredientes.length} ingredientes cadastrados',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarModalAdicionarIngrediente,
        backgroundColor: const Color(0xFF0FE687),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingredientes Cadastrados',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ingredientes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: ingredientes.length,
                      itemBuilder: (context, index) {
                        return _buildIngredienteCard(ingredientes[index]);
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
}

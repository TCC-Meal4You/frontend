import 'package:flutter/material.dart';
import 'package:meal4you_app/models/ingredient_request_dto.dart';
import 'package:meal4you_app/models/ingredient_response_dto.dart';
import 'package:meal4you_app/models/restriction_response_dto.dart';
import 'package:meal4you_app/screens/home/adm_restaurant_home_screen.dart';
import 'package:meal4you_app/screens/profile/adm_profile_screen.dart';
import 'package:meal4you_app/services/ingredient/ingredient_service.dart';
import 'package:meal4you_app/services/restriction/restriction_service.dart';
import 'package:meal4you_app/widgets/manage_ingredients/ingredient_card.dart';
import 'package:meal4you_app/widgets/manage_ingredients/ingredient_empty_state.dart';

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

  Future<bool> _confirmarDeletar(
    int id,
    String nome,
    VoidCallback onDeleteStart,
  ) async {
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
      onDeleteStart();
      try {
        await IngredientService.deletarIngrediente(id);
        if (mounted) {
          setState(() {
            ingredientes.removeWhere((ing) => ing.idIngrediente == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ingrediente deletado com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao deletar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    }
    return false;
  }

  void _mostrarModalAdicionarIngrediente() async {
    final nomeController = TextEditingController();
    List<RestrictionResponseDTO> restricoes = [];
    List<int> restricoesSelecionadas = [];
    bool isLoadingRestricoes = true;
    bool isSaving = false;
    String? mensagemErro;

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
                      if (mensagemErro != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.red.withOpacity(0.1),
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: Colors.red.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  mensagemErro!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Text(
                        'Nome do Ingrediente *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nomeController,
                        decoration: InputDecoration(
                          hintText: 'Ex: Tomate',
                          helperText: 'Mínimo de 3 caracteres',
                          helperStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
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
                            final navigator = Navigator.of(context);

                            if (nomeController.text.isEmpty) {
                              setModalState(() {
                                mensagemErro =
                                    'Por favor, informe o nome do ingrediente';
                              });
                              return;
                            }

                            if (nomeController.text.length < 3) {
                              setModalState(() {
                                mensagemErro =
                                    'O nome do ingrediente deve ter no mínimo 3 caracteres';
                              });
                              return;
                            }

                            setModalState(() {
                              mensagemErro = null;
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
                                navigator.pop();
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
                                mensagemErro = 'Erro ao cadastrar: $e';
                                isSaving = false;
                              });
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            backgroundColor: const Color(0xFF0FE687),
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xFF0FE687), const Color(0xFF00D675)],
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Gerenciar Ingredientes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${ingredientes.length} ${ingredientes.length == 1 ? 'ingrediente' : 'ingredientes'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0FE687), Color(0xFF00D675)],
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: const Color(0xFF0FE687).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _mostrarModalAdicionarIngrediente,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          // ignore: deprecated_member_use
                          const Color(0xFF0FE687).withOpacity(0.15),
                          // ignore: deprecated_member_use
                          const Color(0xFF0FE687).withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      color: Color(0xFF0FE687),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ingredientes Cadastrados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ingredientes.isEmpty
                    ? const IngredientEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: ingredientes.length,
                        itemBuilder: (context, index) {
                          return IngredientCard(
                            key: ValueKey(ingredientes[index].idIngrediente),
                            ingrediente: ingredientes[index],
                            onDelete: _confirmarDeletar,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0FE687),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.store_mall_directory_outlined),
              label: 'Restaurante',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const AdmRestaurantHomeScreen();
                  },
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(-1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                ),
              );
            } else if (index == 1) {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return const AdmProfileScreen();
                  },
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

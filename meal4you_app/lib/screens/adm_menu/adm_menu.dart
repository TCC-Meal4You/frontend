import 'package:flutter/material.dart';
import 'package:meal4you_app/models/ingredient_response_dto.dart';
import 'package:meal4you_app/models/meal_request_dto.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/screens/home/adm_restaurant_home_screen.dart';
import 'package:meal4you_app/screens/profile/adm_profile_screen.dart';
import 'package:meal4you_app/services/ingredient/ingredient_service.dart';
import 'package:meal4you_app/services/meal/meal_service.dart';
import 'package:meal4you_app/widgets/adm_menu/stats_row.dart';
import 'package:meal4you_app/widgets/adm_menu/dish_card.dart';
import 'package:meal4you_app/widgets/adm_menu/empty_state.dart';

class AdmMenuScreen extends StatefulWidget {
  const AdmMenuScreen({super.key});

  @override
  State<AdmMenuScreen> createState() => _AdmMenuScreenState();
}

class _AdmMenuScreenState extends State<AdmMenuScreen> {
  List<MealResponseDTO> refeicoes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarRefeicoes();
  }

  Future<void> _carregarRefeicoes() async {
    setState(() => isLoading = true);
    try {
      final lista = await MealService.listarMinhasRefeicoes().timeout(
        const Duration(seconds: 10),
      );
      if (mounted) {
        setState(() {
          refeicoes = lista;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        if (e.toString().contains('Nenhuma refeição encontrada')) {
          setState(() => refeicoes = []);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao carregar refeições: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  int get _totalRefeicoes => refeicoes.length;
  int get _refeicoesDisponiveis => refeicoes.where((r) => r.disponivel).length;
  int get _refeicoesIndisponiveis =>
      refeicoes.where((r) => !r.disponivel).length;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _mostrarModalAdicionarRefeicao(),
          backgroundColor: const Color.fromARGB(255, 15, 230, 135),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              StatsRow(
                totalRefeicoes: _totalRefeicoes,
                refeicoesDisponiveis: _refeicoesDisponiveis,
                refeicoesIndisponiveis: _refeicoesIndisponiveis,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : refeicoes.isEmpty
                    ? const EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: refeicoes.length,
                        itemBuilder: (context, index) {
                          return DishCard(
                            key: ValueKey(refeicoes[index].idRefeicao),
                            refeicao: refeicoes[index],
                            index: index,
                            onEdit: _mostrarModalEditarRefeicao,
                            onDelete: _confirmarDeletar,
                            onToggleAvailability: _atualizarDisponibilidade,
                          );
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

  Future<void> _atualizarDisponibilidade(int id, bool disponivel) async {
    try {
      await MealService.atualizarDisponibilidade(id, disponivel);
      if (mounted) {
        setState(() {
          final index = refeicoes.indexWhere((r) => r.idRefeicao == id);
          if (index != -1) {
            refeicoes[index] = MealResponseDTO(
              idRefeicao: refeicoes[index].idRefeicao,
              nome: refeicoes[index].nome,
              preco: refeicoes[index].preco,
              tipo: refeicoes[index].tipo,
              descricao: refeicoes[index].descricao,
              disponivel: disponivel,
              ingredientes: refeicoes[index].ingredientes,
            );
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Disponibilidade atualizada para ${disponivel ? 'Disponível' : 'Indisponível'}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool> _confirmarDeletar(int id, VoidCallback onDeleteStart) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Refeição'),
        content: const Text(
          'Tem certeza que deseja deletar esta refeição permanentemente?',
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
        await MealService.deletarRefeicao(id);
        if (mounted) {
          setState(() {
            refeicoes.removeWhere((ref) => ref.idRefeicao == id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refeição deletada com sucesso'),
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

  Future<void> _mostrarModalAdicionarRefeicao() async {
    final nomeController = TextEditingController();
    final precoController = TextEditingController();
    final descricaoController = TextEditingController();
    String? tipoSelecionado;
    bool disponivel = true;
    List<IngredientResponseDTO> ingredientes = [];
    List<int> ingredientesSelecionados = [];
    bool isLoadingIngredientes = true;
    bool isSaving = false;

    // Carregar ingredientes
    try {
      ingredientes = await IngredientService.listarMeusIngredientes();
      isLoadingIngredientes = false;
    } catch (e) {
      isLoadingIngredientes = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar ingredientes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (!mounted) return;

    await showModalBottomSheet(
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
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 157, 0, 255),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.restaurant, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Adicionar Novo Prato',
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
                        'Preencha as informações do novo prato e selecione os ingredientes',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Nome do Prato *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nomeController,
                        decoration: InputDecoration(
                          hintText: 'Ex: Salada Caesar',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Preço *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: precoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ex: 25,50',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixText: 'R\$ ',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tipo do Prato *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: tipoSelecionado,
                        hint: const Text('Selecione o tipo do prato'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Entrada',
                            child: Text('Entrada'),
                          ),
                          DropdownMenuItem(
                            value: 'Prato Principal',
                            child: Text('Prato Principal'),
                          ),
                          DropdownMenuItem(
                            value: 'Sobremesa',
                            child: Text('Sobremesa'),
                          ),
                          DropdownMenuItem(
                            value: 'Bebida',
                            child: Text('Bebida'),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() => tipoSelecionado = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Descrição',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descricaoController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Descrição do prato (opcional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Disponível para pedidos',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Switch(
                            value: disponivel,
                            onChanged: (value) {
                              setModalState(() => disponivel = value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ingredientes',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isLoadingIngredientes)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (ingredientes.isEmpty)
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
                                  'Nenhum ingrediente cadastrado. Adicione ingredientes na tela de gerenciar ingredientes.',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: ingredientes.map((ingrediente) {
                            final isSelected = ingredientesSelecionados
                                .contains(ingrediente.idIngrediente);
                            return CheckboxListTile(
                              title: Text(ingrediente.nome),
                              subtitle: ingrediente.restricoes.isNotEmpty
                                  ? Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: ingrediente.restricoes
                                          .map(
                                            (r) => Chip(
                                              label: Text(r),
                                              labelStyle: const TextStyle(
                                                fontSize: 10,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          )
                                          .toList(),
                                    )
                                  : null,
                              value: isSelected,
                              activeColor: const Color.fromARGB(
                                255,
                                157,
                                0,
                                255,
                              ),
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value == true) {
                                    ingredientesSelecionados.add(
                                      ingrediente.idIngrediente,
                                    );
                                  } else {
                                    ingredientesSelecionados.remove(
                                      ingrediente.idIngrediente,
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

                            if (nomeController.text.isEmpty ||
                                precoController.text.isEmpty ||
                                tipoSelecionado == null) {
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Preencha todos os campos obrigatórios',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (ingredientesSelecionados.isEmpty) {
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Selecione pelo menos 1 ingrediente',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSaving = true);

                            try {
                              final preco = double.tryParse(
                                precoController.text.replaceAll(',', '.'),
                              );
                              if (preco == null) {
                                throw Exception('Preço inválido');
                              }

                              final dto = MealRequestDTO(
                                nome: nomeController.text,
                                preco: preco,
                                tipo: tipoSelecionado!,
                                descricao: descricaoController.text.isEmpty
                                    ? null
                                    : descricaoController.text,
                                disponivel: disponivel,
                                ingredientesIds: ingredientesSelecionados,
                              );

                              await MealService.cadastrarRefeicao(dto);

                              if (mounted) {
                                await _carregarRefeicoes();
                                Navigator.pop(modalContext);
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Prato cadastrado com sucesso!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSaving = false);
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
                      backgroundColor: const Color.fromARGB(255, 157, 0, 255),
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
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Adicionar Prato',
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

  Future<void> _mostrarModalEditarRefeicao(MealResponseDTO refeicao) async {
    final nomeController = TextEditingController(text: refeicao.nome);
    final precoController = TextEditingController(
      text: refeicao.preco.toStringAsFixed(2),
    );
    final descricaoController = TextEditingController(
      text: refeicao.descricao ?? '',
    );
    String? tipoSelecionado = refeicao.tipo;
    List<IngredientResponseDTO> ingredientes = [];
    // Inicializa com os IDs dos ingredientes já na refeição
    final List<int> ingredientesSelecionados = List<int>.from(
      refeicao.ingredientes.map((i) => i.idIngrediente),
    );
    bool isLoadingIngredientes = true;
    bool isSaving = false;

    try {
      ingredientes = await IngredientService.listarMeusIngredientes();
      isLoadingIngredientes = false;
    } catch (e) {
      isLoadingIngredientes = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar ingredientes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (!mounted) return;

    await showModalBottomSheet(
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
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 157, 0, 255),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Editar Prato',
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
                        'Preencha as informações do prato e selecione os ingredientes',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Nome do Prato *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nomeController,
                        decoration: InputDecoration(
                          hintText: 'Ex: Salada Caesar',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Preço *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: precoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ex: 25,50',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          prefixText: 'R\$ ',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tipo do Prato *',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: tipoSelecionado,
                        hint: const Text('Selecione o tipo do prato'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Entrada',
                            child: Text('Entrada'),
                          ),
                          DropdownMenuItem(
                            value: 'Prato Principal',
                            child: Text('Prato Principal'),
                          ),
                          DropdownMenuItem(
                            value: 'Sobremesa',
                            child: Text('Sobremesa'),
                          ),
                          DropdownMenuItem(
                            value: 'Bebida',
                            child: Text('Bebida'),
                          ),
                        ],
                        onChanged: (value) {
                          setModalState(() => tipoSelecionado = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Descrição',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descricaoController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Descrição do prato (opcional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ingredientes',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isLoadingIngredientes)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (ingredientes.isEmpty)
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
                                  'Nenhum ingrediente cadastrado. Adicione ingredientes na tela de gerenciar ingredientes.',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: ingredientes.map((ingrediente) {
                            final isSelected = ingredientesSelecionados
                                .contains(ingrediente.idIngrediente);
                            return CheckboxListTile(
                              title: Text(ingrediente.nome),
                              subtitle: ingrediente.restricoes.isNotEmpty
                                  ? Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: ingrediente.restricoes
                                          .map(
                                            (r) => Chip(
                                              label: Text(r),
                                              labelStyle: const TextStyle(
                                                fontSize: 10,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          )
                                          .toList(),
                                    )
                                  : null,
                              value: isSelected,
                              activeColor: const Color.fromARGB(
                                255,
                                157,
                                0,
                                255,
                              ),
                              onChanged: (bool? value) {
                                setModalState(() {
                                  if (value == true) {
                                    ingredientesSelecionados.add(
                                      ingrediente.idIngrediente,
                                    );
                                  } else {
                                    ingredientesSelecionados.remove(
                                      ingrediente.idIngrediente,
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

                            if (nomeController.text.isEmpty ||
                                precoController.text.isEmpty ||
                                tipoSelecionado == null) {
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Preencha todos os campos obrigatórios',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (ingredientesSelecionados.isEmpty) {
                              ScaffoldMessenger.of(modalContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Selecione pelo menos 1 ingrediente',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSaving = true);

                            try {
                              final preco = double.tryParse(
                                precoController.text.replaceAll(',', '.'),
                              );
                              if (preco == null) {
                                throw Exception('Preço inválido');
                              }

                              final dto = MealRequestDTO(
                                nome: nomeController.text,
                                preco: preco,
                                tipo: tipoSelecionado!,
                                descricao: descricaoController.text.isEmpty
                                    ? null
                                    : descricaoController.text,
                                disponivel: refeicao.disponivel,
                                ingredientesIds: ingredientesSelecionados,
                              );

                              await MealService.atualizarRefeicao(
                                refeicao.idRefeicao,
                                dto,
                              );

                              if (mounted) {
                                await _carregarRefeicoes();
                                Navigator.pop(modalContext);
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Prato atualizado com sucesso!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSaving = false);
                              if (mounted) {
                                ScaffoldMessenger.of(modalContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Erro ao atualizar: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 157, 0, 255),
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
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Salvar Alterações',
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
}

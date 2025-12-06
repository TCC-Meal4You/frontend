import 'package:flutter/material.dart';
import 'package:meal4you_app/models/ingredient_response_dto.dart';
import 'package:meal4you_app/models/meal_request_dto.dart';
import 'package:meal4you_app/models/meal_response_dto.dart';
import 'package:meal4you_app/services/ingredient/ingredient_service.dart';
import 'package:meal4you_app/services/meal/meal_service.dart';

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
          // Apenas seta a lista vazia sem mostrar erro
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
              _buildStatsRow(),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : refeicoes.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: refeicoes.length,
                        itemBuilder: (context, index) {
                          final refeicao = refeicoes[index];
                          return _buildDishCard(refeicao, index);
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
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          'Total de Pratos',
          _totalRefeicoes.toString(),
          Colors.purple,
        ),
        _buildStatCard(
          'Disponíveis',
          _refeicoesDisponiveis.toString(),
          Colors.green,
        ),
        _buildStatCard(
          'Indisponíveis',
          _refeicoesIndisponiveis.toString(),
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
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

  Widget _buildDishCard(MealResponseDTO refeicao, int index) {
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
                          refeicao.nome,
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
                          refeicao.tipo,
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
                      onPressed: () => _mostrarModalEditarRefeicao(refeicao),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarDeletar(refeicao.idRefeicao),
                    ),
                  ],
                ),
              ],
            ),
            if (refeicao.descricao != null && refeicao.descricao!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  refeicao.descricao!,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              'R\$ ${refeicao.preco.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (refeicao.ingredientes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: refeicao.ingredientes
                    .expand((ingrediente) => ingrediente.restricoes)
                    .toSet()
                    .map((restricao) => _buildRestricaoChip(restricao))
                    .toList(),
              ),
              const SizedBox(height: 4),
              Text(
                'Ingredientes: ${refeicao.ingredientes.map((i) => i.nome).join(', ')}',
                style: TextStyle(color: Colors.grey[800], fontSize: 13),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Disponível para pedidos'),
                Switch(
                  value: refeicao.disponivel,
                  onChanged: (value) =>
                      _atualizarDisponibilidade(refeicao.idRefeicao, value),
                ),
              ],
            ),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  Future<void> _confirmarDeletar(int id) async {
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
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmado == true) {
      try {
        await MealService.deletarRefeicao(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refeição deletada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
          _carregarRefeicoes();
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
                        value: tipoSelecionado,
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
                        value: tipoSelecionado,
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
            'Toque em “+” para criar seu primeiro prato',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

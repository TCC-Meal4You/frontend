import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meal4you_app/controllers/logout_handlers/adm_logout_handler.dart';
import 'package:meal4you_app/providers/restaurant/restaurant_provider.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:meal4you_app/services/register_restaurant/register_restaurant_service.dart';
import 'package:meal4you_app/services/viacep/viacep_service.dart';
import 'package:meal4you_app/utils/formatter/cep_input_formatter.dart';
import 'package:provider/provider.dart';

String formatCep(String cep) {
  final cleaned = cep.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleaned.length == 8) {
    return '${cleaned.substring(0, 5)}-${cleaned.substring(5)}';
  }
  return cleaned;
}

class CreateAdmRestaurantScreen extends StatefulWidget {
  const CreateAdmRestaurantScreen({super.key});

  @override
  State<CreateAdmRestaurantScreen> createState() =>
      _CreateAdmRestaurantScreenState();
}

class _CreateAdmRestaurantScreenState extends State<CreateAdmRestaurantScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController cepController = TextEditingController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController ufController = TextEditingController();

  bool _isActive = false;
  bool _isLoadingCep = false;

  final Map<String, bool> _foodTypes = {
    "Brasileira": false,
    "Italiana": false,
    "Japonesa": false,
    "Mexicana": false,
    "Indiana": false,
    "Árabe": false,
    "Francesa": false,
    "Vegetariana": false,
    "Vegana": false,
    "Hambúrguer": false,
    "Pizza": false,
    "Sushi": false,
    "Churrasco": false,
    "Frutos do Mar": false,
    "Comida Saudável": false,
    "Fast Food": false,
    "Doces e Sobremesas": false,
    "Lanches": false,
    "Cafeteria": false,
  };

  @override
  void initState() {
    super.initState();
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );

    nameController.text = restaurantProvider.name;
    descriptionController.text = restaurantProvider.description;
    cepController.text = formatCep(restaurantProvider.cep);
    logradouroController.text = restaurantProvider.logradouro;
    numeroController.text = restaurantProvider.numero;
    complementoController.text = restaurantProvider.complemento;
    bairroController.text = restaurantProvider.bairro;
    cidadeController.text = restaurantProvider.cidade;
    ufController.text = restaurantProvider.uf;

    _isActive = restaurantProvider.isActive;

    for (var food in restaurantProvider.foodTypes) {
      if (_foodTypes.containsKey(food)) {
        _foodTypes[food] = true;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    cepController.dispose();
    logradouroController.dispose();
    numeroController.dispose();
    complementoController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    ufController.dispose();
    super.dispose();
  }

  void resetForm() {
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    restaurantProvider.resetRestaurant();

    nameController.clear();
    descriptionController.clear();
    cepController.clear();
    logradouroController.clear();
    numeroController.clear();
    complementoController.clear();
    bairroController.clear();
    cidadeController.clear();
    ufController.clear();
    _isActive = false;

    for (var key in _foodTypes.keys) {
      _foodTypes[key] = false;
    }

    setState(() {});
  }

  Future<void> _buscarCep() async {
    final cep = cepController.text.replaceAll('-', '').trim();

    if (cep.isEmpty || cep.length != 8) {
      return;
    }

    setState(() => _isLoadingCep = true);

    try {
      final resultado = await ViaCepService.consultarCep(cep);

      if (resultado != null) {
        setState(() {
          logradouroController.text = resultado['logradouro'] ?? '';
          complementoController.text = resultado['complemento'] ?? '';
          bairroController.text = resultado['bairro'] ?? '';
          cidadeController.text = resultado['cidade'] ?? '';
          ufController.text = resultado['uf'] ?? '';
        });

        final provider = Provider.of<RestaurantProvider>(
          context,
          listen: false,
        );
        provider.updateCep(cep);
        provider.updateLogradouro(logradouroController.text);
        provider.updateBairro(bairroController.text);
        provider.updateCidade(cidadeController.text);
        provider.updateEstado(ufController.text);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Endereço encontrado!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        logradouroController.clear();
        bairroController.clear();
        cidadeController.clear();
        ufController.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingCep = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final admLogoutHandler = AdmLogoutHandler();

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              Container(
                height: 190,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 157, 0, 255),
                      Color.fromARGB(255, 15, 230, 135),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: const [
                              Text(
                                'MEAL4YOU',
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 27,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'c  o  m  i  d  a    c  o  n  s  c  i  e  n  t  e',
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () =>
                                admLogoutHandler.showLogoutDialog(context),
                            icon: const FaIcon(
                              FontAwesomeIcons.rightFromBracket,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Configuração inicial',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Crie seu Restaurante',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Configure as informações básicas do seu restaurante',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: 350,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 217, 217, 217),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          color: Color.fromARGB(255, 15, 230, 135),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Informações do Restaurante",
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Nome do Restaurante *",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: nameController,
                      onChanged: (value) =>
                          restaurantProvider.updateName(value),
                      decoration: InputDecoration(
                        hintText: "Ex: Cantinho da Vovó",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Descrição *",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: descriptionController,
                      onChanged: (value) =>
                          restaurantProvider.updateDescription(value),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            "Descreva seu restaurante, especialidades, ambiente...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color.fromARGB(255, 15, 230, 135),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Endereço do Restaurante",
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "CEP *",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: cepController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final restaurantProvider =
                            Provider.of<RestaurantProvider>(
                              context,
                              listen: false,
                            );

                        final cepLimpo = value
                            .replaceAll('-', '')
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        restaurantProvider.updateCep(cepLimpo);

                        if (cepLimpo.length == 8) {
                          _buscarCep();
                        } else if (cepLimpo.length < 8) {
                          setState(() {
                            logradouroController.clear();
                            bairroController.clear();
                            cidadeController.clear();
                            ufController.clear();
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "00000-000",
                        counterText: "",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: _isLoadingCep
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : (logradouroController.text.isNotEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                    )
                                  : null),
                      ),
                      inputFormatters: [CepInputFormatter()],
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "Logradouro *",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: logradouroController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: "Automático pelo CEP",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Número *",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: numeroController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: "123",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Complemento",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: complementoController,
                                decoration: InputDecoration(
                                  hintText: "Bloco, Apto...",
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "Bairro *",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: bairroController,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: "Automático pelo CEP",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Cidade *",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: cidadeController,
                                enabled: false,
                                decoration: InputDecoration(
                                  hintText: "Automático pelo CEP",
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "UF *",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: ufController,
                                enabled: false,
                                maxLength: 2,
                                decoration: InputDecoration(
                                  hintText: "Aut.",
                                  counterText: "",
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    SwitchListTile(
                      title: const Text(
                        "Ativar visibilidade: seu restaurante ficará visível para todos os clientes.\nVocê pode alterar isso depois.",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      value: _isActive,
                      activeThumbColor: const Color.fromARGB(255, 15, 230, 135),
                      onChanged: (value) async {
                        bool activate = value;
                        if (value == true && !_isActive) {
                          final shouldActivate = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              title: const Text(
                                "Atenção!",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Ubuntu',
                                ),
                              ),
                              content: const Text(
                                "Se você ativar agora, seu restaurante ficará visível "
                                "para os clientes, mesmo sem pratos, ingredientes ou cardápio configurado.",
                                style: TextStyle(
                                  fontFamily: 'Ubuntu',
                                  fontSize: 14,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    "Cancelar",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 157, 0, 255),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      15,
                                      230,
                                      135,
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    "Ativar mesmo assim",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                          activate = shouldActivate ?? false;
                        }

                        setState(() => _isActive = activate);
                        restaurantProvider.updateIsActive(_isActive);
                      },
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "Tipos de Comida * (selecione pelo menos um)",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: -8,
                      children: _foodTypes.keys.map((food) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              checkColor: WidgetStateProperty.all(Colors.white),
                            ),
                          ),
                          child: SizedBox(
                            width: 145,
                            child: CheckboxListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                food,
                                style: const TextStyle(fontSize: 13),
                              ),
                              value: _foodTypes[food],
                              onChanged: (value) {
                                setState(() {
                                  _foodTypes[food] = value ?? false;
                                });
                                final selected = _foodTypes.entries
                                    .where((e) => e.value)
                                    .map((e) => e.key)
                                    .toList();
                                restaurantProvider.updateFoodTypes(selected);
                              },
                              activeColor: const Color.fromARGB(
                                255,
                                15,
                                230,
                                135,
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final selected = _foodTypes.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .toList();

                          if (nameController.text.isEmpty ||
                              descriptionController.text.isEmpty ||
                              selected.isEmpty ||
                              cepController.text.isEmpty ||
                              logradouroController.text.isEmpty ||
                              numeroController.text.isEmpty ||
                              bairroController.text.isEmpty ||
                              cidadeController.text.isEmpty ||
                              ufController.text.isEmpty) {
                            String mensagemErro =
                                "Preencha todos os campos obrigatórios.";

                            if (cepController.text.isNotEmpty &&
                                (logradouroController.text.isEmpty ||
                                    bairroController.text.isEmpty ||
                                    cidadeController.text.isEmpty ||
                                    ufController.text.isEmpty)) {
                              mensagemErro =
                                  "Digite um CEP válido de 8 dígitos para preencher o endereço automaticamente.";
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(mensagemErro),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                            return;
                          }

                          final token = await UserTokenSaving.getToken();
                          if (token == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Token não encontrado. Faça login novamente.",
                                ),
                              ),
                            );
                            return;
                          }

                          try {
                            final cepLimpo = cepController.text.replaceAll('-', '').trim();
                            
                            final restaurantData =
                                await RegisterRestaurantService.registerRestaurant(
                                  name: nameController.text,
                                  description: descriptionController.text,
                                  isActive: _isActive,
                                  foodTypes: selected,
                                  token: token,
                                  cep: cepLimpo,
                                  logradouro: logradouroController.text.trim(),
                                  numero: numeroController.text.trim(),
                                  complemento:
                                      complementoController.text.isNotEmpty
                                      ? complementoController.text.trim()
                                      : null,
                                  bairro: bairroController.text.trim(),
                                  cidade: cidadeController.text.trim(),
                                  uf: ufController.text.trim(),
                                );

                            final newRestaurantId =
                                restaurantData['idRestaurante'] ??
                                restaurantData['id'];

                            restaurantProvider.updateRestaurant(
                              id: newRestaurantId,
                              name: nameController.text,
                              description: descriptionController.text,
                              isActive: _isActive,
                              foodTypes: selected,
                              cep: cepLimpo,
                              logradouro: logradouroController.text,
                              numero: numeroController.text,
                              complemento: complementoController.text,
                              bairro: bairroController.text,
                              cidade: cidadeController.text,
                              uf: ufController.text,
                            );

                            await UserTokenSaving.saveRestaurantId(
                              newRestaurantId,
                            );
                            await UserTokenSaving.saveRestaurantDataForCurrentUser(
                              {
                                'idRestaurante': newRestaurantId,
                                'nome': nameController.text,
                                'descricao': descriptionController.text,
                                'ativo': _isActive,
                                'tipoComida': selected,
                                'endereco': {
                                  'cep': cepLimpo,
                                  'logradouro': logradouroController.text,
                                  'numero': numeroController.text,
                                  'complemento': complementoController.text,
                                  'bairro': bairroController.text,
                                  'cidade': cidadeController.text,
                                  'uf': ufController.text,
                                },
                              },
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Restaurante criado com sucesso!",
                                ),
                              ),
                            );

                            Navigator.pushNamed(context, '/admRestaurantHome');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Erro ao criar restaurante: $e"),
                              ),
                            );
                          }
                        },

                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color.fromARGB(
                            255,
                            15,
                            230,
                            135,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Criar Restaurante",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Ubuntu',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'Após criar seu restaurante, você poderá adicionar pratos ao cardápio '
                  'e gerenciar ingredientes para atender às preferências dos clientes.',
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

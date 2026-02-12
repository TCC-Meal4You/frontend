import 'package:flutter/material.dart';
import 'package:meal4you_app/services/restriction/restriction_service.dart';

class RestrictionsChoiceScreen extends StatefulWidget {
  const RestrictionsChoiceScreen({super.key});

  @override
  State<RestrictionsChoiceScreen> createState() => _ButtonSelectedState();
}

class ButtonItem {
  final String name;

  ButtonItem(this.name);
}

class _ButtonSelectedState extends State<RestrictionsChoiceScreen> {
  List<ButtonItem> selected = [];
  List<ButtonItem> buttons = [];
  bool isLoadingRestrictions = true;

  @override
  void initState() {
    super.initState();
    _carregarRestricoes();
  }

  Future<void> _carregarRestricoes() async {
    setState(() => isLoadingRestrictions = true);
    try {
      final restricoes = await RestrictionService.listarRestricoes();

      if (mounted) {
        setState(() {
          buttons = restricoes.map((restricao) {
            return ButtonItem(restricao.nome);
          }).toList();

          buttons.insert(0, ButtonItem('Nenhuma Restrição'));

          isLoadingRestrictions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          buttons = [ButtonItem('Nenhuma Restrição')];
          isLoadingRestrictions = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar restrições: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isNoneSelected() {
    return selected.any((item) => item.name == 'Nenhuma Restrição');
  }

  bool _haveOthersSelected() {
    return selected.any((item) => item.name != 'Nenhuma Restrição');
  }

  void _add(ButtonItem button) {
    setState(() {
      if (button.name == 'Nenhuma Restrição') {
        selected = [button];
      } else {
        if (_isNoneSelected()) {
          selected.clear();
        }
        if (!selected.contains(button)) {
          selected.add(button);
        }
      }
    });
  }

  void _remove(ButtonItem button) {
    setState(() {
      selected.remove(button);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Suas Restrições Alimentares',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selecione todas as suas restrições alimentares (se houver)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontFamily: 'Ubuntu',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoadingRestrictions
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      itemCount: buttons.length,
                      itemBuilder: (context, index) {
                        final button = buttons[index];
                        final isNone = button.name == 'Nenhuma Restrição';
                        final noneActivated = _isNoneSelected();
                        final othersActivated = _haveOthersSelected();
                        final isSelected = selected.contains(button);

                        final disabled =
                            (noneActivated && !isNone) ||
                            (othersActivated && isNone);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: disabled
                                  ? Colors.grey[300]!
                                  : isSelected
                                  ? Color.fromARGB(255, 157, 0, 255)
                                  : Colors.grey[300]!,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: disabled
                                  ? null
                                  : () {
                                      if (isSelected) {
                                        _remove(button);
                                      } else {
                                        _add(button);
                                      }
                                    },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        button.name,
                                        style: TextStyle(
                                          color: disabled
                                              ? Colors.grey[400]
                                              : isNone
                                              ? Color.fromARGB(255, 157, 0, 255)
                                              : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: disabled
                                              ? Colors.grey[300]!
                                              : isSelected
                                              ? Color.fromARGB(255, 157, 0, 255)
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                        color: isSelected
                                            ? Color.fromARGB(255, 157, 0, 255)
                                            : Colors.white,
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selected.isEmpty
                          ? null
                          : () {
                              Navigator.pushNamed(context, '/clientProfile');
                            },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color?>((states) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.grey[300];
                              }
                              return const Color.fromARGB(255, 15, 230, 135);
                            }),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        elevation: WidgetStateProperty.all(0),
                      ),
                      child: Text(
                        selected.isEmpty
                            ? 'Selecione pelo menos uma opção'
                            : 'Confirmar',
                        style: TextStyle(
                          color: selected.isEmpty
                              ? Colors.grey[500]
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${selected.length} selecionada${selected.length != 1 ? 's' : ''}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

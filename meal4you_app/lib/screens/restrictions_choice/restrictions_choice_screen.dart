import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RestrictionsChoiceScreen extends StatefulWidget {
  const RestrictionsChoiceScreen({super.key});

  @override
  State<RestrictionsChoiceScreen> createState() => _ButtonSelectedState();
}

class ButtonItem {
  final String name;
  final IconData icon;

  ButtonItem(this.name, this.icon);
}

class _ButtonSelectedState extends State<RestrictionsChoiceScreen> {
  List<ButtonItem> selected = [];

  final List<ButtonItem> buttons = [
    ButtonItem('Lactose', FontAwesomeIcons.cow),
    ButtonItem('Glúten', FontAwesomeIcons.breadSlice),
    ButtonItem('Peixes', FontAwesomeIcons.fish),
    ButtonItem('Frutose', FontAwesomeIcons.appleWhole),
    ButtonItem('Vegano', FontAwesomeIcons.seedling),
    ButtonItem('Vegetariano', FontAwesomeIcons.carrot),
    ButtonItem('Diabetes', FontAwesomeIcons.syringe),
    ButtonItem('Hipertensão', FontAwesomeIcons.heartPulse),
    ButtonItem('Nenhuma', Icons.not_interested),
  ];

  bool _isNoneSelected() {
    return selected.any((item) => item.name == 'Nenhuma');
  }

  bool _haveOthersSelected() {
    return selected.any((item) => item.name != 'Nenhuma');
  }

  final TextEditingController _controller = TextEditingController();

  void _addCustomText(String text) {
    final name = text.trim();
    if (name.isEmpty) return;

    final alreadyExists = selected.any(
      (item) => item.name.toLowerCase() == name.toLowerCase(),
    );
    if (alreadyExists) return;

    setState(() {
      selected.add(ButtonItem(name, Icons.label_outline));
    });

    _controller.clear();
  }

  void _add(ButtonItem button) {
    setState(() {
      if (button.name == 'Nenhuma') {
        selected = [button];
      } else {
        if (_isNoneSelected()) return;
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
        body: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Column(
                    children: [
                      Text(
                        'Selecione suas',
                        style: TextStyle(color: Colors.black, fontSize: 45),
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'restrições alimentares',
                          style: TextStyle(
                            color: Color.fromARGB(255, 157, 0, 255),
                            fontSize: 35,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 17,
                      mainAxisSpacing: 15,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: buttons.map((button) {
                        final isNone = button.name == 'Nenhuma';
                        final noneActivated = _isNoneSelected();
                        final othersActivated = _haveOthersSelected();

                        final disabled =
                            (noneActivated && !isNone) ||
                            (othersActivated && isNone);

                        return ElevatedButton(
                          onPressed: disabled ? null : () => _add(button),
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Colors.grey[400];
                                  }
                                  if (selected.contains(button)) {
                                    return Color.fromARGB(255, 157, 0, 255);
                                  }
                                  return Colors.white;
                                }),
                            shadowColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Colors.transparent;
                                  }
                                  return Color.fromARGB(255, 157, 0, 255);
                                }),
                            elevation: WidgetStateProperty.resolveWith<double>((
                              states,
                            ) {
                              if (states.contains(WidgetState.disabled)) {
                                return 0;
                              }
                              return 7;
                            }),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                button.icon,
                                size: 28,
                                color: disabled
                                    ? Colors.black45
                                    : selected.contains(button)
                                    ? Colors.white
                                    : Color.fromARGB(255, 157, 0, 255),
                              ),
                              SizedBox(height: 8),
                              Text(
                                button.name,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: disabled
                                      ? Colors.black45
                                      : selected.contains(button)
                                      ? Colors.white
                                      : Color.fromARGB(255, 157, 0, 255),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: 'Adicionar outra restrição',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffix: _controller.text.isEmpty
                            ? null
                            : ElevatedButton(
                                onPressed: () =>
                                    _addCustomText(_controller.text),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    157,
                                    0,
                                    255,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Adicionar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      onSubmitted: (value) => _addCustomText(value),
                    ),
                  ),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selected.map((item) {
                      return SizedBox(
                        width:
                            (MediaQuery.of(context).size.width - 8 * 2 - 16) /
                            3,
                        child: Chip(
                          avatar: Icon(
                            item.icon,
                            size: 20,
                            color: Colors.white,
                          ),
                          label: Text(
                            item.name,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white),
                          ),
                          deleteIcon: Icon(Icons.close),
                          onDeleted: () => _remove(item),
                          backgroundColor: Color.fromARGB(255, 157, 0, 255),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: selected.isEmpty
                        ? null
                        : () {
                           Navigator.pushNamed(context, '/clientProfile');
                          },
                    icon: Icon(
                      selected.isEmpty ? Icons.block : Icons.check,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Confirmar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                        states,
                      ) {
                        if (states.contains(WidgetState.disabled)) {
                          return Colors.grey[400];
                        }
                        return const Color.fromARGB(255, 15, 230, 135);
                      }),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TimeChoiceScreen extends StatefulWidget {
  const TimeChoiceScreen({super.key});

  @override
  State<TimeChoiceScreen> createState() => _ButtonSelectedState();
}

class ButtonItem {
  final String name;

  ButtonItem(this.name);
}

class _ButtonSelectedState extends State<TimeChoiceScreen> {
  List<ButtonItem> selected = [];

  final List<ButtonItem> botoes = [
    ButtonItem('-15 min'),
    ButtonItem('15 min'),
    ButtonItem('25 min'),
    ButtonItem('35 min'),
    ButtonItem('45 min'),
    ButtonItem('55 min'),
    ButtonItem('1 hora'),
    ButtonItem('+1 hora'),
    ButtonItem('Livre'),
  ];

  bool _isNoneSelected() {
    return selected.any((item) => item.name == 'Livre');
  }

  bool _haveOthersSelected() {
    return selected.any((item) => item.name != 'Livre');
  }

  void _add(ButtonItem button) {
    setState(() {
      if (button.name == 'Livre') {
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
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/choices_background.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Column(
                    children: [
                      Text(
                        'Selecione o tempo',
                        style: TextStyle(color: Colors.black, fontSize: 45),
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'disponível para comer',
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
                      children: botoes.map((button) {
                        final isNone = button.name == 'Livre';
                        final noneActivated = _isNoneSelected();
                        final othersActivated = _haveOthersSelected();

                        final disabled =
                            (noneActivated && !isNone) ||
                            (othersActivated && isNone);

                        return ElevatedButton(
                          onPressed: disabled ? null : () => _add(button),
                          style: ButtonStyle(
                            alignment: Alignment.center,
                            backgroundColor:
                                WidgetStateProperty.resolveWith<Color?>((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Colors.grey[400];
                                  }
                                  return selected.contains(button)
                                      ? Color.fromARGB(255, 157, 0, 255)
                                      : Colors.white;
                                }),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            elevation: WidgetStateProperty.resolveWith<double>((
                              states,
                            ) {
                              if (states.contains(WidgetState.disabled)) {
                                return 0;
                              }
                              return 7;
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
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selected.map((item) {
                      return SizedBox(
                        width:
                            (MediaQuery.of(context).size.width - 8 * 2 - 16) /
                            3,
                        child: Chip(
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
                    onPressed: selected.isEmpty ? null : () {},
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
                        return Color.fromARGB(255, 15, 230, 135);
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

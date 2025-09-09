import 'package:flutter/material.dart';

class DescricaoCliente extends StatefulWidget {
  const DescricaoCliente({super.key});

  @override
  State<DescricaoCliente> createState() => _DescricaoClienteState();
}

class _DescricaoClienteState extends State<DescricaoCliente> {
  bool isOptionTwo = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(70, 60, 70, 40),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 80,
                    width: 250,
                    decoration: BoxDecoration(
                      color: isOptionTwo
                          ? Colors.green
                          : const Color.fromARGB(255, 157, 0, 255),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromARGB(255, 44, 44, 44),
                      ),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: isOptionTwo
                            ? const Text(
                                'Dono Restaurante',
                                key: ValueKey(2),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Text(
                                'Cliente',
                                key: ValueKey(1),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: 350,
              width: 320,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 238, 236, 236),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color.fromARGB(255, 44, 44, 44),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: isOptionTwo
                        ? const Text(
                            'Selecione essa opção '
                            'se você é dono de um '
                            'restaurante e deseja '
                            'administrá-lo, além de '
                            'ser capaz de gerir as '
                            'refeições, bem como '
                            'os ingredientes, preços e suas descrições. ',
                            key: ValueKey(2),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Text(
                            'Selecione essa opção '
                            'se você busca por opções de '
                            'refeições que se adequem às '
                            'suas necessidades individuais e deseja '
                            'usar filtros para '
                            'decidir onde e o que você vai comer hoje!',
                            key: ValueKey(1),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(
              color: Colors.black,
              thickness: 3,
              indent: 40,
              endIndent: 40,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                fixedSize: const Size(280, 55),
              ),
              onPressed: () {},
              child: const Text(
                'Continuar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                setState(() {
                  isOptionTwo = !isOptionTwo;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 70,
                height: 35,
                decoration: BoxDecoration(
                  color: isOptionTwo
                      ? Colors.green
                      : const Color.fromARGB(255, 157, 0, 255),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 100),
                  alignment: isOptionTwo
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    width: 27,
                    height: 27,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Toque para trocar de Perfil',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

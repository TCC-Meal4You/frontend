import 'package:flutter/material.dart';

class ProfileChoiceScreen extends StatefulWidget {
  const ProfileChoiceScreen({super.key});

  @override
  State<ProfileChoiceScreen> createState() => _ProfileChoiceScreenState();
}

class _ProfileChoiceScreenState extends State<ProfileChoiceScreen> {
  int _currentIndex = 0;

  final List<List<Color>> _gradients = [
    [Color.fromARGB(255, 27, 28, 28), Color.fromARGB(255, 136, 0, 255)],
    [Color.fromARGB(255, 27, 28, 28), Color.fromARGB(223, 0, 203, 166)],
  ];

  final List<Color> _buttonColors = [
    Color.fromARGB(255, 157, 0, 255),
    Color.fromARGB(255, 4, 128, 73),
  ];

  final List<Map<String, String>> _texts = [
    {
      "title": "Cliente",
      "description":
          "Para quem busca refeições personalizadas: use filtros para escolher onde e o que comer hoje",
      "image": "assets/images/client.png",
    },
    {
      "title": "Administrador",
      "description":
          "Para donos de restaurante: gerencie seu estabelecimento, refeições, ingredientes, preços e descrições",
      "image": "assets/images/adm.png",
    },
  ];

  void _onSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! < 0) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _gradients.length;
      });
    } else if (details.primaryVelocity! > 0) {
      setState(() {
        _currentIndex =
            (_currentIndex - 1 + _gradients.length) % _gradients.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height / 3;
    double imageHeight = 500;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: GestureDetector(
            onHorizontalDragEnd: _onSwipe,
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _gradients[_currentIndex],
                    ),
                  ),
                ),
                Positioned(
                  top:
                      MediaQuery.of(context).size.height -
                      containerHeight -
                      (imageHeight / 1.5),
                  left: MediaQuery.of(context).size.width / 2 - 240,
                  child: Image.asset(
                    _texts[_currentIndex]["image"]!,
                    width: 500,
                    height: imageHeight,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: containerHeight,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Escolha seu perfil",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 106, 105, 105),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _texts[_currentIndex]["title"]!,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _texts[_currentIndex]["description"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentIndex == 0) {
                                Navigator.pushNamed(context, '/clientRegister');
                              } else if (_currentIndex == 1) {
                                Navigator.pushNamed(context, '/admRegister');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _buttonColors[_currentIndex],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Continuar",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_currentIndex == 0)
                  Positioned(
                    right: 20,
                    top: MediaQuery.of(context).size.height / 2 - 50,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 2),
                        Text(
                          "Arraste",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_currentIndex == 1)
                  Positioned(
                    left: 20,
                    top: MediaQuery.of(context).size.height / 2 - 20,
                    child: Row(
                      children: const [
                        Text(
                          "Arraste",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

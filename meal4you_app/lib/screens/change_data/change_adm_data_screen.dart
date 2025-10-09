import 'package:flutter/material.dart';

class ChangeAdmDataScreen extends StatefulWidget {
  const ChangeAdmDataScreen({super.key});

  @override
  State<ChangeAdmDataScreen> createState() => _ChangeAdmDataScreenState();
}

class _ChangeAdmDataScreenState extends State<ChangeAdmDataScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 27, 28, 28),
                    Color.fromARGB(223, 0, 203, 166),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.account_circle,
                                size: 100,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'Altere seus dados:',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                height: 50,
                                width: 320,
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Nome...',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 50,
                                width: 320,
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'E-mail...',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 50,
                                width: 320,
                                child: TextField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Senha...',
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    0,
                                    140,
                                    255,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  fixedSize: const Size(300, 55),
                                  elevation: 20,
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'SALVAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  fixedSize: const Size(200, 50),
                                  elevation: 20,
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'EXCLUIR CONTA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Botão de voltar
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/admProfile');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

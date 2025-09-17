import 'package:flutter/material.dart';
import 'package:meal4you_app/screens/profile/client_profile_screen.dart';

class ChangeClientDataScreen extends StatefulWidget {
  const ChangeClientDataScreen({super.key});

  @override
  State<ChangeClientDataScreen> createState() => _ChangeClientDataScreenState();
}

class _ChangeClientDataScreenState extends State<ChangeClientDataScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClientProfileScreen(),
                ),
              );
            },
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(105, 61, 2, 120),
                Color.fromARGB(255, 136, 0, 255),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 80),
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
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Altere seus dados:',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
                    SizedBox(
                      height: 50,
                      width: 320,
                      child: TextField(
                        obscureText: true,
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
                        obscureText: true,
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
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      width: 320,
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Localização...',
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
                        backgroundColor: const Color.fromARGB(255, 0, 140, 255),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

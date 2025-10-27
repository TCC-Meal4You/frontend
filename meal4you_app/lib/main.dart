import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <- Import do Provider
import 'package:meal4you_app/screens/adm_menu/adm_menu.dart';
import 'package:meal4you_app/screens/change_data/change_adm_data_screen.dart';
import 'package:meal4you_app/screens/change_data/change_client_data_screen.dart';
import 'package:meal4you_app/screens/create_adm_restaurant/create_adm_restaurant_screen.dart';
import 'package:meal4you_app/screens/home/adm_restaurant_home_screen.dart';
import 'package:meal4you_app/screens/home/client_home.dart';
import 'package:meal4you_app/screens/login/adm_login_screen.dart';
import 'package:meal4you_app/screens/login/client_login_screen.dart';
import 'package:meal4you_app/screens/profile/adm_profile_screen.dart';
import 'package:meal4you_app/screens/profile/client_profile_screen.dart';
import 'package:meal4you_app/screens/profile_choice/profile_choice_screen.dart';
import 'package:meal4you_app/screens/register/adm_register_screen.dart';
import 'package:meal4you_app/screens/register/client_register_screen.dart';
import 'package:meal4you_app/screens/restrictions_choice/restrictions_choice_screen.dart';
import 'package:meal4you_app/provider/restaurant_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
      ],
      child: const Meal4You(),
    ),
  );
}

class Meal4You extends StatelessWidget {
  const Meal4You({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal4You',
      debugShowCheckedModeBanner: false,
      initialRoute: '/admRegister',
      routes: {
        '/changeAdmData': (context) => const ChangeAdmDataScreen(),
        '/changeClientData': (context) => const ChangeClientDataScreen(),

        '/admLogin': (context) => const AdmLoginScreen(),
        '/clientLogin': (context) => const ClientLoginScreen(),

        '/admProfile': (context) => const AdmProfileScreen(),
        '/clientProfile': (context) => const ClientProfileScreen(),

        '/profileChoice': (context) => const ProfileChoiceScreen(),

        '/admRegister': (context) => const AdmRegisterScreen(),
        '/clientRegister': (context) => const ClientRegisterScreen(),

        '/restrictionsChoice': (context) => const RestrictionsChoiceScreen(),

        '/createAdmRestaurant': (context) => const CreateAdmRestaurantScreen(),

        '/clientHome': (context) => const ClientHome(),
        '/admRestaurantHome': (context) => const AdmRestaurantHomeScreen(),

        '/admMenu': (context) => const AdmMenuScreen(),
      },
    );
  }
}

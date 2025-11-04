import 'package:flutter/material.dart';
import 'package:meal4you_app/screens/verify_email/verify_code_screen.dart';
import 'package:provider/provider.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RestaurantProvider())],
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
      initialRoute: '/clientRegister',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/changeAdmData':
            return MaterialPageRoute(
              builder: (_) => const ChangeAdmDataScreen(),
            );
          case '/changeClientData':
            return MaterialPageRoute(
              builder: (_) => const ChangeClientDataScreen(),
            );
          case '/admLogin':
            return MaterialPageRoute(builder: (_) => const AdmLoginScreen());
          case '/clientLogin':
            return MaterialPageRoute(builder: (_) => const ClientLoginScreen());
          case '/admProfile':
            return MaterialPageRoute(builder: (_) => const AdmProfileScreen());
          case '/clientProfile':
            return MaterialPageRoute(
              builder: (_) => const ClientProfileScreen(),
            );
          case '/profileChoice':
            return MaterialPageRoute(
              builder: (_) => const ProfileChoiceScreen(),
            );
          case '/admRegister':
            return MaterialPageRoute(builder: (_) => const AdmRegisterScreen());
          case '/clientRegister':
            return MaterialPageRoute(
              builder: (_) => const ClientRegisterScreen(),
            );
          case '/restrictionsChoice':
            return MaterialPageRoute(
              builder: (_) => const RestrictionsChoiceScreen(),
            );
          case '/createAdmRestaurant':
            return MaterialPageRoute(
              builder: (_) => const CreateAdmRestaurantScreen(),
            );
          case '/clientHome':
            return MaterialPageRoute(builder: (_) => const ClientHome());
          case '/admRestaurantHome':
            return MaterialPageRoute(
              builder: (_) => const AdmRestaurantHomeScreen(),
            );
          case '/admMenu':
            return MaterialPageRoute(builder: (_) => const AdmMenuScreen());
          // case '/restaurantSettings':
          //   return MaterialPageRoute(builder: (_) => const RestaurantSettingsScreen());
          case '/verifyCode':
            return MaterialPageRoute(builder: (_) => const VerifyCodeScreen());
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Rota não encontrada')),
              ),
            );
        }
      },
    );
  }
}

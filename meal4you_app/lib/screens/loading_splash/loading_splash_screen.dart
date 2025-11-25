import 'package:flutter/material.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;

  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScale = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoController.forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      _textController.forward();
    });

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 5), _checkLogin);
  }

  Future<void> _checkLogin() async {
  final token = await UserTokenSaving.getToken();
  final userData = await UserTokenSaving.getUserData();

  
  if (token == null || userData == null) {
    _goTo('/profileChoice');
    return;
  }

  final userType = userData['userType'];
  final tipo = userData['tipo'];
  final isAdmField = userData['isAdm'];
  
  final restaurantId = await UserTokenSaving.getRestaurantId();
  
  final restaurantData = await UserTokenSaving.getRestaurantDataForCurrentUser();

  final isAdmByUserType = userType == 'adm';
  final isAdmByTipo = tipo == 'adm';
  final isAdmByField = isAdmField == true;
  final hasRestaurantId = restaurantId != null && restaurantId > 0;
  final hasRestaurantData = restaurantData != null && restaurantData.isNotEmpty;
  
  final isAdm = isAdmByUserType || isAdmByTipo || isAdmByField || hasRestaurantId || hasRestaurantData;


  if (isAdm) {
    if (hasRestaurantData) {
      print('➡️ Indo para admRestaurantHome');
      _goTo('/admRestaurantHome');
    } else {
      print('➡️ Indo para createAdmRestaurant');
      _goTo('/createAdmRestaurant');
    }
  } else {
    print('➡️ Indo para clientProfile');
    _goTo('/clientProfile');
  }
}


  void _goTo(String route) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, child) {
        final t = _bgController.value;

        final color1 = Color.lerp(
          const Color(0xFF9D00FF),
          const Color(0xFF00FFA3),
          t,
        )!;
        final color2 = Color.lerp(
          const Color(0xFF00FFA3),
          const Color(0xFF9D00FF),
          t,
        )!;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: Transform.rotate(
                      angle:
                          math.sin(_logoController.value * math.pi) * 0.05,
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 130,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: const Text(
                        "Meal4You",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

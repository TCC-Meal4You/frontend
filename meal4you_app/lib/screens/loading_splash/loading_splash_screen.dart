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
  late Animation<double> _logoRotation;

  late AnimationController _textController;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  late AnimationController _bgController;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  late AnimationController _particlesController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: -math.pi * 2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoController.forward();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(begin: const Offset(0, 1.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    Future.delayed(const Duration(milliseconds: 800), () {
      _textController.forward();
    });

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    Future.delayed(const Duration(seconds: 5), _checkLogin);
  }

  Future<void> _checkLogin() async {
    final token = await UserTokenSaving.getToken();
    final userData = await UserTokenSaving.getUserData();

    print('🔍 DEBUG SPLASH - Token: ${token != null ? "existe" : "null"}');
    print('🔍 DEBUG SPLASH - UserData: $userData');

    if (token == null || userData == null) {
      print('➡️ Sem token ou userData, indo para profileChoice');
      _goTo('/profileChoice');
      return;
    }

    final restaurantId = await UserTokenSaving.getRestaurantId();
    final restaurantData =
        await UserTokenSaving.getRestaurantDataForCurrentUser();

    print('🔍 DEBUG SPLASH - RestaurantId: $restaurantId');
    print(
      '🔍 DEBUG SPLASH - RestaurantData: ${restaurantData != null ? "existe" : "null"}',
    );

    final userType = userData['userType'];
    final tipo = userData['tipo'];
    final isAdmField = userData['isAdm'];

    print('🔍 DEBUG SPLASH - userType: $userType');
    print('🔍 DEBUG SPLASH - tipo: $tipo');
    print('🔍 DEBUG SPLASH - isAdm: $isAdmField');

    if (restaurantData != null && restaurantData.isNotEmpty) {
      print('✅ Admin com restaurante -> admRestaurantHome');
      _goTo('/admRestaurantHome');
      return;
    }

    if (restaurantId != null && restaurantId > 0) {
      print('⚠️ Admin sem restaurante (tem ID) -> createAdmRestaurant');
      _goTo('/createAdmRestaurant');
      return;
    }

    final isAdmByUserType = userType == 'adm';
    final isAdmByTipo = tipo == 'adm';
    final isAdmByField = isAdmField == true;

    if (isAdmByUserType || isAdmByTipo || isAdmByField) {
      print('✅ Admin sem restaurante (por tipo) -> createAdmRestaurant');
      _goTo('/createAdmRestaurant');
      return;
    }

    print('👤 Cliente -> clientProfile');
    _goTo('/clientProfile');
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
    _pulseController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bgController, _particlesController]),
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
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color1, color2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                ...List.generate(8, (index) {
                  final delay = index * 0.125;
                  final progress = (_particlesController.value + delay) % 1.0;
                  final offset = Offset(
                    (index % 4) * 0.25 + math.sin(progress * math.pi * 2) * 0.1,
                    progress,
                  );

                  return Positioned(
                    left: MediaQuery.of(context).size.width * offset.dx,
                    top: MediaQuery.of(context).size.height * offset.dy,
                    child: Opacity(
                      opacity: (math.sin(progress * math.pi) * 0.3).clamp(
                        0.0,
                        1.0,
                      ),
                      child: Container(
                        width: 4 + (index % 3) * 2,
                        height: 4 + (index % 3) * 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: _pulseScale.value * 1.8,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      // ignore: deprecated_member_use
                                      color: Colors.white.withOpacity(
                                        0.2 * (1 - _pulseController.value),
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: _pulseScale.value * 1.3,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      // ignore: deprecated_member_use
                                      color: Colors.white.withOpacity(
                                        0.3 *
                                            (1 - _pulseController.value * 0.7),
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              ScaleTransition(
                                scale: _logoScale,
                                child: AnimatedBuilder(
                                  animation: _logoRotation,
                                  builder: (context, child) {
                                    return Transform.rotate(
                                      angle: _logoRotation.value,
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              // ignore: deprecated_member_use
                                              color: Colors.white.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 40,
                                              spreadRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.restaurant_menu_rounded,
                                          size: 100,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      SlideTransition(
                        position: _textSlide,
                        child: FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    Colors.white,
                                    // ignore: deprecated_member_use
                                    Colors.white.withOpacity(0.95),
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  "Meal4You",
                                  style: TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Ubuntu',
                                    letterSpacing: 2,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                "comida consciente",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Ubuntu',
                                  letterSpacing: 1.2,
                                  // ignore: deprecated_member_use
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Um impacto que vai além da fome",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Ubuntu',
                                  letterSpacing: 1.2,
                                  // ignore: deprecated_member_use
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

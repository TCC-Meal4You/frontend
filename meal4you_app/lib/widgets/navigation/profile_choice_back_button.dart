import 'package:flutter/material.dart';

class ProfileChoiceBackButton extends StatefulWidget {
  final String routeName;

  const ProfileChoiceBackButton({super.key, this.routeName = '/profileChoice'});

  @override
  State<ProfileChoiceBackButton> createState() =>
      _ProfileChoiceBackButtonState();
}

class _ProfileChoiceBackButtonState extends State<ProfileChoiceBackButton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _goBack() {
    Navigator.of(context).pushReplacementNamed(widget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(top: 0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) {
          setState(() => _pressed = false);
          _goBack();
        },
        child: AnimatedBuilder(
          animation: _controller ?? const AlwaysStoppedAnimation(0.5),
          builder: (context, child) {
            final t = _controller?.value ?? 0.5;
            final floatOffset = -3 + (t * 6);
            final scale = _pressed ? 0.96 : 1.0 + (t * 0.025);

            return Transform.translate(
              offset: Offset(0, floatOffset),
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFF9D00FF).withOpacity(0.6),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9D00FF).withOpacity(0.28),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF9D00FF), Color(0xFF0FE687)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.keyboard_double_arrow_left_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Trocar Perfil',
                    style: TextStyle(
                      color: Color(0xFF9D00FF),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
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

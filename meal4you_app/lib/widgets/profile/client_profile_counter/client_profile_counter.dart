import 'package:flutter/material.dart';

class ClientProfileCounter extends StatelessWidget {
  final String title;
  final int count;
  final bool isLoading;
  const ClientProfileCounter({
    super.key,
    required this.title,
    required this.count,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: isLoading
                  ? const _LoadingDots(key: ValueKey('counter-loading'))
                  : Text(
                      count.toString(),
                      key: const ValueKey('counter-value'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 157, 0, 255),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots({super.key});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotValue(int index) {
    final progress = (_controller.value + index * 0.18) % 1.0;
    final wave = (progress < 0.5) ? progress : 1 - progress;
    return 0.45 + (wave * 1.1);
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = _dotValue(index);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 157, 0, 255),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _dot(0),
        const SizedBox(width: 5),
        _dot(1),
        const SizedBox(width: 5),
        _dot(2),
      ],
    );
  }
}

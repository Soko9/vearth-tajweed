import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/app_logo_mark.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7FBFD), Color(0xFFEFF6F8), Color(0xFFE7F0F3)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Stack(
            children: [
              const _BackgroundBlob(
                top: -110,
                right: -90,
                size: 250,
                color: Color(0x223B8A89),
              ),
              const _BackgroundBlob(
                bottom: -120,
                left: -80,
                size: 270,
                color: Color(0x1F245C66),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 28),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final t = sin(_controller.value * pi);
                            return Transform.translate(
                              offset: Offset(0, -5 * t),
                              child: child,
                            );
                          },
                          child: const AppLogoLockup(),
                        ),
                      ),
                    ),
                    const Text(
                      'تعلّم الأحكام، تدرّب يوميًا، وارتقِ في التلاوة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF35545D),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: const LinearProgressIndicator(
                        minHeight: 6,
                        backgroundColor: Color(0xFFD9E6EB),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2F7278),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundBlob extends StatelessWidget {
  const _BackgroundBlob({
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.size,
    required this.color,
  });

  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

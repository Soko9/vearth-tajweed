import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final AnimationController _orbitController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFEAF1F4)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _SplashBackdrop()),
            SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: Listenable.merge([
                            _pulseController,
                            _orbitController,
                          ]),
                          builder: (context, _) {
                            final pulse =
                                0.97 + (_pulseController.value * 0.06);
                            final orbit = _orbitController.value * 2 * math.pi;

                            return Transform.scale(
                              scale: pulse,
                              child: SizedBox(
                                width: 206,
                                height: 206,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 180,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.88,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF245C66,
                                            ).withValues(alpha: 0.15),
                                            blurRadius: 24,
                                            spreadRadius: 1,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _OrbitDotsPainter(
                                          angle: orbit,
                                          ringColor: const Color(
                                            0xFF245C66,
                                          ).withValues(alpha: 0.24),
                                          dotColor: const Color(0xFF245C66),
                                        ),
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      'assets/branding/tajweed_logo.svg',
                                      width: 122,
                                      height: 122,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'تجويد',
                          style: textTheme.headlineMedium?.copyWith(
                            color: const Color(0xFF1B4A53),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تحفة الأطفال',
                          style: textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF245C66),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'جاري تجهيز التمارين...',
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF48646D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _LoadingDots(),
                      ],
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: _PublisherFooterMark(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -70,
          top: -70,
          child: Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF245C66).withValues(alpha: 0.10),
            ),
          ),
        ),
        Positioned(
          right: -50,
          top: 120,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4D9B8A).withValues(alpha: 0.11),
            ),
          ),
        ),
        Positioned(
          left: 28,
          right: 28,
          bottom: 80,
          child: Container(
            height: 92,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF245C66).withValues(alpha: 0.12),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.42),
                  Colors.white.withValues(alpha: 0.10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrbitDotsPainter extends CustomPainter {
  const _OrbitDotsPainter({
    required this.angle,
    required this.ringColor,
    required this.dotColor,
  });

  final double angle;
  final Color ringColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = ringColor;

    canvas.drawCircle(center, radius, ringPaint);

    final dotPaint = Paint()..color = dotColor;
    final accentPaint = Paint()..color = const Color(0xFFE07A5F);

    final dots = [0.0, 2.1, 4.2];
    for (var i = 0; i < dots.length; i++) {
      final current = angle + dots[i];
      final offset = Offset(
        center.dx + radius * math.cos(current),
        center.dy + radius * math.sin(current),
      );
      canvas.drawCircle(
        offset,
        i == 0 ? 5 : 3.5,
        i == 0 ? accentPaint : dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitDotsPainter oldDelegate) {
    return oldDelegate.angle != angle ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.dotColor != dotColor;
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = (_controller.value - (index * 0.18)).clamp(0.0, 1.0);
            final opacity =
                0.30 + (0.70 * (1 - (phase - 0.5).abs() * 2).clamp(0.0, 1.0));
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF245C66).withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

class _PublisherFooterMark extends StatelessWidget {
  const _PublisherFooterMark();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Developed by Vearth',
          style: textTheme.labelMedium?.copyWith(
            color: const Color(0xFF5F7177),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 8),
        SvgPicture.asset(
          'assets/branding/vearth_logo.svg',
          width: 84,
          height: 22,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

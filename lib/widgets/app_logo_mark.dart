import 'package:flutter/material.dart';

class AppLogoMark extends StatelessWidget {
  const AppLogoMark({super.key, this.size = 96, this.showShadow = true});

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF245C66), Color(0xFF3B8A89)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF245C66).withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.84,
            height: size * 0.84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
          ),
          Icon(Icons.menu_book_rounded, size: size * 0.5, color: Colors.white),
          Positioned(
            top: size * 0.2,
            left: size * 0.2,
            child: _Crescent(size: size * 0.2),
          ),
          Positioned(
            right: size * 0.18,
            bottom: size * 0.2,
            child: Container(
              width: size * 0.08,
              height: size * 0.08,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppLogoLockup extends StatelessWidget {
  const AppLogoLockup({
    super.key,
    this.markSize = 102,
    this.title = 'تجويد',
    this.subtitle = 'تحفة الأطفال',
    this.textColor = const Color(0xFF214A53),
    this.center = true,
  });

  final double markSize;
  final String title;
  final String subtitle;
  final Color textColor;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        AppLogoMark(size: markSize),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: textColor,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: textColor.withValues(alpha: 0.86),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Crescent extends StatelessWidget {
  const _Crescent({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE2A3),
            ),
          ),
          Positioned(
            right: 0,
            top: size * 0.12,
            child: Container(
              width: size * 0.72,
              height: size * 0.72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2F7B7E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

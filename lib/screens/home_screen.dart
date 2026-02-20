import 'package:flutter/material.dart';

import '../data/tajweed_content.dart';
import '../models/practice_models.dart';
import '../theme/app_theme.dart';
import 'analysis_screen.dart';
import 'lessons_screen.dart';
import 'practice/practice_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.attempts,
    required this.onAttemptSaved,
    super.key,
  });

  final List<PracticeAttempt> attempts;
  final Future<void> Function(PracticeAttempt attempt) onAttemptSaved;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const LessonsScreen(),
      PracticeSetupScreen(
        sections: tajweedSections,
        onAttemptSaved: widget.onAttemptSaved,
      ),
      AnalysisScreen(attempts: widget.attempts, rules: allRules),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(title: Text(_titleForIndex(_selectedIndex))),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE2F2F6), Color(0xFFF9EEE8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: 70,
                child: _softBlob(color: const Color(0x5528A3B8), size: 170),
              ),
              Positioned(
                left: -55,
                top: 240,
                child: _softBlob(color: const Color(0x55F39A7E), size: 190),
              ),
              Positioned(
                right: -60,
                bottom: 80,
                child: _softBlob(color: const Color(0x554FC3A1), size: 180),
              ),
              Column(
                children: [
                  const SizedBox(height: 90),
                  _HeroHeader(attemptsCount: widget.attempts.length),
                  const SizedBox(height: 8),
                  Expanded(child: pages[_selectedIndex]),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.auto_stories_rounded),
                  label: 'الدروس',
                ),
                NavigationDestination(
                  icon: Icon(Icons.workspace_premium_rounded),
                  label: 'التدريب',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_rounded),
                  label: 'التحليل',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'تحفة الأطفال';
      case 1:
        return 'تدريب ذكي';
      case 2:
        return 'لوحة التقدّم';
      default:
        return 'تجويد';
    }
  }

  Widget _softBlob({required Color color, required double size}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 80, spreadRadius: 15),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.attemptsCount});

  final int attemptsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F6272), Color(0xFF2297AD), Color(0xFF25997A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تجويد بلغة سهلة وتصميم حديث',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'اقرأ الحكم، تدرب، وتابع أدق نقاط القوة والضعف.',
                  style: TextStyle(color: Color(0xFFF0FBFF), fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'عدد التدريبات: $attemptsCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

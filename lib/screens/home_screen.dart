import 'package:flutter/material.dart';

import '../data/tajweed_content.dart';
import '../models/practice_models.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_numbers.dart';
import '../widgets/mono_numbers_text.dart';
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
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(title: Text(_titleForIndex(_selectedIndex))),
        body: Column(
          children: [
            const SizedBox(height: 6),
            _HeroHeader(attemptsCount: widget.attempts.length),
            const SizedBox(height: 8),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFE2E9EE)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x180A2A33),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
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
          colors: [Color(0xFF255E67), Color(0xFF387D88)],
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
                  style: TextStyle(color: Color(0xFFEDF4F6), fontSize: 16),
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
                  child: MonoNumbersText(
                    'عدد التدريبات: ${arabicInt(attemptsCount)}',
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

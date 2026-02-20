import 'package:flutter/material.dart';

import '../data/tajweed_content.dart';
import '../models/practice_models.dart';
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
        appBar: AppBar(title: Text(_titleForIndex(_selectedIndex))),
        body: Column(
          children: [
            const _HeroHeader(),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_rounded),
              label: 'الدروس',
            ),
            NavigationDestination(
              icon: Icon(Icons.quiz_rounded),
              label: 'التدريب',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_rounded),
              label: 'التحليل',
            ),
          ],
        ),
      ),
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'تحفة الأطفال - الأحكام';
      case 1:
        return 'منطقة التدريب';
      case 2:
        return 'المتابعة والتحليل';
      default:
        return 'تجويد';
    }
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F5132), Color(0xFF1E7A4D)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'رحلة مبسطة في أحكام التجويد',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'تعلم القاعدة، شاهد أمثلة، ثم اختبر نفسك وتابع تقدّمك.',
            style: TextStyle(color: Color(0xFFEAF7F0), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

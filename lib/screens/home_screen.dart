import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/tajweed_content.dart';
import '../models/practice_models.dart';
import '../services/update_checker_service.dart';
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
  static const UpdateCheckerService _updateChecker = UpdateCheckerService(
    owner: 'Soko9',
    repo: 'vearth-tajweed',
  );

  int _selectedIndex = 0;
  bool _isCheckingUpdate = false;
  String? _lastPromptedVersion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForAppUpdates(auto: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final pages = [
      const LessonsScreen(),
      PracticeSetupScreen(
        sections: tajweedSections,
        onAttemptSaved: widget.onAttemptSaved,
        onOpenAnalysis: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
      AnalysisScreen(attempts: widget.attempts, rules: allRules),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(_titleForIndex(_selectedIndex)),
          actions: [
            IconButton(
              tooltip: 'التحقق من التحديث',
              onPressed: _isCheckingUpdate
                  ? null
                  : () => _checkForAppUpdates(auto: false),
              icon: _isCheckingUpdate
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.system_update_alt_rounded),
            ),
          ],
        ),
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
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppTheme.border(context)),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.28)
                      : const Color(0x180A2A33),
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

  Future<void> _checkForAppUpdates({required bool auto}) async {
    if (_isCheckingUpdate) {
      return;
    }
    setState(() {
      _isCheckingUpdate = true;
    });

    final result = await _updateChecker.checkForUpdate();

    if (!mounted) {
      return;
    }
    setState(() {
      _isCheckingUpdate = false;
    });

    if (result == null) {
      if (!auto) {
        _showMessage('تعذر التحقق من التحديث الآن.');
      }
      return;
    }

    if (!result.hasUpdate) {
      if (!auto) {
        _showMessage('أنت على أحدث إصدار حاليًا.');
      }
      return;
    }

    if (auto && _lastPromptedVersion == result.latestVersion) {
      return;
    }

    _lastPromptedVersion = result.latestVersion;
    await _showUpdateDialog(result);
  }

  Future<void> _showUpdateDialog(UpdateCheckResult result) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تحديث جديد متاح'),
          content: Text(
            'الإصدار الحالي: ${result.currentVersion}\n'
            'الإصدار الجديد: ${result.latestVersion}\n\n'
            'هل تريد تنزيل التحديث الآن؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('لاحقًا'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final launched = await launchUrl(
                  Uri.parse(result.releaseUrl),
                  mode: LaunchMode.externalApplication,
                );
                if (!launched && mounted) {
                  _showMessage('تعذر فتح رابط التحميل.');
                }
              },
              child: const Text('تنزيل'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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

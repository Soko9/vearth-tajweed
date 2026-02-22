import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/practice_models.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/practice_storage_service.dart';
import 'theme/app_theme.dart';

class TajweedApp extends StatefulWidget {
  const TajweedApp({super.key});

  @override
  State<TajweedApp> createState() => _TajweedAppState();
}

class _TajweedAppState extends State<TajweedApp> {
  static const Duration _minimumSplashDuration = Duration(milliseconds: 1800);
  final PracticeStorageService _storageService = PracticeStorageService();
  List<PracticeAttempt> _attempts = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    final start = DateTime.now();
    final attempts = await _storageService.loadAttempts();
    final elapsed = DateTime.now().difference(start);
    if (elapsed < _minimumSplashDuration) {
      await Future<void>.delayed(_minimumSplashDuration - elapsed);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _attempts = attempts;
      _isLoading = false;
    });
  }

  Future<void> _onAttemptSaved(PracticeAttempt attempt) async {
    await _storageService.saveAttempt(attempt);
    if (!mounted) {
      return;
    }
    setState(() {
      _attempts = [attempt, ..._attempts];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تجويد - تحفة الأطفال',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _isLoading
            ? const SplashScreen(key: ValueKey('splash'))
            : HomeScreen(
                key: const ValueKey('home'),
                attempts: _attempts,
                onAttemptSaved: _onAttemptSaved,
              ),
      ),
    );
  }
}

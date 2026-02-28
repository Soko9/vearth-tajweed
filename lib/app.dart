import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/practice_models.dart';
import 'screens/app_splash_screen.dart';
import 'screens/home_screen.dart';
import 'services/practice_storage_service.dart';
import 'services/theme_mode_storage_service.dart';
import 'theme/app_theme.dart';

class TajweedApp extends StatefulWidget {
  const TajweedApp({super.key});

  @override
  State<TajweedApp> createState() => _TajweedAppState();
}

class _TajweedAppState extends State<TajweedApp> {
  final PracticeStorageService _storageService = PracticeStorageService();
  final ThemeModeStorageService _themeModeStorageService =
      ThemeModeStorageService();
  List<PracticeAttempt> _attempts = const [];
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final attemptsFuture = _storageService.loadAttempts();
    final themeModeFuture = _themeModeStorageService.loadThemeMode();
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) {
      return;
    }

    final attempts = await attemptsFuture;
    final themeMode = await themeModeFuture;
    if (!mounted) {
      return;
    }

    setState(() {
      _attempts = attempts;
      _themeMode = themeMode;
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

  void _toggleThemeMode() {
    final nextMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setState(() {
      _themeMode = nextMode;
    });
    unawaited(_themeModeStorageService.saveThemeMode(nextMode));
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
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _isLoading
          ? const AppSplashScreen()
          : HomeScreen(
              attempts: _attempts,
              onAttemptSaved: _onAttemptSaved,
              themeMode: _themeMode,
              onToggleThemeMode: _toggleThemeMode,
            ),
    );
  }
}

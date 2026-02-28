import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/practice_models.dart';
import 'screens/app_splash_screen.dart';
import 'screens/home_screen.dart';
import 'services/practice_storage_service.dart';
import 'theme/app_theme.dart';

class TajweedApp extends StatefulWidget {
  const TajweedApp({super.key});

  @override
  State<TajweedApp> createState() => _TajweedAppState();
}

class _TajweedAppState extends State<TajweedApp> {
  final PracticeStorageService _storageService = PracticeStorageService();
  List<PracticeAttempt> _attempts = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttempts();
  }

  Future<void> _loadAttempts() async {
    final attemptsFuture = _storageService.loadAttempts();
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) {
      return;
    }

    final attempts = await attemptsFuture;
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
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _isLoading
          ? const AppSplashScreen()
          : HomeScreen(attempts: _attempts, onAttemptSaved: _onAttemptSaved),
    );
  }
}

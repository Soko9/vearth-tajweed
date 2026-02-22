import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final startedAt = DateTime.now();
  await _initializeFirebase();
  final elapsed = DateTime.now().difference(startedAt);
  const minimumSplash = Duration(seconds: 2);
  if (elapsed < minimumSplash) {
    await Future<void>.delayed(minimumSplash - elapsed);
  }
  runApp(const TajweedApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Keep app functional offline when Firebase config is missing.
  }
}

import 'package:flutter/widgets.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final startedAt = DateTime.now();
  final elapsed = DateTime.now().difference(startedAt);
  const minimumSplash = Duration(seconds: 2);
  if (elapsed < minimumSplash) {
    await Future<void>.delayed(minimumSplash - elapsed);
  }
  runApp(const TajweedApp());
}

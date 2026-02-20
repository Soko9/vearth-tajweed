import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/practice_models.dart';

class PracticeStorageService {
  static const String _attemptsKey = 'tajweed_practice_attempts_v1';

  Future<List<PracticeAttempt>> loadAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_attemptsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => PracticeAttempt.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> saveAttempt(PracticeAttempt attempt) async {
    final attempts = await loadAttempts();
    final updated = [attempt, ...attempts];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _attemptsKey,
      jsonEncode(updated.map((session) => session.toJson()).toList()),
    );
  }
}

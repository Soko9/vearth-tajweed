import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/practice_models.dart';
import '../models/tajweed_models.dart';

class FirebasePracticeSourceService {
  FirebasePracticeSourceService({FirebaseFirestore? firestore, Random? random})
    : _firestore = firestore,
      _random = random ?? Random();

  final FirebaseFirestore? _firestore;
  final Random _random;

  Future<List<PracticeQuestion>> fetchQuestions({
    required PracticeConfig config,
    required List<TajweedSection> sections,
  }) async {
    try {
      if (Firebase.apps.isEmpty) {
        return const [];
      }

      final firestore = _firestore ?? FirebaseFirestore.instance;
      final scopedRuleIds = _resolveScopedRuleIds(config, sections);
      if (scopedRuleIds.isEmpty) {
        return const [];
      }

      final snapshot = await firestore
          .collection('practice_questions')
          .where('enabled', isEqualTo: true)
          .where('practiceType', isEqualTo: config.practiceType.name)
          .limit(max(config.questionCount * 4, 40))
          .get();

      final questions = snapshot.docs
          .map((doc) => _mapQuestion(doc, scopedRuleIds, config.practiceType))
          .whereType<PracticeQuestion>()
          .toList();

      if (questions.isEmpty) {
        return const [];
      }

      questions.shuffle(_random);
      if (questions.length >= config.questionCount) {
        return questions.take(config.questionCount).toList();
      }

      return _repeatToTargetCount(questions, config.questionCount);
    } on FirebaseException {
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Set<String> _resolveScopedRuleIds(
    PracticeConfig config,
    List<TajweedSection> sections,
  ) {
    switch (config.scope) {
      case PracticeScope.all:
        return sections
            .expand((section) => section.rules)
            .map((rule) => rule.id)
            .toSet();
      case PracticeScope.section:
        return sections
            .where((section) => section.id == config.sectionId)
            .expand((section) => section.rules)
            .map((rule) => rule.id)
            .toSet();
      case PracticeScope.rule:
        if (config.ruleId == null || config.ruleId!.isEmpty) {
          return const {};
        }
        return {config.ruleId!};
    }
  }

  PracticeQuestion? _mapQuestion(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Set<String> scopedRuleIds,
    PracticeType practiceType,
  ) {
    final data = doc.data();
    final ruleId = (data['ruleId'] as String?)?.trim() ?? '';
    if (ruleId.isEmpty || !scopedRuleIds.contains(ruleId)) {
      return null;
    }

    final explanation = (data['explanation'] as String?)?.trim() ?? '';
    if (practiceType == PracticeType.letterMatch) {
      final sourceText = (data['sourceText'] as String?)?.trim() ?? '';
      final validLetters = (data['validLetters'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .map(_normalizeArabicLetter)
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();
      final prompt = (data['prompt'] as String?)?.trim();
      if (sourceText.isEmpty || validLetters.isEmpty) {
        return null;
      }
      return PracticeQuestion(
        id: doc.id,
        ruleId: ruleId,
        prompt: prompt?.isNotEmpty == true
            ? prompt!
            : 'اختر حرفًا من النص يحقق الحكم.',
        explanation: explanation,
        sourceText: sourceText,
        validLetters: validLetters,
      );
    }

    final prompt = (data['prompt'] as String?)?.trim() ?? '';
    final options = (data['options'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final correctOptionIndex = data['correctOptionIndex'] as int? ?? -1;

    if (prompt.isEmpty || options.length < 2) {
      return null;
    }
    if (correctOptionIndex < 0 || correctOptionIndex >= options.length) {
      return null;
    }

    return PracticeQuestion(
      id: doc.id,
      ruleId: ruleId,
      prompt: prompt,
      options: options,
      correctOptionIndex: correctOptionIndex,
      explanation: explanation,
    );
  }

  String _normalizeArabicLetter(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final withoutMarks = trimmed.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    );
    final match = RegExp(r'[ء-ي]').firstMatch(withoutMarks);
    return match?.group(0) ?? '';
  }

  List<PracticeQuestion> _repeatToTargetCount(
    List<PracticeQuestion> source,
    int targetCount,
  ) {
    final repeated = <PracticeQuestion>[];
    while (repeated.length < targetCount) {
      source.shuffle(_random);
      repeated.addAll(source);
    }
    return repeated.take(targetCount).toList();
  }
}

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/practice_models.dart';
import '../models/tajweed_models.dart';

class FirebasePracticeSourceService {
  FirebasePracticeSourceService({
    FirebaseFirestore? firestore,
    Random? random,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _random = random ?? Random();

  final FirebaseFirestore _firestore;
  final Random _random;

  Future<List<PracticeQuestion>> fetchQuestions({
    required PracticeConfig config,
    required List<TajweedSection> sections,
  }) async {
    try {
      final scopedRuleIds = _resolveScopedRuleIds(config, sections);
      if (scopedRuleIds.isEmpty) {
        return const [];
      }

      final snapshot = await _firestore
          .collection('practice_questions')
          .where('enabled', isEqualTo: true)
          .where('practiceType', isEqualTo: config.practiceType.name)
          .limit(max(config.questionCount * 4, 40))
          .get();

      final questions = snapshot.docs
          .map((doc) => _mapQuestion(doc, scopedRuleIds))
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
  ) {
    final data = doc.data();
    final ruleId = (data['ruleId'] as String?)?.trim() ?? '';
    if (ruleId.isEmpty || !scopedRuleIds.contains(ruleId)) {
      return null;
    }

    final prompt = (data['prompt'] as String?)?.trim() ?? '';
    final options = (data['options'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final correctOptionIndex = data['correctOptionIndex'] as int? ?? -1;
    final explanation = (data['explanation'] as String?)?.trim() ?? '';

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

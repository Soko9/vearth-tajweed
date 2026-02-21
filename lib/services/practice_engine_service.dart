import 'dart:math';

import '../models/practice_models.dart';
import '../models/tajweed_models.dart';
import 'firebase_practice_source_service.dart';

class GeneratedPracticeQuestions {
  const GeneratedPracticeQuestions({
    required this.questions,
    required this.usedOnlineSource,
  });

  final List<PracticeQuestion> questions;
  final bool usedOnlineSource;
}

class PracticeEngineService {
  PracticeEngineService({
    FirebasePracticeSourceService? onlineSource,
    Random? random,
  }) : _onlineSource = onlineSource ?? FirebasePracticeSourceService(),
       _random = random ?? Random();

  final FirebasePracticeSourceService _onlineSource;
  final Random _random;

  Future<List<PracticeQuestion>> generateQuestions({
    required PracticeConfig config,
    required List<TajweedSection> sections,
  }) async =>
      (await generateQuestionBatch(config: config, sections: sections))
          .questions;

  Future<GeneratedPracticeQuestions> generateQuestionBatch({
    required PracticeConfig config,
    required List<TajweedSection> sections,
  }) async {
    final scopedRules = _resolveRules(config, sections);
    if (scopedRules.isEmpty) {
      return const GeneratedPracticeQuestions(
        questions: [],
        usedOnlineSource: false,
      );
    }

    if (config.useOnlineSource) {
      final onlineQuestions = await _onlineSource.fetchQuestions(
        config: config,
        sections: sections,
      );
      if (onlineQuestions.isNotEmpty) {
        return GeneratedPracticeQuestions(
          questions: onlineQuestions,
          usedOnlineSource: true,
        );
      }
    }

    final sectionMap = {for (final section in sections) section.id: section};
    final allRules = [for (final section in sections) ...section.rules];
    final generatedOffline = List<PracticeQuestion>.generate(config.questionCount, (
      index,
    ) {
      final rule = scopedRules[_random.nextInt(scopedRules.length)];
      final id =
          '${config.practiceType.name}_${index}_${rule.id}_${DateTime.now().microsecondsSinceEpoch}';

      switch (config.practiceType) {
        case PracticeType.mcq:
          return _buildMcqQuestion(id: id, rule: rule, rulesPool: allRules);
        case PracticeType.trueFalse:
          return _buildTrueFalseQuestion(id: id, rule: rule);
        case PracticeType.letterMatch:
          return _buildLetterMatchQuestion(
            id: id,
            rule: rule,
            rulesPool: allRules,
          );
        case PracticeType.sectionMatch:
          return _buildSectionMatchQuestion(
            id: id,
            rule: rule,
            sections: sections,
            sectionMap: sectionMap,
          );
      }
    });

    return GeneratedPracticeQuestions(
      questions: generatedOffline,
      usedOnlineSource: false,
    );
  }

  List<TajweedRule> _resolveRules(
    PracticeConfig config,
    List<TajweedSection> sections,
  ) {
    switch (config.scope) {
      case PracticeScope.all:
        return [for (final section in sections) ...section.rules];
      case PracticeScope.section:
        return sections
            .where((section) => section.id == config.sectionId)
            .expand((section) => section.rules)
            .toList();
      case PracticeScope.rule:
        return sections
            .expand((section) => section.rules)
            .where((rule) => rule.id == config.ruleId)
            .toList();
    }
  }

  PracticeQuestion _buildMcqQuestion({
    required String id,
    required TajweedRule rule,
    required List<TajweedRule> rulesPool,
  }) {
    final example = rule.examples[_random.nextInt(rule.examples.length)];
    final otherNames = rulesPool
        .map((item) => item.name)
        .where((name) => name != rule.name)
        .toSet()
        .toList();
    otherNames.shuffle(_random);

    final options = <String>[rule.name, ...otherNames.take(3)]
      ..shuffle(_random);
    if (options.length < 2) {
      final fallback = rulesPool
          .map((item) => item.name)
          .firstWhere((item) => item != rule.name, orElse: () => '');
      if (fallback.isNotEmpty) {
        options.add(fallback);
      }
    }

    return PracticeQuestion(
      id: id,
      ruleId: rule.id,
      prompt: 'ما الحكم التجويدي في المثال: "${example.text}"؟',
      options: options,
      correctOptionIndex: options.indexOf(rule.name),
      explanation:
          'الإجابة الصحيحة: ${rule.name}. ${example.note} | حروف الحكم: ${rule.letters.join('، ')}.',
    );
  }

  PracticeQuestion _buildTrueFalseQuestion({
    required String id,
    required TajweedRule rule,
  }) {
    final statementIsCorrect = _random.nextBool();
    String shownLetters;

    if (statementIsCorrect) {
      shownLetters = rule.letters.take(4).join('، ');
    } else {
      final lettersPool = 'ءابتثجحخدذرزسشصضطظعغفقكلمنهوي'.split('');
      lettersPool.shuffle(_random);
      shownLetters = lettersPool.take(4).join('، ');
      if (shownLetters == rule.letters.take(4).join('، ')) {
        shownLetters = lettersPool.reversed.take(4).join('، ');
      }
    }

    return PracticeQuestion(
      id: id,
      ruleId: rule.id,
      prompt: 'صح أم خطأ: من حروف ${rule.name}: $shownLetters',
      options: const ['صح', 'خطأ'],
      correctOptionIndex: statementIsCorrect ? 0 : 1,
      explanation: 'حروف ${rule.name}: ${rule.letters.join('، ')}.',
    );
  }

  PracticeQuestion _buildLetterMatchQuestion({
    required String id,
    required TajweedRule rule,
    required List<TajweedRule> rulesPool,
  }) {
    final letters = rule.letters
        .where((item) => item.trim().isNotEmpty)
        .toList();
    final correctLetter = letters[_random.nextInt(letters.length)];

    final wrongLetters = rulesPool
        .where((item) => item.id != rule.id)
        .expand((item) => item.letters)
        .where((item) => item != correctLetter)
        .toSet()
        .toList();

    wrongLetters.shuffle(_random);
    final options = <String>[correctLetter, ...wrongLetters.take(3)]
      ..shuffle(_random);
    if (options.length < 2) {
      final fallbackLetter = 'ءابتثجحخدذرزسشصضطظعغفقكلمنهوي'
          .split('')
          .firstWhere((item) => item != correctLetter, orElse: () => '');
      if (fallbackLetter.isNotEmpty) {
        options.add(fallbackLetter);
      }
    }

    return PracticeQuestion(
      id: id,
      ruleId: rule.id,
      prompt: 'أي خيار يعد من حروف ${rule.name}؟',
      options: options,
      correctOptionIndex: options.indexOf(correctLetter),
      explanation: 'الحرف الصحيح: $correctLetter ضمن حروف ${rule.name}.',
    );
  }

  PracticeQuestion _buildSectionMatchQuestion({
    required String id,
    required TajweedRule rule,
    required List<TajweedSection> sections,
    required Map<String, TajweedSection> sectionMap,
  }) {
    final section = sectionMap[rule.sectionId];
    final sectionTitle = section?.title ?? '';

    final otherSections = sections
        .where((item) => item.id != rule.sectionId)
        .map((item) => item.title)
        .toList();
    otherSections.shuffle(_random);

    final options = <String>[sectionTitle, ...otherSections.take(3)]
      ..shuffle(_random);

    return PracticeQuestion(
      id: id,
      ruleId: rule.id,
      prompt: 'إلى أي قسم ينتمي حكم "${rule.name}"؟',
      options: options,
      correctOptionIndex: options.indexOf(sectionTitle),
      explanation: 'ينتمي ${rule.name} إلى قسم $sectionTitle.',
    );
  }
}

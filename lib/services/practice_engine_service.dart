import 'dart:math';

import '../data/tajweed_content.dart';
import '../models/practice_models.dart';
import '../models/tajweed_models.dart';
import 'firebase_practice_source_service.dart';

const List<String> _standardArabicLetters = [
  'ء',
  'ا',
  'ب',
  'ت',
  'ث',
  'ج',
  'ح',
  'خ',
  'د',
  'ذ',
  'ر',
  'ز',
  'س',
  'ش',
  'ص',
  'ض',
  'ط',
  'ظ',
  'ع',
  'غ',
  'ف',
  'ق',
  'ك',
  'ل',
  'م',
  'ن',
  'ه',
  'و',
  'ي',
];

const List<List<String>> _confusableLetterGroups = [
  ['ت', 'ث', 'ب', 'ن', 'ي'],
  ['ج', 'ح', 'خ'],
  ['د', 'ذ'],
  ['ر', 'ز'],
  ['س', 'ش'],
  ['ص', 'ض'],
  ['ط', 'ظ'],
  ['ع', 'غ'],
  ['ف', 'ق'],
  ['ك', 'ق'],
  ['ا', 'و', 'ي'],
  ['ه', 'ح'],
];

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
  int _questionIdCounter = 0;

  Future<List<PracticeQuestion>> generateQuestions({
    required PracticeConfig config,
    required List<TajweedSection> sections,
  }) async => (await generateQuestionBatch(
    config: config,
    sections: sections,
  )).questions;

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

    final eligibleRules = _eligibleRulesForType(
      config.practiceType,
      scopedRules,
    );
    if (eligibleRules.isEmpty) {
      return const GeneratedPracticeQuestions(
        questions: [],
        usedOnlineSource: false,
      );
    }

    final allRules = [for (final section in sections) ...section.rules];
    final questionPool = _buildQuestionPool(
      config: config,
      eligibleRules: eligibleRules,
      allRules: allRules,
      sections: sections,
    );
    if (questionPool.isEmpty) {
      return const GeneratedPracticeQuestions(
        questions: [],
        usedOnlineSource: false,
      );
    }

    return GeneratedPracticeQuestions(
      questions: _pickQuestions(
        pool: questionPool,
        targetCount: config.questionCount,
        practiceType: config.practiceType,
      ),
      usedOnlineSource: false,
    );
  }

  List<TajweedRule> _eligibleRulesForType(
    PracticeType type,
    List<TajweedRule> rules,
  ) {
    final withLetters = rules
        .where((rule) => _lettersOf(rule).any((item) => item.trim().isNotEmpty))
        .toList();

    switch (type) {
      case PracticeType.mcq:
      case PracticeType.trueFalse:
      case PracticeType.sectionMatch:
      case PracticeType.definitionMatch:
        return rules;
      case PracticeType.letterMatch:
        return withLetters.where((rule) {
          final normalized = _lettersOf(
            rule,
            singleCharacterOnly: true,
          ).toSet();
          return normalized.isNotEmpty &&
              _standardArabicLetters.any((item) => !normalized.contains(item));
        }).toList();
    }
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

  List<PracticeQuestion> _buildQuestionPool({
    required PracticeConfig config,
    required List<TajweedRule> eligibleRules,
    required List<TajweedRule> allRules,
    required List<TajweedSection> sections,
  }) {
    switch (config.practiceType) {
      case PracticeType.mcq:
        return _buildMcqPool(eligibleRules: eligibleRules, allRules: allRules);
      case PracticeType.trueFalse:
        return _buildTrueFalsePool(
          eligibleRules: eligibleRules,
          allRules: allRules,
          sections: sections,
        );
      case PracticeType.letterMatch:
        return _buildLetterMatchPool(
          eligibleRules: eligibleRules,
          allRules: allRules,
        );
      case PracticeType.sectionMatch:
        return _buildSectionMatchPool(
          eligibleRules: eligibleRules,
          allRules: allRules,
          sections: sections,
        );
      case PracticeType.definitionMatch:
        return _buildDefinitionMatchPool(
          eligibleRules: eligibleRules,
          allRules: allRules,
          sections: sections,
        );
    }
  }

  List<PracticeQuestion> _buildMcqPool({
    required List<TajweedRule> eligibleRules,
    required List<TajweedRule> allRules,
  }) {
    final pool = <PracticeQuestion>[];
    for (final rule in eligibleRules) {
      final options = _buildRuleOptions(correct: rule, rulesPool: allRules);
      final correctIndex = options.indexOf(rule.name);
      if (options.length < 2 || correctIndex < 0) {
        continue;
      }

      for (final example in rule.examples) {
        pool.add(
          PracticeQuestion(
            id: _nextQuestionId(PracticeType.mcq, rule.id),
            ruleId: rule.id,
            prompt: 'ما الحكم التجويدي الأدق للمثال: "${example.text}"؟',
            options: options,
            correctOptionIndex: correctIndex,
            explanation: 'الصحيح: ${rule.name}. ${example.note}',
          ),
        );
      }

      pool.add(
        PracticeQuestion(
          id: _nextQuestionId(PracticeType.mcq, '${rule.id}_description'),
          ruleId: rule.id,
          prompt: 'أي حكم ينطبق على الوصف: ${rule.description}',
          options: options,
          correctOptionIndex: correctIndex,
          explanation: 'هذا الوصف هو تعريف ${rule.name}.',
        ),
      );

      final letterSnippet = _lettersOf(
        rule,
        singleCharacterOnly: true,
      ).take(6).join('، ');
      if (letterSnippet.isNotEmpty) {
        pool.add(
          PracticeQuestion(
            id: _nextQuestionId(PracticeType.mcq, '${rule.id}_letters'),
            ruleId: rule.id,
            prompt: 'الحروف التالية تشير غالبًا لأي حكم: $letterSnippet ؟',
            options: options,
            correctOptionIndex: correctIndex,
            explanation: 'الحروف المعروضة تابعة لحكم ${rule.name}.',
          ),
        );
      }

      final poemLines = rulePoemExcerptsById(rule.id);
      if (poemLines.isNotEmpty) {
        final line = poemLines[_random.nextInt(poemLines.length)];
        pool.add(
          PracticeQuestion(
            id: _nextQuestionId(PracticeType.mcq, '${rule.id}_poem'),
            ruleId: rule.id,
            prompt: 'البيت التالي يدل على أي حكم: "$line"؟',
            options: options,
            correctOptionIndex: correctIndex,
            explanation: 'هذا البيت متعلق بباب ${rule.name}.',
          ),
        );
      }
    }
    return pool;
  }

  List<PracticeQuestion> _buildTrueFalsePool({
    required List<TajweedRule> eligibleRules,
    required List<TajweedRule> allRules,
    required List<TajweedSection> sections,
  }) {
    final sectionMap = {for (final section in sections) section.id: section};
    final pool = <PracticeQuestion>[];

    for (final rule in eligibleRules) {
      final example = rule.examples[_random.nextInt(rule.examples.length)];
      pool.add(
        _buildTrueFalseQuestion(
          rule: rule,
          prompt: 'صح أم خطأ: المثال "${example.text}" يندرج تحت ${rule.name}.',
          isStatementCorrect: true,
          explanation: 'صحيح. ${example.note}',
        ),
      );

      final confusingRule = _pickSingleRuleDistractor(
        correct: rule,
        rulesPool: allRules,
      );
      if (confusingRule != null) {
        pool.add(
          _buildTrueFalseQuestion(
            rule: rule,
            prompt:
                'صح أم خطأ: المثال "${example.text}" يندرج تحت ${confusingRule.name}.',
            isStatementCorrect: false,
            explanation: 'خطأ. الحكم الصحيح للمثال هو ${rule.name}.',
          ),
        );
      }

      final letters = _lettersOf(rule, singleCharacterOnly: true);
      if (letters.length >= 2) {
        final trueSubset = [...letters]..shuffle(_random);
        final shownTrueLetters = trueSubset
            .take(min(4, trueSubset.length))
            .join('، ');
        pool.add(
          _buildTrueFalseQuestion(
            rule: rule,
            prompt: 'صح أم خطأ: من حروف ${rule.name}: $shownTrueLetters',
            isStatementCorrect: true,
            explanation: 'صحيح. حروف ${rule.name}: ${letters.join('، ')}.',
          ),
        );

        final intruder = _pickIntruderLetter(
          correctRule: rule,
          allRules: allRules,
        );
        if (intruder != null) {
          final mixed = [
            ...trueSubset.take(min(3, trueSubset.length)),
            intruder,
          ]..shuffle(_random);
          pool.add(
            _buildTrueFalseQuestion(
              rule: rule,
              prompt: 'صح أم خطأ: من حروف ${rule.name}: ${mixed.join('، ')}',
              isStatementCorrect: false,
              explanation: 'خطأ. الحرف "$intruder" ليس من حروف ${rule.name}.',
            ),
          );
        }
      }

      final section = sectionMap[rule.sectionId];
      if (section != null) {
        pool.add(
          _buildTrueFalseQuestion(
            rule: rule,
            prompt: 'صح أم خطأ: حكم ${rule.name} يتبع قسم "${section.title}".',
            isStatementCorrect: true,
            explanation: 'صحيح. ${rule.name} ضمن قسم ${section.title}.',
          ),
        );

        final wrongSection = _pickSectionDistractor(
          correctSectionId: section.id,
          sections: sections,
          focusRule: rule,
        );
        if (wrongSection != null) {
          pool.add(
            _buildTrueFalseQuestion(
              rule: rule,
              prompt:
                  'صح أم خطأ: حكم ${rule.name} يتبع قسم "${wrongSection.title}".',
              isStatementCorrect: false,
              explanation: 'خطأ. ${rule.name} يتبع قسم ${section.title}.',
            ),
          );
        }
      }
    }

    return pool;
  }

  List<PracticeQuestion> _buildLetterMatchPool({
    required List<TajweedRule> eligibleRules,
    required List<TajweedRule> allRules,
  }) {
    final pool = <PracticeQuestion>[];
    for (final rule in eligibleRules) {
      final letters = _lettersOf(rule, singleCharacterOnly: true);
      if (letters.isEmpty) {
        continue;
      }

      final shuffledLetters = [...letters]..shuffle(_random);
      final positiveTargets = shuffledLetters.take(
        min(4, shuffledLetters.length),
      );
      for (final correctLetter in positiveTargets) {
        final wrongLetters = _pickWrongLetters(
          correctLetter: correctLetter,
          rule: rule,
          allRules: allRules,
          forbiddenLetters: letters.toSet(),
          count: 3,
        );
        final options = <String>{correctLetter, ...wrongLetters}.toList()
          ..shuffle(_random);
        if (options.length < 2) {
          continue;
        }
        pool.add(
          PracticeQuestion(
            id: _nextQuestionId(
              PracticeType.letterMatch,
              '${rule.id}_positive',
            ),
            ruleId: rule.id,
            prompt: 'أي حرف يعد من حروف ${rule.name}؟',
            options: options,
            correctOptionIndex: options.indexOf(correctLetter),
            explanation:
                'الصحيح "$correctLetter". حروف ${rule.name}: ${letters.join('، ')}.',
          ),
        );
      }

      final pivotLetter = shuffledLetters.first;
      final intruderCandidates = _pickWrongLetters(
        correctLetter: pivotLetter,
        rule: rule,
        allRules: allRules,
        forbiddenLetters: letters.toSet(),
        count: 2,
      );
      if (intruderCandidates.isNotEmpty) {
        final intruder = intruderCandidates.first;
        final trueLetters = [...letters]..shuffle(_random);
        final safeCount = min(3, trueLetters.length);
        final options = <String>[...trueLetters.take(safeCount), intruder]
          ..shuffle(_random);

        if (options.length >= 2) {
          pool.add(
            PracticeQuestion(
              id: _nextQuestionId(
                PracticeType.letterMatch,
                '${rule.id}_negative',
              ),
              ruleId: rule.id,
              prompt: 'أي حرف ليس من حروف ${rule.name}؟',
              options: options,
              correctOptionIndex: options.indexOf(intruder),
              explanation:
                  'الحرف غير الصحيح هو "$intruder". حروف ${rule.name}: ${letters.join('، ')}.',
            ),
          );
        }
      }
    }
    return pool;
  }

  List<PracticeQuestion> _buildSectionMatchPool({
    required List<TajweedRule> eligibleRules,
    required List<TajweedRule> allRules,
    required List<TajweedSection> sections,
  }) {
    final sectionMap = {for (final section in sections) section.id: section};
    final pool = <PracticeQuestion>[];

    for (final rule in eligibleRules) {
      final options = _buildSectionOptions(
        correctRule: rule,
        allRules: allRules,
        sections: sections,
      );
      final correctSectionTitle = sectionMap[rule.sectionId]?.title ?? '';
      final correctIndex = options.indexOf(correctSectionTitle);
      if (correctIndex < 0 || options.length < 2) {
        continue;
      }

      pool.add(
        PracticeQuestion(
          id: _nextQuestionId(PracticeType.sectionMatch, '${rule.id}_name'),
          ruleId: rule.id,
          prompt: 'ينتمي حكم "${rule.name}" إلى أي قسم؟',
          options: options,
          correctOptionIndex: correctIndex,
          explanation: '${rule.name} ضمن قسم $correctSectionTitle.',
        ),
      );

      final example = rule.examples[_random.nextInt(rule.examples.length)];
      pool.add(
        PracticeQuestion(
          id: _nextQuestionId(PracticeType.sectionMatch, '${rule.id}_example'),
          ruleId: rule.id,
          prompt: 'المثال "${example.text}" أقرب لأي قسم من أبواب التجويد؟',
          options: options,
          correctOptionIndex: correctIndex,
          explanation:
              'المثال تابع لحكم ${rule.name} من قسم $correctSectionTitle.',
        ),
      );
    }

    return pool;
  }

  List<PracticeQuestion> _buildDefinitionMatchPool({
    required List<TajweedRule> eligibleRules,
    required List<TajweedRule> allRules,
    required List<TajweedSection> sections,
  }) {
    final sectionMap = {for (final section in sections) section.id: section};
    final pool = <PracticeQuestion>[];
    for (final rule in eligibleRules) {
      final options = _buildRuleOptions(correct: rule, rulesPool: allRules);
      final correctIndex = options.indexOf(rule.name);
      if (correctIndex < 0 || options.length < 2) {
        continue;
      }

      final sectionTitle = sectionMap[rule.sectionId]?.title ?? '';
      pool.add(
        PracticeQuestion(
          id: _nextQuestionId(
            PracticeType.definitionMatch,
            '${rule.id}_definition',
          ),
          ruleId: rule.id,
          prompt: 'حدّد الحكم المناسب للتعريف التالي:\n${rule.description}',
          options: options,
          correctOptionIndex: correctIndex,
          explanation: 'الوصف السابق هو تعريف ${rule.name}.',
        ),
      );

      pool.add(
        PracticeQuestion(
          id: _nextQuestionId(PracticeType.definitionMatch, '${rule.id}_tip'),
          ruleId: rule.id,
          prompt: 'أي حكم تنطبق عليه هذه المعلومة: "${rule.tip}"؟',
          options: options,
          correctOptionIndex: correctIndex,
          explanation: 'المعلومة مرتبطة بحكم ${rule.name}.',
        ),
      );

      final letters = _lettersOf(rule, singleCharacterOnly: true);
      if (letters.isNotEmpty) {
        final sampleLetters = [...letters]..shuffle(_random);
        final letterHint = sampleLetters
            .take(min(5, sampleLetters.length))
            .join('، ');
        pool.add(
          PracticeQuestion(
            id: _nextQuestionId(
              PracticeType.definitionMatch,
              '${rule.id}_letters',
            ),
            ruleId: rule.id,
            prompt:
                'حكم من قسم "$sectionTitle" يعتمد على الحروف: $letterHint. ما هو؟',
            options: options,
            correctOptionIndex: correctIndex,
            explanation: 'هذه الحروف تابعة لحكم ${rule.name}.',
          ),
        );
      }
    }
    return pool;
  }

  PracticeQuestion _buildTrueFalseQuestion({
    required TajweedRule rule,
    required String prompt,
    required bool isStatementCorrect,
    required String explanation,
  }) {
    return PracticeQuestion(
      id: _nextQuestionId(PracticeType.trueFalse, rule.id),
      ruleId: rule.id,
      prompt: prompt,
      options: const ['صح', 'خطأ'],
      correctOptionIndex: isStatementCorrect ? 0 : 1,
      explanation: explanation,
    );
  }

  List<PracticeQuestion> _pickQuestions({
    required List<PracticeQuestion> pool,
    required int targetCount,
    required PracticeType practiceType,
  }) {
    if (targetCount <= 0) {
      return const [];
    }
    final shuffled = [...pool]..shuffle(_random);
    if (shuffled.length >= targetCount) {
      return shuffled.take(targetCount).toList();
    }

    final selected = <PracticeQuestion>[];
    var cycle = 0;
    while (selected.length < targetCount) {
      final cyclePool = [...pool]..shuffle(_random);
      for (final question in cyclePool) {
        if (selected.length >= targetCount) {
          break;
        }
        selected.add(
          PracticeQuestion(
            id: _nextQuestionId(practiceType, 'repeat_$cycle'),
            ruleId: question.ruleId,
            prompt: question.prompt,
            options: question.options,
            correctOptionIndex: question.correctOptionIndex,
            explanation: question.explanation,
          ),
        );
      }
      cycle++;
    }
    return selected;
  }

  List<String> _buildRuleOptions({
    required TajweedRule correct,
    required List<TajweedRule> rulesPool,
    int total = 4,
  }) {
    final distractors = _pickRuleDistractors(
      correct: correct,
      rulesPool: rulesPool,
      count: max(0, total - 1),
    );
    final options = <String>{
      correct.name,
      ...distractors.map((item) => item.name),
    }.toList();

    if (options.length < total) {
      final fallback =
          rulesPool
              .where((item) => item.id != correct.id)
              .map((item) => item.name)
              .where((item) => !options.contains(item))
              .toList()
            ..shuffle(_random);
      options.addAll(fallback.take(total - options.length));
    }

    options.shuffle(_random);
    return options;
  }

  List<String> _buildSectionOptions({
    required TajweedRule correctRule,
    required List<TajweedRule> allRules,
    required List<TajweedSection> sections,
    int total = 4,
  }) {
    final correctSection = sections.firstWhere(
      (section) => section.id == correctRule.sectionId,
      orElse: () => sections.first,
    );

    final scored =
        sections
            .where((section) => section.id != correctSection.id)
            .map(
              (section) => _ScoredSection(
                section: section,
                score: _sectionSimilarity(
                  section: section,
                  focusRule: correctRule,
                  allRules: allRules,
                ),
              ),
            )
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    final distractors = scored
        .take(max(0, total - 1))
        .map((item) => item.section.title);
    final options = <String>{correctSection.title, ...distractors}.toList();
    if (options.length < total) {
      final fallback =
          sections
              .where((section) => section.id != correctSection.id)
              .map((section) => section.title)
              .where((title) => !options.contains(title))
              .toList()
            ..shuffle(_random);
      options.addAll(fallback.take(total - options.length));
    }

    options.shuffle(_random);
    return options;
  }

  List<TajweedRule> _pickRuleDistractors({
    required TajweedRule correct,
    required List<TajweedRule> rulesPool,
    required int count,
  }) {
    final scored =
        rulesPool
            .where((item) => item.id != correct.id)
            .map(
              (candidate) => _ScoredRule(
                rule: candidate,
                score:
                    _ruleSimilarity(correct, candidate) + _random.nextDouble(),
              ),
            )
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));
    return scored.take(count).map((item) => item.rule).toList();
  }

  TajweedRule? _pickSingleRuleDistractor({
    required TajweedRule correct,
    required List<TajweedRule> rulesPool,
  }) {
    final distractors = _pickRuleDistractors(
      correct: correct,
      rulesPool: rulesPool,
      count: 1,
    );
    return distractors.isEmpty ? null : distractors.first;
  }

  List<String> _pickWrongLetters({
    required String correctLetter,
    required TajweedRule rule,
    required List<TajweedRule> allRules,
    required Set<String> forbiddenLetters,
    required int count,
  }) {
    final sameSectionLetters = allRules
        .where((item) => item.sectionId == rule.sectionId && item.id != rule.id)
        .expand((item) => _lettersOf(item, singleCharacterOnly: true))
        .toSet();

    final allLetters =
        allRules
            .expand((item) => _lettersOf(item, singleCharacterOnly: true))
            .toSet()
          ..addAll(_standardArabicLetters);

    final scored =
        allLetters
            .where((item) => !forbiddenLetters.contains(item))
            .map(
              (item) => _ScoredLetter(
                letter: item,
                score:
                    _letterSimilarity(
                      reference: correctLetter,
                      candidate: item,
                    ) +
                    (sameSectionLetters.contains(item) ? 2.0 : 0.0) +
                    _random.nextDouble(),
              ),
            )
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    return scored.take(count).map((item) => item.letter).toList();
  }

  String? _pickIntruderLetter({
    required TajweedRule correctRule,
    required List<TajweedRule> allRules,
  }) {
    final letters = _lettersOf(correctRule, singleCharacterOnly: true).toSet();
    if (letters.isEmpty) {
      return null;
    }

    final reference = letters.elementAt(_random.nextInt(letters.length));
    final candidates = _pickWrongLetters(
      correctLetter: reference,
      rule: correctRule,
      allRules: allRules,
      forbiddenLetters: letters,
      count: 1,
    );
    return candidates.isEmpty ? null : candidates.first;
  }

  TajweedSection? _pickSectionDistractor({
    required String correctSectionId,
    required List<TajweedSection> sections,
    required TajweedRule focusRule,
  }) {
    final otherSections = sections
        .where((section) => section.id != correctSectionId)
        .toList();
    if (otherSections.isEmpty) {
      return null;
    }

    final scored =
        otherSections
            .map(
              (section) => _ScoredSection(
                section: section,
                score:
                    section.rules
                        .map((rule) => _ruleSimilarity(focusRule, rule))
                        .fold<double>(0, max) +
                    _random.nextDouble(),
              ),
            )
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));
    return scored.first.section;
  }

  List<String> _lettersOf(
    TajweedRule rule, {
    bool singleCharacterOnly = false,
  }) {
    return rule.letters
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .where(
          (item) =>
              !singleCharacterOnly || _standardArabicLetters.contains(item),
        )
        .toSet()
        .toList();
  }

  double _ruleSimilarity(TajweedRule a, TajweedRule b) {
    var score = 0.0;
    if (a.sectionId == b.sectionId) {
      score += 8;
    }

    final aLetters = _lettersOf(a, singleCharacterOnly: true).toSet();
    final bLetters = _lettersOf(b, singleCharacterOnly: true).toSet();
    final sharedLetters = aLetters.intersection(bLetters).length;
    score += sharedLetters * 2.0;

    final aName = a.name;
    final bName = b.name;
    for (final token in const [
      'مد',
      'إدغام',
      'إخفاء',
      'إظهار',
      'لام',
      'غنة',
      'لازم',
      'شفوي',
    ]) {
      if (aName.contains(token) && bName.contains(token)) {
        score += 1.5;
      }
    }

    final letterDiff = (aLetters.length - bLetters.length).abs();
    if (letterDiff <= 2) {
      score += 0.8;
    }
    return score;
  }

  double _sectionSimilarity({
    required TajweedSection section,
    required TajweedRule focusRule,
    required List<TajweedRule> allRules,
  }) {
    if (section.rules.isEmpty) {
      return 0;
    }
    final maxRuleSimilarity = section.rules
        .map((candidate) => _ruleSimilarity(focusRule, candidate))
        .fold<double>(0, max);

    final sharedTopicBonus = allRules
        .where((item) => item.sectionId == section.id)
        .where(
          (item) => focusRule.name.contains('مد') && item.name.contains('مد'),
        )
        .length
        .toDouble();

    return maxRuleSimilarity + sharedTopicBonus;
  }

  double _letterSimilarity({
    required String reference,
    required String candidate,
  }) {
    if (reference == candidate) {
      return 10;
    }
    final group = _confusableLetterGroups.firstWhere(
      (letters) => letters.contains(reference),
      orElse: () => const <String>[],
    );
    if (group.contains(candidate)) {
      return 5;
    }
    final referenceIndex = _standardArabicLetters.indexOf(reference);
    final candidateIndex = _standardArabicLetters.indexOf(candidate);
    if (referenceIndex != -1 &&
        candidateIndex != -1 &&
        (referenceIndex - candidateIndex).abs() <= 2) {
      return 2;
    }
    return 0.5;
  }

  String _nextQuestionId(PracticeType type, String context) {
    _questionIdCounter++;
    return '${type.name}_${context}_${DateTime.now().microsecondsSinceEpoch}_$_questionIdCounter';
  }
}

class _ScoredRule {
  const _ScoredRule({required this.rule, required this.score});

  final TajweedRule rule;
  final double score;
}

class _ScoredSection {
  const _ScoredSection({required this.section, required this.score});

  final TajweedSection section;
  final double score;
}

class _ScoredLetter {
  const _ScoredLetter({required this.letter, required this.score});

  final String letter;
  final double score;
}

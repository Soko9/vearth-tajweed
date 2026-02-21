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

    final sectionMap = {for (final section in sections) section.id: section};
    final allRules = [for (final section in sections) ...section.rules];
    final generatedOffline = List<PracticeQuestion>.generate(
      config.questionCount,
      (index) {
        final rule = scopedRules[_random.nextInt(scopedRules.length)];
        final id =
            '${config.practiceType.name}_${index}_${rule.id}_${DateTime.now().microsecondsSinceEpoch}';

        switch (config.practiceType) {
          case PracticeType.mcq:
            return _buildMcqQuestion(id: id, rule: rule, rulesPool: allRules);
          case PracticeType.trueFalse:
            return _buildTrueFalseQuestion(id: id, rule: rule);
          case PracticeType.letterMatch:
            return _buildLetterMatchQuestion(id: id, rule: rule);
          case PracticeType.sectionMatch:
            return _buildSectionMatchQuestion(
              id: id,
              rule: rule,
              sections: sections,
              sectionMap: sectionMap,
            );
        }
      },
    );

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
  }) {
    final validLetters = rule.letters
        .where((item) => item.trim().isNotEmpty)
        .toSet()
        .toList();
    if (validLetters.isEmpty) {
      validLetters.addAll(['ن', 'م']);
    }

    return PracticeQuestion(
      id: id,
      ruleId: rule.id,
      prompt: 'اختر حرفًا من الآية التالية يحقق حكم ${rule.name}.',
      explanation: 'الحروف الصحيحة في هذا السؤال: ${validLetters.join('، ')}.',
      sourceText: _pickFullAyahForRule(rule: rule, validLetters: validLetters),
      validLetters: validLetters,
    );
  }

  String _pickFullAyahForRule({
    required TajweedRule rule,
    required List<String> validLetters,
  }) {
    final explicitAyahs = _ruleAyahPool[rule.id];
    if (explicitAyahs != null && explicitAyahs.isNotEmpty) {
      final longAyahs = explicitAyahs
          .where((ayah) => _wordCount(ayah) >= 4)
          .toList();
      final pool = longAyahs.isNotEmpty ? longAyahs : explicitAyahs;
      return pool[_random.nextInt(pool.length)];
    }
    return _pickFullAyahForLetters(validLetters);
  }

  String _pickFullAyahForLetters(List<String> validLetters) {
    if (_fullAyahPool.isEmpty) {
      return 'قُلْ هُوَ اللَّهُ أَحَدٌ';
    }

    final normalizedLetters = validLetters
        .map(_normalizeArabicLetter)
        .where((item) => item.isNotEmpty)
        .toSet();
    final matchingAyahs = _fullAyahPool
        .where(
          (ayah) => normalizedLetters.any((letter) => ayah.contains(letter)),
        )
        .where((ayah) => _wordCount(ayah) >= 4)
        .toList();
    final fallbackPool = _fullAyahPool
        .where((ayah) => _wordCount(ayah) >= 4)
        .toList();
    final pool = matchingAyahs.isNotEmpty
        ? matchingAyahs
        : (fallbackPool.isNotEmpty ? fallbackPool : _fullAyahPool);
    return pool[_random.nextInt(pool.length)];
  }

  int _wordCount(String input) => input
      .trim()
      .split(RegExp(r'\s+'))
      .where((item) => item.isNotEmpty)
      .length;

  String _normalizeArabicLetter(String input) {
    final withoutMarks = input.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    );
    final match = RegExp(r'[ء-ي]').firstMatch(withoutMarks);
    return match?.group(0) ?? '';
  }

  static const List<String> _fullAyahPool = [
    'قُلْ هُوَ اللَّهُ أَحَدٌ',
    'اللَّهُ الصَّمَدُ',
    'لَمْ يَلِدْ وَلَمْ يُولَدْ',
    'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
    'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
    'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
    'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
    'مِن شَرِّ مَا خَلَقَ',
    'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
    'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
    'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
    'مَلِكِ النَّاسِ',
    'إِلَهِ النَّاسِ',
    'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
    'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
    'مِنَ الْجِنَّةِ وَالنَّاسِ',
    'تَبَّتْ يَدَا أَبِي لَهَبٍ وَتَبَّ',
    'مَا أَغْنَىٰ عَنْهُ مَالُهُ وَمَا كَسَبَ',
    'سَيَصْلَىٰ نَارًا ذَاتَ لَهَبٍ',
    'وَامْرَأَتُهُ حَمَّالَةَ الْحَطَبِ',
    'فِي جِيدِهَا حَبْلٌ مِّن مَّسَدٍ',
  ];

  static const Map<String, List<String>> _ruleAyahPool = {
    'izhar_halqi': [
      'مَنْ آمَنَ بِاللَّهِ وَالْيَوْمِ الْآخِرِ وَعَمِلَ صَالِحًا فَلَهُمْ أَجْرُهُمْ',
      'إِنْ هُوَ إِلَّا وَحْيٌ يُوحَى',
      'وَمَنْ يَعْمَلْ مِنَ الصَّالِحَاتِ وَهُوَ مُؤْمِنٌ فَلَا يَخَافُ ظُلْمًا وَلَا هَضْمًا',
    ],
    'idgham_ghunnah': [
      'مَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ',
      'مِن وَلِيٍّ وَلَا نَصِيرٍ',
      'إِنَّ اللَّهَ غَفُورٌ وَرَحِيمٌ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    ],
    'idgham_no_ghunnah': [
      'هُدًى مِن رَبِّهِمْ وَأُولَٰئِكَ هُمُ الْمُفْلِحُونَ',
      'قَيِّمًا لِيُنذِرَ بَأْسًا شَدِيدًا مِّن لَّدُنْهُ',
      'إِنَّ رَبَّكَ غَفُورٌ رَّحِيمٌ لِّمَن تَابَ وَآمَنَ',
    ],
    'iqlab': [
      'أَنْبِئْهُمْ بِأَسْمَائِهِمْ فَلَمَّا أَنْبَأَهُمْ بِأَسْمَائِهِمْ',
      'إِنَّ اللَّهَ سَمِيعٌ بَصِيرٌ',
      'مِن بَعْدِ مَا تَبَيَّنَ لَهُمُ الْهُدَى',
    ],
    'ikhfa_haqiqi': [
      'إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ',
      'وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      'مِنْ قَبْلِكُمْ سُنَنٌ فَسِيرُوا فِي الْأَرْضِ',
    ],
    'ikhfa_shafawi': [
      'تَرْمِيهِمْ بِحِجَارَةٍ مِّن سِجِّيلٍ',
      'لَهُم بِهَا زَفِيرٌ وَهُمْ فِيهَا لَا يَسْمَعُونَ',
      'وَمَا لَهُم بِهِ مِنْ عِلْمٍ',
    ],
    'idgham_shafawi': [
      'لَهُمْ مَا يَشَاءُونَ عِندَ رَبِّهِمْ',
      'عَلَيْهِمْ مَا حُمِّلُوا',
      'كَم مِّن فِئَةٍ قَلِيلَةٍ',
    ],
    'izhar_shafawi': [
      'هُمْ فِيهَا خَالِدُونَ',
      'عَلَيْهِمْ قِتَالٌ',
      'أَنْتُمْ فُقَرَاءُ إِلَى اللَّهِ',
    ],
    'mad_asli': [
      'قَالَ رَبِّ اشْرَحْ لِي صَدْرِي',
      'يَقُولُ الْحَقَّ وَهُوَ يَهْدِي السَّبِيلَ',
      'فِيهَا فَاكِهَةٌ وَنَخْلٌ',
    ],
    'mad_muttasil': [
      'جَاءَ الْحَقُّ وَزَهَقَ الْبَاطِلُ',
      'وَالسَّمَاءِ وَالطَّارِقِ وَمَا أَدْرَاكَ مَا الطَّارِقُ',
      'إِنَّ السَّاعَةَ آتِيَةٌ لَا رَيْبَ فِيهَا',
    ],
    'mad_munfasil': [
      'بِمَا أُنْزِلَ إِلَيْكَ وَمَا أُنْزِلَ مِن قَبْلِكَ',
      'فِي أَنْفُسِكُمْ',
      'يَا أَيُّهَا الَّذِينَ آمَنُوا',
    ],
    'mad_lazim': [
      'وَلَا الضَّالِّينَ',
      'آلْآنَ وَقَدْ عَصَيْتَ قَبْلُ',
      'أَتُحَاجُّونِّي فِي اللَّهِ وَقَدْ هَدَانِ',
    ],
  };

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

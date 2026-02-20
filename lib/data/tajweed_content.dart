import '../models/tajweed_models.dart';

const List<TajweedSection> tajweedSections = [
  TajweedSection(
    id: 'nun_tanween',
    title: 'أحكام النون الساكنة والتنوين',
    overview:
        'خمسة أحكام رئيسية: الإظهار، الإدغام بغنة، الإدغام بغير غنة، الإقلاب، الإخفاء الحقيقي.',
    poemExcerpt:
        'للنون إن تسكن وللتنوينِ أربع أحكام فخذ تبييني\nفالأول الإظهار قبل أحرف للحلق ست رتبت فلتعرف',
    rules: [
      TajweedRule(
        id: 'izhar_halqi',
        sectionId: 'nun_tanween',
        name: 'الإظهار الحلقي',
        description:
            'إخراج النون الساكنة أو التنوين من مخرجهما من غير غنة زائدة عند مجيء أحد أحرف الحلق.',
        letters: ['ء', 'ه', 'ع', 'ح', 'غ', 'خ'],
        colorHex: 0xFF1E88E5,
        tip: 'سمّي حلقيًا لأن حروفه تخرج من الحلق.',
        examples: [
          RuleExample(text: 'مِنْ هَادٍ', note: 'نون ساكنة بعدها هاء.'),
          RuleExample(text: 'سَمِيعٌ عَلِيمٌ', note: 'تنوين ضم بعده عين.'),
        ],
      ),
      TajweedRule(
        id: 'idgham_ghunnah',
        sectionId: 'nun_tanween',
        name: 'الإدغام بغنة',
        description:
            'إدخال النون الساكنة أو التنوين في الحرف الذي بعدها مع غنة مقدارها حركتان.',
        letters: ['ي', 'ن', 'م', 'و'],
        colorHex: 0xFF43A047,
        tip: 'تجمع في كلمة "ينمو".',
        examples: [
          RuleExample(text: 'مِنْ وَالٍ', note: 'نون ساكنة بعدها واو.'),
          RuleExample(text: 'غَفُورٌ نَصِيرٌ', note: 'تنوين ضم بعده نون.'),
        ],
      ),
      TajweedRule(
        id: 'idgham_no_ghunnah',
        sectionId: 'nun_tanween',
        name: 'الإدغام بغير غنة',
        description:
            'إدخال النون الساكنة أو التنوين في اللام أو الراء بلا غنة.',
        letters: ['ل', 'ر'],
        colorHex: 0xFF8E24AA,
        tip: 'لا غنة فيه لأن الحرفين قويان في المخرج.',
        examples: [
          RuleExample(text: 'مِنْ رَبِّهِمْ', note: 'نون ساكنة بعدها راء.'),
          RuleExample(text: 'غَفُورٌ رَحِيمٌ', note: 'تنوين ضم بعده راء.'),
        ],
      ),
      TajweedRule(
        id: 'iqlab',
        sectionId: 'nun_tanween',
        name: 'الإقلاب',
        description:
            'قلب النون الساكنة أو التنوين ميماً مخفاة عند حرف الباء مع بقاء الغنة.',
        letters: ['ب'],
        colorHex: 0xFFF4511E,
        tip: 'علامته غالبًا ميم صغيرة فوق النون في المصحف.',
        examples: [
          RuleExample(text: 'أَنْبِئْهُمْ', note: 'نون ساكنة بعدها باء.'),
          RuleExample(text: 'سَمِيعٌ بَصِيرٌ', note: 'تنوين ضم بعده باء.'),
        ],
      ),
      TajweedRule(
        id: 'ikhfa_haqiqi',
        sectionId: 'nun_tanween',
        name: 'الإخفاء الحقيقي',
        description:
            'النطق بحرف بين الإظهار والإدغام مع بقاء الغنة عند حروف الإخفاء الخمسة عشر.',
        letters: [
          'ت',
          'ث',
          'ج',
          'د',
          'ذ',
          'ز',
          'س',
          'ش',
          'ص',
          'ض',
          'ط',
          'ظ',
          'ف',
          'ق',
          'ك',
        ],
        colorHex: 0xFFFB8C00,
        tip:
            'يكون الإخفاء أقرب للإدغام عند القاف والكاف وأقرب للإظهار عند التاء والدال.',
        examples: [
          RuleExample(text: 'مِنْ قَبْلُ', note: 'نون ساكنة بعدها قاف.'),
          RuleExample(text: 'عَلِيمٌ شَاكِرٌ', note: 'تنوين بعده شين.'),
        ],
      ),
    ],
  ),
  TajweedSection(
    id: 'meem_sakinah',
    title: 'أحكام الميم الساكنة',
    overview: 'ثلاثة أحكام: الإخفاء الشفوي، الإدغام الشفوي، الإظهار الشفوي.',
    poemExcerpt:
        'وأخـفِيَــنْ الميمَ إن تسكنْ لدى باءٍ على المختار من أهل الأداء',
    rules: [
      TajweedRule(
        id: 'ikhfa_shafawi',
        sectionId: 'meem_sakinah',
        name: 'الإخفاء الشفوي',
        description: 'إخفاء الميم الساكنة عند الباء مع غنة.',
        letters: ['ب'],
        colorHex: 0xFF00897B,
        tip: 'يكون من الشفتين ولذلك سمي شفويًا.',
        examples: [
          RuleExample(
            text: 'تَرْمِيهِمْ بِحِجَارَةٍ',
            note: 'ميم ساكنة بعدها باء.',
          ),
          RuleExample(text: 'هُمْ بِهِ', note: 'ميم ساكنة بعدها باء.'),
        ],
      ),
      TajweedRule(
        id: 'idgham_shafawi',
        sectionId: 'meem_sakinah',
        name: 'الإدغام الشفوي',
        description: 'إدغام الميم الساكنة في ميم متحركة مع غنة.',
        letters: ['م'],
        colorHex: 0xFF5E35B1,
        tip: 'يسمى أيضًا الإدغام المِثلي الصغير للميم.',
        examples: [
          RuleExample(text: 'لَهُمْ مَا', note: 'ميم ساكنة بعدها ميم.'),
          RuleExample(
            text: 'عَلَيْهِمْ مَا حُمِّلُوا',
            note: 'ميم ساكنة بعدها ميم.',
          ),
        ],
      ),
      TajweedRule(
        id: 'izhar_shafawi',
        sectionId: 'meem_sakinah',
        name: 'الإظهار الشفوي',
        description: 'إظهار الميم الساكنة عند جميع الحروف ما عدا الباء والميم.',
        letters: [
          'ء',
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
          'ن',
          'ه',
          'و',
          'ي',
        ],
        colorHex: 0xFF6D4C41,
        tip: 'احذر من إخفاء الميم عند الفاء والواو، والصواب الإظهار.',
        examples: [
          RuleExample(text: 'عَلَيْهِمْ قِتَالٌ', note: 'ميم ساكنة بعدها قاف.'),
          RuleExample(text: 'هُمْ فِيهَا', note: 'ميم ساكنة بعدها فاء.'),
        ],
      ),
    ],
  ),
  TajweedSection(
    id: 'mudood',
    title: 'أحكام المدود الأساسية',
    overview:
        'أهم المدود التعليمية: المد الطبيعي، المد الواجب المتصل، المد الجائز المنفصل، المد اللازم.',
    poemExcerpt:
        'والمد أصلي وفرعي له وسم أولًا طبيعيًا وهو ما لا توقف له على سبب',
    rules: [
      TajweedRule(
        id: 'mad_asli',
        sectionId: 'mudood',
        name: 'المد الطبيعي',
        description: 'مد بمقدار حركتين دون سبب همز أو سكون.',
        letters: ['ا', 'و', 'ي'],
        colorHex: 0xFF00ACC1,
        tip: 'هو أصل المدود كلها ويُمد حركتين فقط.',
        examples: [
          RuleExample(text: 'قَالَ', note: 'ألف مد طبيعي.'),
          RuleExample(text: 'يَقُولُ', note: 'واو مد طبيعي.'),
        ],
      ),
      TajweedRule(
        id: 'mad_muttasil',
        sectionId: 'mudood',
        name: 'المد الواجب المتصل',
        description:
            'أن يأتي بعد حرف المد همز في نفس الكلمة، ويمد غالبًا أربع أو خمس حركات.',
        letters: ['ا', 'و', 'ي', 'ء'],
        colorHex: 0xFF3949AB,
        tip: 'سمي متصلًا لاجتماع حرف المد والهمز في كلمة واحدة.',
        examples: [
          RuleExample(text: 'جَاءَ', note: 'ألف بعدها همز في نفس الكلمة.'),
          RuleExample(text: 'السُّوءُ', note: 'واو مد بعدها همز.'),
        ],
      ),
      TajweedRule(
        id: 'mad_munfasil',
        sectionId: 'mudood',
        name: 'المد الجائز المنفصل',
        description:
            'أن يقع حرف المد في آخر كلمة والهمز في أول الكلمة التي بعدها، ويمد أربع أو خمس حركات.',
        letters: ['ا', 'و', 'ي', 'ء'],
        colorHex: 0xFF7CB342,
        tip: 'سمي منفصلًا لانفصال حرف المد عن الهمز في كلمتين.',
        examples: [
          RuleExample(
            text: 'فِي أَنْفُسِكُمْ',
            note: 'ياء مد في كلمة وهمز في الكلمة التالية.',
          ),
          RuleExample(
            text: 'بِمَا أُنْزِلَ',
            note: 'ألف مد ثم همز في الكلمة التالية.',
          ),
        ],
      ),
      TajweedRule(
        id: 'mad_lazim',
        sectionId: 'mudood',
        name: 'المد اللازم',
        description:
            'أن يأتي بعد حرف المد سكون لازم في كلمة أو حرف، ويمد ست حركات.',
        letters: ['ا', 'و', 'ي', 'سكون لازم'],
        colorHex: 0xFFE53935,
        tip: 'هو أقوى المدود اللازمة من حيث طول مقدار المد.',
        examples: [
          RuleExample(text: 'الضَّالِّينَ', note: 'مد لازم كلمي مثقل.'),
          RuleExample(text: 'آلْآنَ', note: 'مد لازم في قراءة خاصة.'),
        ],
      ),
    ],
  ),
];

List<TajweedRule> get allRules => [
  for (final section in tajweedSections) ...section.rules,
];

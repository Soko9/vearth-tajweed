import '../models/tajweed_models.dart';

const List<String> _allArabicLetters = [
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

const List<TajweedSection> tajweedSections = [
  TajweedSection(
    id: 'nun_tanween',
    title: 'أحكام النون الساكنة والتنوين',
    overview:
        'الأبواب الأساسية في التحفة: الإظهار، الإدغام (بغنة وبغير غنة)، الإقلاب، الإخفاء الحقيقي.',
    poemExcerpt:
        'لِلنُّونِ إِنْ تَسْكُنْ وَلِلتَّنْوِينِ أَرْبَعُ أَحْكَامٍ فَخُذْ تَبْيِينِي',
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
          RuleExample(text: 'عَلِيمٌ حَكِيمٌ', note: 'تنوين ضم بعده حاء.'),
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
          RuleExample(text: 'مَنْ يَعْمَلْ', note: 'نون ساكنة بعدها ياء.'),
          RuleExample(text: 'غَفُورٌ وَدُودٌ', note: 'تنوين ضم بعده واو.'),
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
          RuleExample(
            text: 'هُدًى لِّلْمُتَّقِينَ',
            note: 'تنوين فتح بعده لام.',
          ),
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
          RuleExample(text: 'مِنْ شَرٍّ', note: 'نون ساكنة بعدها شين.'),
          RuleExample(text: 'عَلِيمٌ شَاكِرٌ', note: 'تنوين بعده شين.'),
        ],
      ),
    ],
  ),
  TajweedSection(
    id: 'ghunnah_mushaddadah',
    title: 'أحكام النون والميم المشددتين',
    overview:
        'الغنة في النون المشددة والميم المشددة واجبة بمقدار حركتين، وهو باب مستقل في التحفة.',
    poemExcerpt: 'وَغُنَّ مِيمًا ثُمَّ نُونًا شُدِّدَا',
    rules: [
      TajweedRule(
        id: 'ghunnah_on_mushaddad',
        sectionId: 'ghunnah_mushaddadah',
        name: 'غنة النون والميم المشددتين',
        description:
            'عند وجود نون أو ميم مشددة يجب إظهار الغنة بمقدار حركتين وصلاً ووقفًا.',
        letters: ['ن', 'م'],
        colorHex: 0xFF0D47A1,
        tip: 'هذا الحكم واجب دائمًا في كل نون أو ميم مشددة.',
        examples: [
          RuleExample(text: 'إِنَّا أَعْطَيْنَاكَ', note: 'نون مشددة مع غنة.'),
          RuleExample(text: 'ثُمَّ نُنَجِّي', note: 'ميم مشددة مع غنة.'),
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
          RuleExample(text: 'كَمْ مِنْ فِئَةٍ', note: 'ميم ساكنة بعدها ميم.'),
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
          RuleExample(
            text: 'هُمْ فِيهَا',
            note: 'ميم ساكنة بعدها فاء مع إظهار.',
          ),
        ],
      ),
    ],
  ),
  TajweedSection(
    id: 'lamat',
    title: 'حكم لام "الـ" ولام الفعل',
    overview:
        'في التحفة: لام التعريف لها حالان (قمرية وشمسية)، وأما لام الفعل فالأصل فيها الإظهار.',
    poemExcerpt:
        'لِلَامِ أَلْ حَالَانِ قَبْلَ الأَحْرُفِ أُولَاهُمَا إِظْهَارُهَا',
    rules: [
      TajweedRule(
        id: 'lam_qamariyah',
        sectionId: 'lamat',
        name: 'اللام القمرية',
        description:
            'تُظهر لام "الـ" إذا جاء بعدها أحد الحروف القمرية الأربعة عشر.',
        letters: [
          'ء',
          'ب',
          'ج',
          'ح',
          'خ',
          'ع',
          'غ',
          'ف',
          'ق',
          'ك',
          'م',
          'ه',
          'و',
          'ي',
        ],
        colorHex: 0xFF5D4037,
        tip: 'علامتها في المصحف غالبًا سكون على اللام.',
        examples: [
          RuleExample(text: 'الْقَمَرُ', note: 'لام ظاهرة قبل القاف.'),
          RuleExample(text: 'الْفَلَقِ', note: 'لام ظاهرة قبل الفاء.'),
        ],
      ),
      TajweedRule(
        id: 'lam_shamsiyah',
        sectionId: 'lamat',
        name: 'اللام الشمسية',
        description:
            'تُدغم لام "الـ" في الحرف الشمسي الذي بعدها، ويُشدد الحرف التالي.',
        letters: [
          'ت',
          'ث',
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
          'ل',
          'ن',
        ],
        colorHex: 0xFFEF6C00,
        tip: 'علامتها شدة على الحرف بعد "الـ" وعدم نطق اللام.',
        examples: [
          RuleExample(text: 'الشَّمْسُ', note: 'أدغمت اللام في الشين.'),
          RuleExample(text: 'النَّاسُ', note: 'أدغمت اللام في النون.'),
        ],
      ),
      TajweedRule(
        id: 'lam_fiil_izhar',
        sectionId: 'lamat',
        name: 'إظهار لام الفعل',
        description:
            'لام الفعل تُظهر عند جميع الحروف في نحو: قُلْ نَعَمْ، قُلْنَا، الْتَقَى.',
        letters: _allArabicLetters,
        colorHex: 0xFF00838F,
        tip: 'هذا الحكم عام في لام الفعل، بخلاف لام التعريف.',
        examples: [
          RuleExample(text: 'قُلْ نَعَمْ', note: 'لام ساكنة ظاهرة في فعل.'),
          RuleExample(text: 'قُلْ تَعَالَوْا', note: 'لام ظاهرة قبل التاء.'),
        ],
      ),
    ],
  ),
  TajweedSection(
    id: 'idgham_groups',
    title: 'المتماثلان والمتجانسان والمتقاربان',
    overview:
        'تصنيف الحرفين بحسب المخرج والصفة، والعمل في رواية حفص يكون غالبًا في النوع الصغير (الأول ساكن والثاني متحرك).',
    poemExcerpt:
        'إِنْ فِي الصِّفَاتِ وَالمَخَارِجِ اتَّفَقْ حَرْفَانِ فَالمِثْلَانِ',
    rules: [
      TajweedRule(
        id: 'idgham_mutamathilain_sagheer',
        sectionId: 'idgham_groups',
        name: 'إدغام المتماثلين الصغير',
        description:
            'إذا اجتمع حرفان متماثلان وكان الأول ساكنًا والثاني متحركًا، فالحكم إدغام الأول في الثاني.',
        letters: ['ب', 'م', 'ل', 'ن', 'ق'],
        colorHex: 0xFF7B1FA2,
        tip: 'المتماثلان: اتحاد في المخرج والصفة.',
        examples: [
          RuleExample(
            text: 'اضْرِبْ بِعَصَاكَ',
            note: 'الباء الساكنة أدغمت في الباء.',
          ),
          RuleExample(text: 'قُلْ لَهُمْ', note: 'لام ساكنة بعدها لام متحركة.'),
        ],
      ),
      TajweedRule(
        id: 'idgham_mutajanisain_sagheer',
        sectionId: 'idgham_groups',
        name: 'إدغام المتجانسين الصغير',
        description:
            'المتجانسان يتفقان في المخرج ويختلفان في الصفة، فإذا سكن الأول وتحرك الثاني يقع الإدغام في مواضع معروفة.',
        letters: ['ت', 'د', 'ط', 'ذ', 'ظ', 'ث', 'ب', 'م'],
        colorHex: 0xFF283593,
        tip: 'أشهر أمثلته: الدال مع التاء، والذال مع الظاء.',
        examples: [
          RuleExample(text: 'قَدْ تَبَيَّنَ', note: 'دال ساكنة قبل تاء.'),
          RuleExample(text: 'إِذْ ظَلَمُوا', note: 'ذال ساكنة قبل ظاء.'),
        ],
      ),
      TajweedRule(
        id: 'idgham_mutaqaribain_sagheer',
        sectionId: 'idgham_groups',
        name: 'إدغام المتقاربين الصغير',
        description:
            'المتقاربان يتقاربان في المخرج والصفة، ومع سكون الأول وتحرك الثاني يقع الإدغام في مواضع مخصوصة.',
        letters: ['ق', 'ك', 'ل', 'ر'],
        colorHex: 0xFF455A64,
        tip: 'من أمثلته المشهورة: القاف مع الكاف، واللام مع الراء.',
        examples: [
          RuleExample(text: 'أَلَمْ نَخْلُقْكُمْ', note: 'قاف ساكنة قبل كاف.'),
          RuleExample(text: 'قُلْ رَبِّ', note: 'لام ساكنة قبل راء.'),
        ],
      ),
    ],
  ),
  TajweedSection(
    id: 'mudood',
    title: 'أقسام المد وأحكامه',
    overview:
        'يشمل باب المد في التحفة: الطبيعي، المتصل، المنفصل، البدل، العارض للسكون، اللين، والمد اللازم بأقسامه.',
    poemExcerpt:
        'وَالْمَدُّ أَصْلِيٌّ وَفَرْعِيٌّ لَهُ وَسَمِّ أَوَّلًا طَبِيعِيًّا وَهُوَ',
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
        id: 'mad_badal',
        sectionId: 'mudood',
        name: 'مد البدل',
        description:
            'أن يتقدم الهمز على حرف المد في كلمة واحدة، ومقداره غالبًا حركتان.',
        letters: ['ء', 'ا', 'و', 'ي'],
        colorHex: 0xFF00897B,
        tip: 'قاعدته العامة: همز قبل مد في نفس الكلمة.',
        examples: [
          RuleExample(text: 'آمَنُوا', note: 'همز متقدم على ألف المد.'),
          RuleExample(text: 'إِيمَانًا', note: 'همز متقدم على ياء المد.'),
        ],
      ),
      TajweedRule(
        id: 'mad_arid_lissukun',
        sectionId: 'mudood',
        name: 'المد العارض للسكون',
        description:
            'أن يقع بعد حرف المد حرف متحرك يسكن لأجل الوقف، ويجوز فيه القصر أو التوسط أو الإشباع.',
        letters: ['ا', 'و', 'ي'],
        colorHex: 0xFF6A1B9A,
        tip: 'يظهر حكمه عند الوقف فقط، لا في حال الوصل.',
        examples: [
          RuleExample(
            text: 'الْعَالَمِينَ',
            note: 'يمد عند الوقف على آخر الكلمة.',
          ),
          RuleExample(
            text: 'نَسْتَعِينُ',
            note: 'يمد عند الوقف على آخر الكلمة.',
          ),
        ],
      ),
      TajweedRule(
        id: 'mad_layyin',
        sectionId: 'mudood',
        name: 'مد اللين',
        description:
            'يكون في الواو أو الياء الساكنتين المفتوح ما قبلهما إذا وقف القارئ على الكلمة.',
        letters: ['و', 'ي'],
        colorHex: 0xFFAD1457,
        tip: 'مثل العارض للسكون: يختص غالبًا بحالة الوقف.',
        examples: [
          RuleExample(text: 'خَوْف', note: 'واو لِين عند الوقف.'),
          RuleExample(text: 'الْبَيْت', note: 'ياء لِين عند الوقف.'),
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
          RuleExample(
            text: 'الضَّالِّينَ',
            note: 'أصل الباب في اللازم: ست حركات.',
          ),
          RuleExample(text: 'الم', note: 'ومن أمثلته ما يأتي في فواتح السور.'),
        ],
      ),
      TajweedRule(
        id: 'mad_lazim_kalimi_muthaqal',
        sectionId: 'mudood',
        name: 'المد اللازم الكلمي المثقل',
        description:
            'يكون إذا جاء بعد حرف المد سكون أصلي في كلمة واحدة مع إدغام (تشديد).',
        letters: ['ا', 'و', 'ي'],
        colorHex: 0xFFD81B60,
        tip: 'يمد ست حركات لزوماً في الوصل والوقف.',
        examples: [
          RuleExample(text: 'الضَّالِّينَ', note: 'بعد المد حرف مشدد.'),
          RuleExample(
            text: 'الْحَاقَّةُ',
            note: 'ألف قبل حرف مشدد في كلمة واحدة.',
          ),
        ],
      ),
      TajweedRule(
        id: 'mad_lazim_kalimi_mukhaffaf',
        sectionId: 'mudood',
        name: 'المد اللازم الكلمي المخفف',
        description:
            'سكون أصلي بعد حرف المد في كلمة واحدة بدون إدغام، وهو قليل جدًا في القرآن.',
        letters: ['ا'],
        colorHex: 0xFF5E35B1,
        tip: 'المثال الأشهر في رواية حفص: "آلْآنَ".',
        examples: [
          RuleExample(text: 'آلْآنَ', note: 'مد لازم كلمي مخفف.'),
          RuleExample(text: 'آلْآنَ', note: 'ورد في موضعين من سورة يونس.'),
        ],
      ),
      TajweedRule(
        id: 'mad_lazim_harfi_muthaqal',
        sectionId: 'mudood',
        name: 'المد اللازم الحرفي المثقل',
        description:
            'يكون في فواتح السور إذا كان حرف المد في حرف مقطع وبعده إدغام (تشديد).',
        letters: ['ل', 'م', 'س'],
        colorHex: 0xFF3949AB,
        tip: 'يمد ست حركات في الحروف التي بنيتها ثلاثة أحرف ووسطها حرف مد.',
        examples: [
          RuleExample(text: 'الم', note: 'لام حرفي لازم مثقل.'),
          RuleExample(text: 'طسم', note: 'سين من حروف المد الحرفي المثقل.'),
        ],
      ),
      TajweedRule(
        id: 'mad_lazim_harfi_mukhaffaf',
        sectionId: 'mudood',
        name: 'المد اللازم الحرفي المخفف',
        description:
            'يكون في فواتح السور في الحرف الثلاثي الذي وسطه حرف مد دون إدغام بعده.',
        letters: ['ق', 'ن', 'ص'],
        colorHex: 0xFF00838F,
        tip: 'يمد ست حركات كذلك، لكن دون تشديد بعد المد.',
        examples: [
          RuleExample(text: 'قٓ', note: 'قاف من اللازم الحرفي المخفف.'),
          RuleExample(text: 'نٓ', note: 'نون من اللازم الحرفي المخفف.'),
        ],
      ),
      TajweedRule(
        id: 'mad_fawatih_natural',
        sectionId: 'mudood',
        name: 'المد الطبيعي في فواتح السور',
        description:
            'الحروف المقطعة غير الثلاثية (مثل حي طهر) يمد كل حرف منها مدًا طبيعيًا بمقدار حركتين.',
        letters: ['ح', 'ي', 'ط', 'ه', 'ر'],
        colorHex: 0xFF2E7D32,
        tip: 'هذه الحروف لا يدخلها اللازم الحرفي، ومدها طبيعي فقط.',
        examples: [
          RuleExample(text: 'طه', note: 'الطاء والهاء مدهما طبيعي.'),
          RuleExample(
            text: 'يس',
            note: 'الياء من حروف المد الطبيعي في الفواتح.',
          ),
        ],
      ),
    ],
  ),
];

List<TajweedRule> get allRules => [
  for (final section in tajweedSections) ...section.rules,
];

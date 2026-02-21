enum PracticeType { mcq, trueFalse, letterMatch, sectionMatch }

enum PracticeScope { all, section, rule }

extension PracticeTypeX on PracticeType {
  String get label {
    switch (this) {
      case PracticeType.mcq:
        return 'اختيار من متعدد';
      case PracticeType.trueFalse:
        return 'صح أو خطأ';
      case PracticeType.letterMatch:
        return 'تحديد الحرف';
      case PracticeType.sectionMatch:
        return 'تحديد القسم';
    }
  }

  String get value => name;

  static PracticeType fromValue(String value) {
    return PracticeType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => PracticeType.mcq,
    );
  }
}

extension PracticeScopeX on PracticeScope {
  String get label {
    switch (this) {
      case PracticeScope.all:
        return 'كل الأحكام';
      case PracticeScope.section:
        return 'قسم محدد';
      case PracticeScope.rule:
        return 'حكم محدد';
    }
  }
}

class PracticeConfig {
  const PracticeConfig({
    required this.practiceType,
    required this.questionCount,
    required this.scope,
    this.sectionId,
    this.ruleId,
    this.useOnlineSource = false,
    this.durationMinutes,
  });

  final PracticeType practiceType;
  final int questionCount;
  final PracticeScope scope;
  final String? sectionId;
  final String? ruleId;
  final bool useOnlineSource;
  final int? durationMinutes;

  bool get isTimedMode => durationMinutes != null;
}

class PracticeQuestion {
  const PracticeQuestion({
    required this.id,
    required this.ruleId,
    required this.prompt,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });

  final String id;
  final String ruleId;
  final String prompt;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
}

class PracticeAnswer {
  const PracticeAnswer({
    required this.ruleId,
    required this.questionPrompt,
    required this.chosenAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  final String ruleId;
  final String questionPrompt;
  final String chosenAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;

  Map<String, dynamic> toJson() {
    return {
      'ruleId': ruleId,
      'questionPrompt': questionPrompt,
      'chosenAnswer': chosenAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }

  factory PracticeAnswer.fromJson(Map<String, dynamic> json) {
    return PracticeAnswer(
      ruleId: json['ruleId'] as String? ?? '',
      questionPrompt: json['questionPrompt'] as String? ?? '',
      chosenAnswer: json['chosenAnswer'] as String? ?? '',
      correctAnswer: json['correctAnswer'] as String? ?? '',
      isCorrect: json['isCorrect'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class PracticeAttempt {
  const PracticeAttempt({
    required this.id,
    required this.createdAt,
    required this.practiceType,
    required this.questionCount,
    required this.correctCount,
    required this.answers,
    this.durationMinutes,
  });

  final String id;
  final DateTime createdAt;
  final PracticeType practiceType;
  final int questionCount;
  final int correctCount;
  final List<PracticeAnswer> answers;
  final int? durationMinutes;

  double get score {
    if (questionCount == 0) {
      return 0;
    }
    return (correctCount / questionCount) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'practiceType': practiceType.value,
      'questionCount': questionCount,
      'correctCount': correctCount,
      'durationMinutes': durationMinutes,
      'answers': answers.map((answer) => answer.toJson()).toList(),
    };
  }

  factory PracticeAttempt.fromJson(Map<String, dynamic> json) {
    final answerList = (json['answers'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (entry) => PracticeAnswer.fromJson(Map<String, dynamic>.from(entry)),
        )
        .toList();

    return PracticeAttempt(
      id: json['id'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      practiceType: PracticeTypeX.fromValue(
        json['practiceType'] as String? ?? 'mcq',
      ),
      questionCount: json['questionCount'] as int? ?? answerList.length,
      correctCount: json['correctCount'] as int? ?? 0,
      durationMinutes: json['durationMinutes'] as int?,
      answers: answerList,
    );
  }
}

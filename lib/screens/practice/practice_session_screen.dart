import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/practice_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_numbers.dart';
import '../../widgets/mono_numbers_text.dart';
import 'practice_result_screen.dart';

class PracticeSessionScreen extends StatefulWidget {
  const PracticeSessionScreen({
    required this.config,
    required this.questions,
    super.key,
  });

  final PracticeConfig config;
  final List<PracticeQuestion> questions;

  @override
  State<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends State<PracticeSessionScreen> {
  int _currentIndex = 0;
  late final List<int?> _selectedOptions;
  late final List<String?> _selectedLetterAnswers;
  late final List<_LetterTapSelection?> _selectedLetterSelections;
  Timer? _timer;
  int? _remainingSeconds;
  bool _isSubmitting = false;

  static const String _noRuleToken = '__NO_RULE__';
  static const String _skipToken = '__SKIP__';

  @override
  void initState() {
    super.initState();
    _selectedOptions = List<int?>.filled(widget.questions.length, null);
    _selectedLetterAnswers = List<String?>.filled(
      widget.questions.length,
      null,
    );
    _selectedLetterSelections = List<_LetterTapSelection?>.filled(
      widget.questions.length,
      null,
    );
    if (widget.config.durationMinutes != null) {
      _remainingSeconds = widget.config.durationMinutes! * 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || _remainingSeconds == null) {
          timer.cancel();
          return;
        }
        if (_remainingSeconds! <= 1) {
          timer.cancel();
          _remainingSeconds = 0;
          _submit(force: true);
          return;
        }
        setState(() {
          _remainingSeconds = _remainingSeconds! - 1;
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: MonoNumbersText(
            'التدريب • ${arabicInt(_currentIndex + 1)}/${arabicInt(widget.questions.length)}',
          ),
          actions: [
            if (_remainingSeconds != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MonoNumbersText(
                      _formatTime(_remainingSeconds!),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.16),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFFFF), Color(0xFFF5FEFF)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  question.prompt,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: question.isLetterTapQuestion
                    ? _buildLetterTapQuestion(question)
                    : _buildOptionsQuestion(question),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_currentIndex > 0)
                    OutlinedButton.icon(
                      onPressed: _goToPrevious,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('السابق'),
                    ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _isLastQuestion ? _submit : _goToNext,
                    icon: Icon(
                      _isLastQuestion
                          ? Icons.flag_circle_rounded
                          : Icons.arrow_back_rounded,
                    ),
                    label: Text(_isLastQuestion ? 'إنهاء' : 'التالي'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isLastQuestion => _currentIndex == widget.questions.length - 1;

  void _goToNext() {
    if (!_hasAnswerAt(_currentIndex)) {
      final question = widget.questions[_currentIndex];
      _showMessage(
        question.isLetterTapQuestion
            ? 'اختر حرفًا أولًا.'
            : 'اختر إجابة أولًا.',
      );
      return;
    }

    setState(() {
      if (!_isLastQuestion) {
        _currentIndex++;
      }
    });
  }

  void _goToPrevious() {
    setState(() {
      _currentIndex--;
    });
  }

  Future<void> _submit({bool force = false}) async {
    if (_isSubmitting) {
      return;
    }
    if (!force && !_hasAnswerAt(_currentIndex)) {
      final question = widget.questions[_currentIndex];
      _showMessage(
        question.isLetterTapQuestion
            ? 'اختر حرفًا في السؤال الأخير أولًا.'
            : 'اختر إجابة السؤال الأخير أولًا.',
      );
      return;
    }
    _isSubmitting = true;
    _timer?.cancel();

    int correctCount = 0;
    final answers = <PracticeAnswer>[];

    for (var i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final selectedIndex = _selectedOptions[i];
      final selectedLetter = _selectedLetterAnswers[i];
      final isCorrect = question.isLetterTapQuestion
          ? _isLetterCorrect(question, selectedLetter)
          : _isOptionCorrect(question, selectedIndex);
      if (isCorrect) {
        correctCount++;
      }

      final chosenAnswer = question.isLetterTapQuestion
          ? _letterAnswerLabel(selectedLetter)
          : _selectedOptionText(question, selectedIndex);
      final correctAnswer = question.isLetterTapQuestion
          ? _letterCorrectAnswerLabel(question)
          : _correctOptionText(question);

      answers.add(
        PracticeAnswer(
          ruleId: question.ruleId,
          questionPrompt: question.prompt,
          chosenAnswer: chosenAnswer,
          correctAnswer: correctAnswer,
          isCorrect: isCorrect,
          explanation: question.explanation,
        ),
      );
    }

    final attempt = PracticeAttempt(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      practiceType: widget.config.practiceType,
      questionCount: widget.questions.length,
      correctCount: correctCount,
      answers: answers,
      durationMinutes: widget.config.durationMinutes,
    );

    final result = await Navigator.of(context).push<PracticeAttempt>(
      MaterialPageRoute<PracticeAttempt>(
        builder: (_) => PracticeResultScreen(attempt: attempt),
      ),
    );

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(result ?? attempt);
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return toArabicDigits('$minutes:$seconds');
  }

  Widget _buildOptionsQuestion(PracticeQuestion question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, optionIndex) {
        final isSelected = _selectedOptions[_currentIndex] == optionIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.16)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.primary.withValues(alpha: 0.12),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            onTap: () {
              setState(() {
                _selectedOptions[_currentIndex] = optionIndex;
              });
            },
            title: Text(
              question.options[optionIndex],
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 18,
              ),
            ),
            trailing: Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: isSelected ? AppTheme.primary : Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLetterTapQuestion(PracticeQuestion question) {
    const contentPadding = EdgeInsets.all(14);
    const ayahStyle = TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: Color(0xFF102126),
      height: 1.5,
    );
    final selectedAnswer = _selectedLetterAnswers[_currentIndex];
    final selection = _selectedLetterSelections[_currentIndex];
    final selectedLetter = selection?.normalizedLetter;
    final selectedLabel = _letterAnswerLabel(selectedAnswer);
    final isCorrect = selectedLetter == null
        ? (selectedAnswer == null
              ? null
              : _isLetterCorrect(question, selectedAnswer))
        : _isLetterCorrect(question, selectedAnswer);

    return ListView(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return _buildInteractiveAyahCard(
              sourceText: question.sourceText!,
              maxWidth: constraints.maxWidth,
              style: ayahStyle,
              contentPadding: contentPadding,
              selection: selection,
            );
          },
        ),
        const SizedBox(height: 10),
        if (selectedAnswer != null)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                'اختيارك: $selectedLabel',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedLetterAnswers[_currentIndex] = _noRuleToken;
                  _selectedLetterSelections[_currentIndex] = null;
                });
              },
              icon: const Icon(Icons.help_outline_rounded),
              label: const Text('لا يوجد حكم هنا'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedLetterAnswers[_currentIndex] = _skipToken;
                  _selectedLetterSelections[_currentIndex] = null;
                  if (!_isLastQuestion) {
                    _currentIndex++;
                  }
                });
              },
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('تخطي'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (selectedAnswer == null)
          const Text(
            'اضغط على أي حرف من النص.',
            style: TextStyle(color: Color(0xFF50636B), fontSize: 16),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: (isCorrect ?? false)
                  ? Colors.green.withValues(alpha: 0.08)
                  : Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isCorrect ?? false)
                    ? Colors.green.withValues(alpha: 0.35)
                    : Colors.red.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              (isCorrect ?? false)
                  ? 'إجابة صحيحة.'
                  : 'غير صحيح. اختر حرفًا آخر أو أكمل.',
              style: TextStyle(
                color: (isCorrect ?? false)
                    ? const Color(0xFF196D2E)
                    : const Color(0xFF9A1C1C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  bool _hasAnswerAt(int index) {
    final question = widget.questions[index];
    if (question.isLetterTapQuestion) {
      return _selectedLetterAnswers[index] != null;
    }
    return _selectedOptions[index] != null;
  }

  bool _isOptionCorrect(PracticeQuestion question, int? selectedIndex) {
    final correctIndex = question.correctOptionIndex;
    if (selectedIndex == null || correctIndex == null) {
      return false;
    }
    if (correctIndex < 0 || correctIndex >= question.options.length) {
      return false;
    }
    return selectedIndex == correctIndex;
  }

  String _selectedOptionText(PracticeQuestion question, int? selectedIndex) {
    if (selectedIndex == null) {
      return 'بدون إجابة';
    }
    if (selectedIndex < 0 || selectedIndex >= question.options.length) {
      return 'بدون إجابة';
    }
    return question.options[selectedIndex];
  }

  String _correctOptionText(PracticeQuestion question) {
    final correctIndex = question.correctOptionIndex;
    if (correctIndex == null) {
      return '';
    }
    if (correctIndex < 0 || correctIndex >= question.options.length) {
      return '';
    }
    return question.options[correctIndex];
  }

  bool _isLetterCorrect(PracticeQuestion question, String? selectedLetter) {
    if (selectedLetter == null) {
      return false;
    }
    if (selectedLetter == _skipToken) {
      return false;
    }
    if (selectedLetter == _noRuleToken) {
      return !_textContainsValidLetters(question);
    }
    final normalizedSelected = _normalizeArabicLetter(selectedLetter);
    if (normalizedSelected.isEmpty) {
      return false;
    }
    final normalizedValid = question.validLetters
        .map(_normalizeArabicLetter)
        .where((item) => item.isNotEmpty)
        .toSet();
    return normalizedValid.contains(normalizedSelected);
  }

  bool _textContainsValidLetters(PracticeQuestion question) {
    final source = question.sourceText ?? '';
    if (source.isEmpty || question.validLetters.isEmpty) {
      return false;
    }
    final sourceLetters = RegExp(r'[ء-ي]')
        .allMatches(source)
        .map((match) => match.group(0))
        .whereType<String>()
        .toSet();
    final normalizedValid = question.validLetters
        .map(_normalizeArabicLetter)
        .where((item) => item.isNotEmpty)
        .toSet();
    return normalizedValid.any(sourceLetters.contains);
  }

  String _letterCorrectAnswerLabel(PracticeQuestion question) {
    if (!_textContainsValidLetters(question)) {
      return 'لا يوجد حكم هنا';
    }
    return question.validLetters.join('، ');
  }

  String _letterAnswerLabel(String? answer) {
    if (answer == null) {
      return 'بدون إجابة';
    }
    if (answer == _noRuleToken) {
      return 'لا يوجد حكم هنا';
    }
    if (answer == _skipToken) {
      return 'تم التخطي';
    }
    return answer;
  }

  String _normalizeArabicLetter(String input) {
    final withoutMarks = input.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    );
    final match = RegExp(r'[ء-ي]').firstMatch(withoutMarks);
    return match?.group(0) ?? '';
  }

  TextSpan _buildAyahSpan({
    required String sourceText,
    required TextStyle style,
    required _LetterTapSelection? selection,
  }) {
    if (selection == null ||
        selection.start < 0 ||
        selection.end > sourceText.length ||
        selection.start >= selection.end) {
      return TextSpan(text: sourceText, style: style);
    }

    final before = sourceText.substring(0, selection.start);
    final selected = sourceText.substring(selection.start, selection.end);
    final after = sourceText.substring(selection.end);
    return TextSpan(
      style: style,
      children: [
        TextSpan(text: before),
        TextSpan(
          text: selected,
          style: style.copyWith(
            color: AppTheme.primary,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
            fontWeight: FontWeight.w900,
          ),
        ),
        TextSpan(text: after),
      ],
    );
  }

  Widget _buildInteractiveAyahCard({
    required String sourceText,
    required double maxWidth,
    required TextStyle style,
    required EdgeInsets contentPadding,
    required _LetterTapSelection? selection,
  }) {
    final layoutWidth = maxWidth - contentPadding.horizontal;
    final safeWidth = layoutWidth > 0 ? layoutWidth : 1.0;
    final painter = TextPainter(
      text: TextSpan(text: sourceText, style: style),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    )..layout(maxWidth: safeWidth);
    final tapRegions = _buildLetterTapRegions(
      sourceText: sourceText,
      painter: painter,
    );

    return Container(
      width: double.infinity,
      padding: contentPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
      ),
      child: SizedBox(
        width: safeWidth,
        height: painter.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Text.rich(
                  _buildAyahSpan(
                    sourceText: sourceText,
                    style: style,
                    selection: selection,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            for (final region in tapRegions)
              Positioned.fromRect(
                rect: region.rect.inflate(0.5),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      _selectedLetterAnswers[_currentIndex] =
                          region.selection.normalizedLetter;
                      _selectedLetterSelections[_currentIndex] =
                          region.selection;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_LetterTapRegion> _buildLetterTapRegions({
    required String sourceText,
    required TextPainter painter,
  }) {
    final regions = <_LetterTapRegion>[];
    for (var i = 0; i < sourceText.length; i++) {
      final normalized = _normalizeArabicLetter(sourceText[i]);
      if (normalized.isEmpty) {
        continue;
      }

      final end = _expandSelectionEnd(sourceText: sourceText, start: i);
      final boxes = painter.getBoxesForSelection(
        TextSelection(baseOffset: i, extentOffset: end),
      );
      if (boxes.isEmpty) {
        continue;
      }
      final rect = _mergeTextBoxes(boxes);
      if (rect.width <= 0 || rect.height <= 0) {
        continue;
      }

      regions.add(
        _LetterTapRegion(
          selection: _LetterTapSelection(
            normalizedLetter: normalized,
            start: i,
            end: end,
          ),
          rect: rect,
        ),
      );
      i = end - 1;
    }
    return regions;
  }

  int _expandSelectionEnd({required String sourceText, required int start}) {
    var end = start + 1;
    while (end < sourceText.length && _isArabicMark(sourceText[end])) {
      end++;
    }
    return end;
  }

  bool _isArabicMark(String input) =>
      RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]').hasMatch(input);

  Rect _mergeTextBoxes(List<ui.TextBox> boxes) {
    var left = boxes.first.left;
    var top = boxes.first.top;
    var right = boxes.first.right;
    var bottom = boxes.first.bottom;
    for (final box in boxes.skip(1)) {
      if (box.left < left) {
        left = box.left;
      }
      if (box.top < top) {
        top = box.top;
      }
      if (box.right > right) {
        right = box.right;
      }
      if (box.bottom > bottom) {
        bottom = box.bottom;
      }
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }
}

class _LetterTapSelection {
  const _LetterTapSelection({
    required this.normalizedLetter,
    required this.start,
    required this.end,
  });

  final String normalizedLetter;
  final int start;
  final int end;
}

class _LetterTapRegion {
  const _LetterTapRegion({required this.selection, required this.rect});

  final _LetterTapSelection selection;
  final Rect rect;
}

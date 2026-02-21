import 'dart:async';

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
  late final List<String?> _selectedLetters;
  Timer? _timer;
  int? _remainingSeconds;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List<int?>.filled(widget.questions.length, null);
    _selectedLetters = List<String?>.filled(widget.questions.length, null);
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
      final selectedLetter = _selectedLetters[i];
      final isCorrect = question.isLetterTapQuestion
          ? _isLetterCorrect(selectedLetter, question.validLetters)
          : _isOptionCorrect(question, selectedIndex);
      if (isCorrect) {
        correctCount++;
      }

      final chosenAnswer = question.isLetterTapQuestion
          ? (selectedLetter ?? 'بدون إجابة')
          : _selectedOptionText(question, selectedIndex);
      final correctAnswer = question.isLetterTapQuestion
          ? question.validLetters.join('، ')
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
    final selectedLetter = _selectedLetters[_currentIndex];
    final isCorrect = selectedLetter == null
        ? null
        : _isLetterCorrect(selectedLetter, question.validLetters);

    return ListView(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final tappedLetter = _extractTappedLetter(
                  sourceText: question.sourceText!,
                  localPosition: details.localPosition,
                  maxWidth: constraints.maxWidth,
                  textStyle: ayahStyle,
                  contentPadding: contentPadding,
                );
                if (tappedLetter == null) {
                  return;
                }
                setState(() {
                  _selectedLetters[_currentIndex] = tappedLetter;
                });
              },
              child: Container(
                width: double.infinity,
                padding: contentPadding,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  question.sourceText!,
                  textAlign: TextAlign.right,
                  style: ayahStyle,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        if (selectedLetter != null)
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
                'الحرف المختار: $selectedLetter',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        if (selectedLetter == null)
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
      return _selectedLetters[index] != null;
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

  bool _isLetterCorrect(String? selectedLetter, List<String> validLetters) {
    if (selectedLetter == null) {
      return false;
    }
    final normalizedSelected = _normalizeArabicLetter(selectedLetter);
    if (normalizedSelected.isEmpty) {
      return false;
    }
    final normalizedValid = validLetters
        .map(_normalizeArabicLetter)
        .where((item) => item.isNotEmpty)
        .toSet();
    return normalizedValid.contains(normalizedSelected);
  }

  String _normalizeArabicLetter(String input) {
    final withoutMarks = input.replaceAll(
      RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    );
    final match = RegExp(r'[ء-ي]').firstMatch(withoutMarks);
    return match?.group(0) ?? '';
  }

  String? _extractTappedLetter({
    required String sourceText,
    required Offset localPosition,
    required double maxWidth,
    required TextStyle textStyle,
    required EdgeInsets contentPadding,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: sourceText, style: textStyle),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );
    painter.layout(maxWidth: maxWidth - contentPadding.horizontal);

    final textOffset =
        localPosition - Offset(contentPadding.left, contentPadding.top);
    if (textOffset.dx < 0 ||
        textOffset.dy < 0 ||
        textOffset.dx > painter.width ||
        textOffset.dy > painter.height) {
      return null;
    }

    final tappedTextOffset = painter.getPositionForOffset(textOffset).offset;
    return _resolveLetterFromOffset(sourceText, tappedTextOffset);
  }

  String? _resolveLetterFromOffset(String sourceText, int offset) {
    if (sourceText.isEmpty || offset < 0 || offset >= sourceText.length) {
      return null;
    }

    final candidates = [offset, offset - 1, offset + 1, offset - 2, offset + 2];
    for (final candidate in candidates) {
      if (candidate < 0 || candidate >= sourceText.length) {
        continue;
      }
      final normalized = _normalizeArabicLetter(sourceText[candidate]);
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }
    return null;
  }
}

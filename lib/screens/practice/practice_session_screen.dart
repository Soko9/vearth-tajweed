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
  Timer? _timer;
  int? _remainingSeconds;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedOptions = List<int?>.filled(widget.questions.length, null);
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
                child: ListView.builder(
                  itemCount: question.options.length,
                  itemBuilder: (context, optionIndex) {
                    final isSelected =
                        _selectedOptions[_currentIndex] == optionIndex;
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
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: isSelected ? AppTheme.primary : Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
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
    if (_selectedOptions[_currentIndex] == null) {
      _showMessage('اختر إجابة أولًا.');
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
    if (!force && _selectedOptions[_currentIndex] == null) {
      _showMessage('اختر إجابة السؤال الأخير أولًا.');
      return;
    }
    _isSubmitting = true;
    _timer?.cancel();

    int correctCount = 0;
    final answers = <PracticeAnswer>[];

    for (var i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final selectedIndex = _selectedOptions[i];
      final isCorrect = selectedIndex == question.correctOptionIndex;
      if (isCorrect) {
        correctCount++;
      }

      answers.add(
        PracticeAnswer(
          ruleId: question.ruleId,
          questionPrompt: question.prompt,
          chosenAnswer: selectedIndex == null
              ? 'بدون إجابة'
              : question.options[selectedIndex],
          correctAnswer: question.options[question.correctOptionIndex],
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
}

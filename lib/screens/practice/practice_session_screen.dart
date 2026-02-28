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
    final progress = _sessionProgress;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(widget.config.practiceType.label),
          actions: [
            if (_remainingSeconds != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 14),
                child: Center(child: _timerChip()),
              ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSessionHeader(progress),
                if (!_isTimedMode) ...[
                  const SizedBox(height: 10),
                  _buildQuestionStrip(),
                ],
                const SizedBox(height: 10),
                _buildQuestionCard(question),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, optionIndex) {
                      final isSelected =
                          _selectedOptions[_currentIndex] == optionIndex;
                      return _buildOptionCard(
                        optionText: question.options[optionIndex],
                        optionIndex: optionIndex,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedOptions[_currentIndex] = optionIndex;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionHeader(double progress) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF245C66), Color(0xFF3A8C7C)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonoNumbersText(
                  _isTimedMode
                      ? 'الأسئلة المجابة: ${arabicInt(_answeredCount)}'
                      : 'السؤال ${arabicInt(_currentIndex + 1)} من ${arabicInt(widget.questions.length)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                  ),
                ),
                const SizedBox(height: 6),
                MonoNumbersText(
                  _isTimedMode
                      ? 'أكمل حتى نهاية المؤقت'
                      : 'تمت الإجابة: ${arabicInt(_answeredCount)} / ${arabicInt(widget.questions.length)}',
                  style: const TextStyle(
                    color: Color(0xFFE7F4F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.24),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  color: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.22),
                ),
                MonoNumbersText(
                  '${arabicInt((progress * 100).round())}٪',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(widget.questions.length, (index) {
            final isCurrent = index == _currentIndex;
            final isAnswered = _selectedOptions[index] != null;
            return Padding(
              padding: EdgeInsetsDirectional.only(
                start: index == 0 ? 10 : 5,
                end: index == widget.questions.length - 1 ? 10 : 0,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.primary
                          : (isAnswered
                                ? AppTheme.accent.withValues(alpha: 0.18)
                                : AppTheme.surfaceAlt(context)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.primary
                            : AppTheme.primary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Center(
                      child: MonoNumbersText(
                        arabicInt(index + 1),
                        style: TextStyle(
                          color: isCurrent
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(PracticeQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.surface(context),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'السؤال الحالي',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.prompt,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String optionText,
    required int optionIndex,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final badge = _optionBadge(optionIndex);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.12)
                : AppTheme.surface(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.primary.withValues(alpha: 0.14),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.surfaceAlt(context),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  optionText,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.mutedText(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Row(
        children: [
          if (_currentIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _goToPrevious,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: const Text('السابق'),
              ),
            ),
          if (_currentIndex > 0) const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: _isLastQuestion ? _submit : _goToNext,
              icon: Icon(
                _isLastQuestion
                    ? Icons.flag_circle_rounded
                    : Icons.arrow_back_rounded,
              ),
              label: Text(_isLastQuestion ? 'إنهاء التدريب' : 'التالي'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: MonoNumbersText(
        _formatTime(_remainingSeconds!),
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }

  String _optionBadge(int optionIndex) {
    const badges = ['أ', 'ب', 'ج', 'د', 'هـ', 'و', 'ز', 'ح'];
    if (optionIndex < badges.length) {
      return badges[optionIndex];
    }
    return toArabicDigits((optionIndex + 1).toString());
  }

  int get _answeredCount =>
      _selectedOptions.where((entry) => entry != null).length;

  bool get _isTimedMode => widget.config.durationMinutes != null;

  double get _sessionProgress {
    if (!_isTimedMode || _remainingSeconds == null) {
      return (_currentIndex + 1) / widget.questions.length;
    }
    final totalSeconds = widget.config.durationMinutes! * 60;
    if (totalSeconds <= 0) {
      return 0;
    }
    final elapsed = totalSeconds - _remainingSeconds!;
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
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

      if (_isTimedMode && selectedIndex == null) {
        continue;
      }

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

    final evaluatedQuestionCount = _isTimedMode
        ? answers.length
        : widget.questions.length;

    final attempt = PracticeAttempt(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      practiceType: widget.config.practiceType,
      questionCount: evaluatedQuestionCount,
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

import 'package:flutter/material.dart';

import '../../models/practice_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_numbers.dart';
import '../../widgets/mono_numbers_text.dart';

class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({required this.attempt, super.key});

  final PracticeAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final wrongAnswers = attempt.answers
        .where((answer) => !answer.isCorrect)
        .toList();
    final answeredCount = attempt.answers
        .where((answer) => answer.chosenAnswer != 'بدون إجابة')
        .length;
    final isTimed = attempt.durationMinutes != null;
    final displayedScore = isTimed
        ? (answeredCount == 0
              ? 0.0
              : (attempt.correctCount / answeredCount) * 100)
        : attempt.score;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('نتيجة التدريب')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF39B4C8)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Column(
                children: [
                  MonoNumbersText(
                    isTimed
                        ? '${arabicInt(attempt.correctCount)} / ${arabicInt(answeredCount)}'
                        : '${arabicInt(attempt.correctCount)} / ${arabicInt(attempt.questionCount)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  MonoNumbersText(
                    isTimed
                        ? 'دقة الإجابات ${arabicFixed(displayedScore, digits: 1)}٪'
                        : 'نسبة النجاح ${arabicFixed(attempt.score, digits: 1)}٪',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (attempt.durationMinutes != null) ...[
                    const SizedBox(height: 6),
                    MonoNumbersText(
                      'مدة الجلسة: ${arabicInt(attempt.durationMinutes!)} دقائق',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: displayedScore / 100,
                      minHeight: 10,
                      color: AppTheme.secondary,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'الأخطاء التي تحتاج مراجعة',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            const SizedBox(height: 8),
            if (wrongAnswers.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text('ممتاز! لا توجد أخطاء في هذه المحاولة.'),
              )
            else
              for (final answer in wrongAnswers)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        answer.questionPrompt,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'إجابتك: ${answer.chosenAnswer}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الصحيح: ${answer.correctAnswer}',
                        style: const TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 6),
                      Text(answer.explanation),
                    ],
                  ),
                ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop(attempt);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
              icon: const Icon(Icons.keyboard_return_rounded),
              label: const Text('رجوع وحفظ النتيجة'),
            ),
          ],
        ),
      ),
    );
  }
}

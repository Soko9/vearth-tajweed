import 'package:flutter/material.dart';

import '../../models/practice_models.dart';

class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({required this.attempt, super.key});

  final PracticeAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final wrongAnswers = attempt.answers
        .where((answer) => !answer.isCorrect)
        .toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('نتيجة التدريب')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      '${attempt.correctCount} / ${attempt.questionCount}',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'نسبة النجاح ${attempt.score.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (attempt.durationMinutes != null) ...[
                      const SizedBox(height: 6),
                      Text('مدة الجلسة: ${attempt.durationMinutes} دقائق'),
                    ],
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: attempt.score / 100),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'مراجعة الأخطاء',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (wrongAnswers.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('ممتاز! لا توجد إجابات خاطئة في هذه المحاولة.'),
                ),
              )
            else
              for (final answer in wrongAnswers)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(attempt);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('العودة إلى التدريب'),
            ),
          ],
        ),
      ),
    );
  }
}

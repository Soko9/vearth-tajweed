import 'package:flutter/material.dart';

import '../models/practice_models.dart';
import '../models/tajweed_models.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({
    required this.attempts,
    required this.rules,
    super.key,
  });

  final List<PracticeAttempt> attempts;
  final List<TajweedRule> rules;

  @override
  Widget build(BuildContext context) {
    if (attempts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'لا توجد تدريبات محفوظة بعد. ابدأ أول تمرين ليظهر التحليل هنا.',
            ),
          ),
        ),
      );
    }

    final ruleStats = _buildRuleStats();
    final weakRules = [...ruleStats]
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
    final strongRules = [...ruleStats]
      ..sort((a, b) => b.accuracy.compareTo(a.accuracy));

    final totalSessions = attempts.length;
    final avgScore =
        attempts
            .map((attempt) => attempt.score)
            .reduce((value, element) => value + element) /
        totalSessions;
    final totalQuestions = attempts
        .map((attempt) => attempt.questionCount)
        .reduce((value, element) => value + element);

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص الأداء',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('عدد الجلسات: $totalSessions'),
                Text('إجمالي الأسئلة: $totalQuestions'),
                Text('متوسط النتيجة: ${avgScore.toStringAsFixed(1)}%'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _ruleBlock(
          context: context,
          title: 'أحكام تحتاج تدريبًا أكثر',
          data: weakRules.take(4).toList(),
          emptyText: 'الأداء متوازن ولم يظهر ضعف واضح بعد.',
        ),
        const SizedBox(height: 10),
        _ruleBlock(
          context: context,
          title: 'أحكام قوية لديك',
          data: strongRules.take(4).toList(),
          emptyText: 'أكمل تدريبات أكثر لإبراز نقاط القوة.',
        ),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سجل المحاولات',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final attempt in attempts.take(8))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history_rounded),
                    title: Text(
                      '${attempt.practiceType.label} • ${attempt.score.toStringAsFixed(0)}%',
                    ),
                    subtitle: Text(
                      '${_formatDate(attempt.createdAt)} • ${attempt.correctCount}/${attempt.questionCount}${attempt.durationMinutes != null ? ' • ${attempt.durationMinutes}د' : ''}',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _ruleBlock({
    required BuildContext context,
    required String title,
    required List<_RuleStat> data,
    required String emptyText,
  }) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(emptyText),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final item in data)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(item.rule.name)),
                        Text('${item.accuracy.toStringAsFixed(0)}%'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: item.accuracy / 100,
                        minHeight: 8,
                        color: item.rule.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الإجابات الصحيحة ${item.correct} من ${item.total}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<_RuleStat> _buildRuleStats() {
    final map = {
      for (final rule in rules)
        rule.id: _RuleStat(rule: rule, total: 0, correct: 0),
    };

    for (final attempt in attempts) {
      for (final answer in attempt.answers) {
        final item = map[answer.ruleId];
        if (item == null) {
          continue;
        }
        item.total += 1;
        if (answer.isCorrect) {
          item.correct += 1;
        }
      }
    }

    return map.values.where((item) => item.total > 0).toList();
  }

  String _formatDate(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '${value.day}/${value.month}/${value.year} - $hh:$mm';
  }
}

class _RuleStat {
  _RuleStat({required this.rule, required this.total, required this.correct});

  final TajweedRule rule;
  int total;
  int correct;

  double get accuracy {
    if (total == 0) {
      return 0;
    }
    return (correct / total) * 100;
  }
}

import 'package:flutter/material.dart';

import '../models/practice_models.dart';
import '../models/tajweed_models.dart';
import '../theme/app_theme.dart';
import '../utils/arabic_numbers.dart';
import '../widgets/mono_numbers_text.dart';

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
      return ListView(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border(context)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.insights_rounded, size: 36, color: AppTheme.primary),
                SizedBox(height: 10),
                Text(
                  'لا توجد نتائج بعد',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
                ),
                SizedBox(height: 6),
                Text(
                  'ابدأ تدريبًا واحدًا على الأقل وسيظهر التحليل التفصيلي هنا.',
                ),
              ],
            ),
          ),
        ],
      );
    }

    final ruleStats = _buildRuleStats();
    final weakRules = [...ruleStats]
      ..sort((a, b) => a.accuracy.compareTo(b.accuracy));
    final strongRules = [...ruleStats]
      ..sort((a, b) => b.accuracy.compareTo(a.accuracy));

    final totalSessions = attempts.length;
    final avgScore =
        attempts.map((attempt) => attempt.score).reduce((a, b) => a + b) /
        totalSessions;
    final totalQuestions = attempts
        .map((attempt) => attempt.questionCount)
        .reduce((a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ملخص الأداء',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),
              MonoNumbersText(
                'عدد الجلسات: ${arabicInt(totalSessions)}',
                style: _statStyle(context),
              ),
              MonoNumbersText(
                'إجمالي الأسئلة: ${arabicInt(totalQuestions)}',
                style: _statStyle(context),
              ),
              MonoNumbersText(
                'متوسط النتيجة: ${arabicFixed(avgScore, digits: 1)}٪',
                style: _statStyle(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ruleBlock(
          context: context,
          title: 'أحكام تحتاج تدريبًا أكثر',
          data: weakRules.take(4).toList(),
          emptyText: 'الأداء متوازن الآن.',
          color: AppTheme.secondary,
        ),
        const SizedBox(height: 12),
        _ruleBlock(
          context: context,
          title: 'أحكام قوية لديك',
          data: strongRules.take(4).toList(),
          emptyText: 'أكمل تدريبات أكثر لإظهار نقاط القوة.',
          color: AppTheme.accent,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'آخر المحاولات',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
              const SizedBox(height: 10),
              for (final attempt in attempts.take(8))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  horizontalTitleGap: 10,
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.13),
                    child: const Icon(
                      Icons.history_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                  title: MonoNumbersText(
                    '${attempt.practiceType.label} • ${arabicFixed(attempt.score, digits: 0)}٪',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: MonoNumbersText(
                    '${_formatDate(attempt.createdAt)} • ${arabicInt(attempt.correctCount)}/${arabicInt(attempt.questionCount)}${attempt.durationMinutes != null ? ' • ${arabicInt(attempt.durationMinutes!)}د' : ''}',
                  ),
                ),
            ],
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
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(height: 8),
          if (data.isEmpty)
            Text(emptyText)
          else
            for (final item in data)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.rule.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        MonoNumbersText(
                          '${arabicFixed(item.accuracy, digits: 0)}٪',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: item.accuracy / 100,
                        minHeight: 9,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.18),
                      ),
                    ),
                    const SizedBox(height: 4),
                    MonoNumbersText(
                      'صحيح ${arabicInt(item.correct)} من ${arabicInt(item.total)}',
                      style: TextStyle(color: AppTheme.mutedText(context)),
                    ),
                  ],
                ),
              ),
        ],
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
    return toArabicDigits(
      '${value.day}/${value.month}/${value.year} - $hh:$mm',
    );
  }

  TextStyle _statStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w700,
      fontSize: 17,
    );
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

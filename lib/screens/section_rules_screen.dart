import 'package:flutter/material.dart';

import '../data/tajweed_content.dart';
import '../models/tajweed_models.dart';
import '../theme/app_theme.dart';
import 'rule_details_screen.dart';

class SectionRulesScreen extends StatelessWidget {
  const SectionRulesScreen({required this.section, super.key});

  final TajweedSection section;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(section.title)),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border(context)),
              ),
              child: Text(
                section.poemExcerpt,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            for (final rule in section.rules)
              _RuleCard(rule: rule, section: section),
          ],
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({required this.rule, required this.section});

  final TajweedRule rule;
  final TajweedSection section;

  @override
  Widget build(BuildContext context) {
    final rulePoemExcerpts = rulePoemExcerptsById(rule.id);
    final rulePoemPreview = rulePoemExcerpts.isEmpty
        ? ''
        : rulePoemExcerpts.first;
    final extraVersesCount = rulePoemExcerpts.length > 1
        ? rulePoemExcerpts.length - 1
        : 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? AppTheme.border(context)
              : rule.color.withValues(alpha: 0.28),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RuleDetailsScreen(
                  rule: rule,
                  sectionTitle: section.title,
                  poemExcerpt: section.poemExcerpt,
                  rulePoemExcerpts: rulePoemExcerpts,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: rule.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_left_rounded),
                  ],
                ),
                const SizedBox(height: 8),
                Text(rule.description, style: const TextStyle(fontSize: 16)),
                if (rulePoemPreview.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: rule.color.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      extraVersesCount == 0
                          ? 'من التحفة: $rulePoemPreview'
                          : 'من التحفة: $rulePoemPreview (+$extraVersesCount)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final letter in rule.letters.take(6))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: rule.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(letter),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

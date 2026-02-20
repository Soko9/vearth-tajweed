import 'package:flutter/material.dart';

import '../data/tajweed_content.dart';
import 'rule_details_screen.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      itemCount: tajweedSections.length,
      itemBuilder: (context, index) {
        final section = tajweedSections[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            title: Text(
              section.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              '${section.overview}\n${section.poemExcerpt}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            children: [
              for (final rule in section.rules)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  leading: CircleAvatar(backgroundColor: rule.color, radius: 8),
                  title: Text(rule.name),
                  subtitle: Text(
                    rule.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_left_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RuleDetailsScreen(
                          rule: rule,
                          sectionTitle: section.title,
                          poemExcerpt: section.poemExcerpt,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

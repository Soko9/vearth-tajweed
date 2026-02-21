import 'package:flutter/material.dart';

import '../data/tajweed_content.dart';
import '../utils/arabic_numbers.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/mono_numbers_text.dart';
import 'section_rules_screen.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 22),
      itemCount: tajweedSections.length,
      itemBuilder: (context, index) {
        final section = tajweedSections[index];
        final accents = const [
          Color(0xFF4F8D99),
          Color(0xFFBD7A63),
          Color(0xFF5F83B5),
        ];
        final accent = accents[index % accents.length];

        return FadeSlideIn(
          index: index,
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE3EBEF)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SectionRulesScreen(section: section),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: MonoNumbersText(
                              '${arabicInt(section.rules.length)} أحكام',
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: accent,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        section.title,
                        style: TextStyle(
                          color: accent,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        section.overview,
                        style: TextStyle(
                          color: Color(0xFF2D424A),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2EBF0)),
                        ),
                        child: Text(
                          section.poemExcerpt,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF3B5058),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

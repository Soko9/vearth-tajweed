import 'package:flutter/material.dart';

class TajweedSection {
  const TajweedSection({
    required this.id,
    required this.title,
    required this.overview,
    required this.poemExcerpt,
    required this.rules,
  });

  final String id;
  final String title;
  final String overview;
  final String poemExcerpt;
  final List<TajweedRule> rules;
}

class TajweedRule {
  const TajweedRule({
    required this.id,
    required this.sectionId,
    required this.name,
    required this.description,
    required this.letters,
    required this.examples,
    required this.tip,
    required this.colorHex,
  });

  final String id;
  final String sectionId;
  final String name;
  final String description;
  final List<String> letters;
  final List<RuleExample> examples;
  final String tip;
  final int colorHex;

  Color get color => Color(colorHex);
}

class RuleExample {
  const RuleExample({required this.text, required this.note});

  final String text;
  final String note;
}

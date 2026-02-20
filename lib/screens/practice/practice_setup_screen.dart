import 'package:flutter/material.dart';

import '../../models/practice_models.dart';
import '../../models/tajweed_models.dart';
import '../../services/practice_engine_service.dart';
import 'practice_session_screen.dart';

enum SessionLengthMode { questionCount, duration }

class PracticeSetupScreen extends StatefulWidget {
  const PracticeSetupScreen({
    required this.sections,
    required this.onAttemptSaved,
    super.key,
  });

  final List<TajweedSection> sections;
  final Future<void> Function(PracticeAttempt attempt) onAttemptSaved;

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  final PracticeEngineService _engine = PracticeEngineService();

  PracticeType _practiceType = PracticeType.mcq;
  PracticeScope _scope = PracticeScope.all;
  int _questionCount = 10;
  int _durationMinutes = 5;
  bool _useOnlineSource = false;
  SessionLengthMode _lengthMode = SessionLengthMode.questionCount;

  String? _selectedSectionId;
  String? _selectedRuleId;

  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final selectedSection = widget.sections.where(
      (section) => section.id == _selectedSectionId,
    );

    final availableRules = _scope == PracticeScope.rule
        ? (selectedSection.isEmpty ? _allRules : selectedSection.first.rules)
        : _allRules;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Column(
        children: [
          _buildTypeCard(context),
          const SizedBox(height: 12),
          _buildCountCard(context),
          const SizedBox(height: 12),
          _buildScopeCard(context, availableRules),
          const SizedBox(height: 12),
          _buildSourceCard(context),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isGenerating ? null : _startPractice,
            icon: _isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow_rounded),
            label: Text(
              _isGenerating ? 'جاري تجهيز الأسئلة...' : 'ابدأ التدريب',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1) نوع التدريب',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<PracticeType>(
              initialValue: _practiceType,
              items: PracticeType.values
                  .map(
                    (type) => DropdownMenuItem<PracticeType>(
                      value: type,
                      child: Text(type.label),
                    ),
                  )
                  .toList(),
              onChanged: (type) {
                if (type == null) {
                  return;
                }
                setState(() {
                  _practiceType = type;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'اختر نمط التدريب',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('2) طول الجلسة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  selected: _lengthMode == SessionLengthMode.questionCount,
                  label: const Text('بعدد الأسئلة'),
                  onSelected: (_) {
                    setState(() {
                      _lengthMode = SessionLengthMode.questionCount;
                    });
                  },
                ),
                ChoiceChip(
                  selected: _lengthMode == SessionLengthMode.duration,
                  label: const Text('بالمدة (دقائق)'),
                  onSelected: (_) {
                    setState(() {
                      _lengthMode = SessionLengthMode.duration;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _lengthMode == SessionLengthMode.questionCount
                  ? 'عدد الأسئلة: $_questionCount'
                  : 'المدة: $_durationMinutes دقائق',
            ),
            Slider(
              value: (_lengthMode == SessionLengthMode.questionCount
                      ? _questionCount
                      : _durationMinutes)
                  .toDouble(),
              min: _lengthMode == SessionLengthMode.questionCount ? 5 : 2,
              max: _lengthMode == SessionLengthMode.questionCount ? 30 : 20,
              divisions:
                  _lengthMode == SessionLengthMode.questionCount ? 25 : 18,
              label: _lengthMode == SessionLengthMode.questionCount
                  ? '$_questionCount'
                  : '$_durationMinutes',
              onChanged: (value) {
                setState(() {
                  if (_lengthMode == SessionLengthMode.questionCount) {
                    _questionCount = value.round();
                  } else {
                    _durationMinutes = value.round();
                  }
                });
              },
            ),
            if (_lengthMode == SessionLengthMode.duration)
              Text(
                'سيتم إنهاء التدريب تلقائيًا عند انتهاء الوقت.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeCard(
    BuildContext context,
    List<TajweedRule> availableRules,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '3) نطاق التدريب',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PracticeScope.values
                  .map(
                    (scope) => ChoiceChip(
                      selected: _scope == scope,
                      label: Text(scope.label),
                      onSelected: (_) {
                        setState(() {
                          _scope = scope;
                          if (scope == PracticeScope.all) {
                            _selectedSectionId = null;
                            _selectedRuleId = null;
                          }
                          if (scope == PracticeScope.section) {
                            _selectedRuleId = null;
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            if (_scope != PracticeScope.all) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedSectionId),
                initialValue: _selectedSectionId,
                hint: const Text('اختر القسم'),
                items: widget.sections
                    .map(
                      (section) => DropdownMenuItem<String>(
                        value: section.id,
                        child: Text(section.title),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSectionId = value;
                    _selectedRuleId = null;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
            if (_scope == PracticeScope.rule && _selectedSectionId != null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(_selectedRuleId),
                initialValue: _selectedRuleId,
                hint: const Text('اختر الحكم'),
                items: availableRules
                    .map(
                      (rule) => DropdownMenuItem<String>(
                        value: rule.id,
                        child: Text(rule.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRuleId = value;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(
          'مصدر التدريب المتصل',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: const Text('يمكنك إبقاؤه مطفأً للتدريب بالكامل دون إنترنت.'),
        value: _useOnlineSource,
        onChanged: (value) {
          setState(() {
            _useOnlineSource = value;
          });
        },
      ),
    );
  }

  List<TajweedRule> get _allRules => [
    for (final section in widget.sections) ...section.rules,
  ];

  Future<void> _startPractice() async {
    if (_scope == PracticeScope.section && _selectedSectionId == null) {
      _showMessage('اختر قسمًا أولًا.');
      return;
    }
    if (_scope == PracticeScope.rule && _selectedRuleId == null) {
      _showMessage('اختر حكمًا أولًا.');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final config = PracticeConfig(
      practiceType: _practiceType,
      questionCount: _lengthMode == SessionLengthMode.questionCount
          ? _questionCount
          : _durationMinutes * 6,
      scope: _scope,
      sectionId: _selectedSectionId,
      ruleId: _selectedRuleId,
      useOnlineSource: _useOnlineSource,
      durationMinutes: _lengthMode == SessionLengthMode.duration
          ? _durationMinutes
          : null,
    );

    final questions = await _engine.generateQuestions(
      config: config,
      sections: widget.sections,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isGenerating = false;
    });

    if (questions.isEmpty) {
      _showMessage('تعذر إنشاء أسئلة لهذا الاختيار.');
      return;
    }

    final attempt = await Navigator.of(context).push<PracticeAttempt>(
      MaterialPageRoute<PracticeAttempt>(
        builder: (_) =>
            PracticeSessionScreen(config: config, questions: questions),
      ),
    );

    if (attempt == null) {
      return;
    }

    await widget.onAttemptSaved(attempt);
    if (!mounted) {
      return;
    }
    _showMessage('تم حفظ نتيجة التدريب بنجاح.');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

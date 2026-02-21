import 'package:flutter/material.dart';

import '../../models/practice_models.dart';
import '../../models/tajweed_models.dart';
import '../../services/practice_engine_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/arabic_numbers.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/mono_numbers_text.dart';
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
    final selectedSection = widget.sections.firstWhere(
      (section) => section.id == _selectedSectionId,
      orElse: () => widget.sections.first,
    );

    final availableRules = selectedSection.rules;
    final hasSelectedRule = availableRules.any(
      (rule) => rule.id == _selectedRuleId,
    );
    if (!hasSelectedRule && _scope == PracticeScope.rule) {
      _selectedRuleId = null;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      children: [
        FadeSlideIn(
          index: 0,
          child: _glassCard(context: context, child: _buildPracticeType()),
        ),
        const SizedBox(height: 12),
        FadeSlideIn(
          index: 1,
          child: _glassCard(context: context, child: _buildLengthMode()),
        ),
        const SizedBox(height: 12),
        FadeSlideIn(
          index: 2,
          child: _glassCard(
            context: context,
            child: _buildScope(availableRules),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlideIn(
          index: 3,
          child: _glassCard(
            context: context,
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'مصدر أسئلة متصل (اختياري)',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: const Text('إذا كان مغلقًا فكل التدريب يعمل أوفلاين.'),
              value: _useOnlineSource,
              onChanged: (value) {
                setState(() {
                  _useOnlineSource = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          index: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: FilledButton.icon(
              onPressed: _isGenerating ? null : _startPractice,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.rocket_launch_rounded),
              label: Text(
                _isGenerating ? 'جاري تجهيز التدريب...' : 'ابدأ التدريب الآن',
                style: const TextStyle(fontSize: 17),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size.fromHeight(56),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MonoNumbersText(
          '١) نوع التدريب',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in PracticeType.values)
              _choiceChip(
                selected: _practiceType == type,
                label: type.label,
                onTap: () {
                  setState(() {
                    _practiceType = type;
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLengthMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MonoNumbersText(
          '٢) طول الجلسة',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        const SizedBox(height: 10),
        SegmentedButton<SessionLengthMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: SessionLengthMode.questionCount,
              label: Text('بعدد الأسئلة'),
              icon: Icon(Icons.format_list_numbered_rounded),
            ),
            ButtonSegment(
              value: SessionLengthMode.duration,
              label: Text('بالمدة'),
              icon: Icon(Icons.timer_rounded),
            ),
          ],
          selected: {_lengthMode},
          onSelectionChanged: (values) {
            setState(() {
              _lengthMode = values.first;
            });
          },
        ),
        const SizedBox(height: 10),
        MonoNumbersText(
          _lengthMode == SessionLengthMode.questionCount
              ? 'عدد الأسئلة: ${arabicInt(_questionCount)}'
              : 'مدة التدريب: ${arabicInt(_durationMinutes)} دقائق',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        Slider(
          value:
              (_lengthMode == SessionLengthMode.questionCount
                      ? _questionCount
                      : _durationMinutes)
                  .toDouble(),
          min: _lengthMode == SessionLengthMode.questionCount ? 5 : 2,
          max: _lengthMode == SessionLengthMode.questionCount ? 30 : 20,
          divisions: _lengthMode == SessionLengthMode.questionCount ? 25 : 18,
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
      ],
    );
  }

  Widget _buildScope(List<TajweedRule> availableRules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MonoNumbersText(
          '٣) نطاق التدريب',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final scope in PracticeScope.values)
              _choiceChip(
                selected: _scope == scope,
                label: scope.label,
                onTap: () {
                  setState(() {
                    _scope = scope;
                    if (scope == PracticeScope.all) {
                      _selectedSectionId = null;
                      _selectedRuleId = null;
                    } else {
                      _selectedSectionId ??= widget.sections.first.id;
                      if (scope == PracticeScope.section) {
                        _selectedRuleId = null;
                      }
                    }
                  });
                },
              ),
          ],
        ),
        if (_scope != PracticeScope.all) ...[
          const SizedBox(height: 12),
          const Text('القسم', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final section in widget.sections)
                _choiceChip(
                  selected: _selectedSectionId == section.id,
                  label: section.title,
                  onTap: () {
                    setState(() {
                      _selectedSectionId = section.id;
                      _selectedRuleId = null;
                    });
                  },
                ),
            ],
          ),
        ],
        if (_scope == PracticeScope.rule) ...[
          const SizedBox(height: 12),
          const Text('الحكم', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (availableRules.isEmpty)
            const Text('لا توجد أحكام متاحة في هذا القسم.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final rule in availableRules)
                  _choiceChip(
                    selected: _selectedRuleId == rule.id,
                    label: rule.name,
                    avatar: CircleAvatar(
                      radius: 5,
                      backgroundColor: rule.color,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedRuleId = rule.id;
                      });
                    },
                  ),
              ],
            ),
        ],
      ],
    );
  }

  Widget _glassCard({required BuildContext context, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: child,
    );
  }

  Widget _choiceChip({
    required bool selected,
    required String label,
    required VoidCallback onTap,
    Widget? avatar,
  }) {
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      avatar: avatar,
      side: BorderSide(
        color: selected ? AppTheme.primary : const Color(0xFFD5E0E6),
      ),
      backgroundColor: const Color(0xFFF2F6F9),
      selectedColor: AppTheme.primary,
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF2E434C),
          fontWeight: FontWeight.w700,
        ),
      ),
      onSelected: (_) => onTap(),
    );
  }

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

    final generation = await _engine.generateQuestionBatch(
      config: config,
      sections: widget.sections,
    );
    final questions = generation.questions;

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

    if (_useOnlineSource && !generation.usedOnlineSource) {
      _showMessage(
        'تعذر تحميل الأسئلة المتصلة حاليًا. تم استخدام الأسئلة المحلية بدلًا منها.',
      );
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
    _showMessage('تم حفظ النتيجة وتحديث التحليل.');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

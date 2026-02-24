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
    required this.onOpenAnalysis,
    super.key,
  });

  final List<TajweedSection> sections;
  final Future<void> Function(PracticeAttempt attempt) onAttemptSaved;
  final VoidCallback onOpenAnalysis;

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  final PracticeEngineService _engine = PracticeEngineService();

  PracticeType _practiceType = PracticeType.mcq;
  PracticeScope _scope = PracticeScope.all;
  int _questionCount = 40;
  int _durationMinutes = 3;
  SessionLengthMode _lengthMode = SessionLengthMode.questionCount;

  String? _selectedSectionId;
  String? _selectedRuleId;

  bool _isGenerating = false;

  int get _estimatedQuestionCount =>
      _lengthMode == SessionLengthMode.questionCount
      ? _questionCount
      : _durationMinutes * 8;

  @override
  Widget build(BuildContext context) {
    final section = _resolveSelectedSection();
    final availableRules = section?.rules ?? const <TajweedRule>[];
    final hasSelectedRule = availableRules.any(
      (rule) => rule.id == _selectedRuleId,
    );
    if (!hasSelectedRule && _scope == PracticeScope.rule) {
      _selectedRuleId = null;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      children: [
        FadeSlideIn(index: 0, child: _buildHero()),
        const SizedBox(height: 12),
        FadeSlideIn(
          index: 1,
          child: _panelCard(
            icon: Icons.tune_rounded,
            title: 'نوع التدريب',
            subtitle: 'أنماط متنوعة بمستوى أصعب وتفاصيل أدق.',
            child: _buildPracticeTypeSelector(),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlideIn(
          index: 2,
          child: _panelCard(
            icon: Icons.hourglass_bottom_rounded,
            title: 'طول الجلسة',
            subtitle: 'اختيار أنيق وواضح للعدد أو المدة.',
            child: _buildLengthMode(),
          ),
        ),
        const SizedBox(height: 12),
        FadeSlideIn(
          index: 3,
          child: _panelCard(
            icon: Icons.filter_alt_rounded,
            title: 'نطاق التدريب',
            subtitle: 'كل الأحكام أو قسم محدد أو حكم واحد.',
            child: _buildScope(availableRules),
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(index: 4, child: _buildStartButton()),
      ],
    );
  }

  TajweedSection? _resolveSelectedSection() {
    if (widget.sections.isEmpty) {
      return null;
    }
    if (_selectedSectionId == null) {
      return widget.sections.first;
    }
    return widget.sections.firstWhere(
      (item) => item.id == _selectedSectionId,
      orElse: () => widget.sections.first,
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF255E67), Color(0xFF3A8C7C)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تدريب شامل بمستوى أقوى',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'اختبر فهمك في الأحكام والحروف والأقسام مع أسئلة صعبة.',
            style: TextStyle(color: Color(0xFFEAF7F9), fontSize: 16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statChip('النوع: ${_practiceType.label}'),
              _statChip(
                _lengthMode == SessionLengthMode.questionCount
                    ? 'المطلوب: ${arabicInt(_questionCount)} سؤال'
                    : 'نمط مؤقت: الإجابات فقط',
              ),
              _statChip(
                _lengthMode == SessionLengthMode.duration
                    ? 'المدة: ${arabicInt(_durationMinutes)} دقائق'
                    : 'بنظام العدد',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: MonoNumbersText(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _panelCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF52707A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPracticeTypeSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final type in PracticeType.values)
              SizedBox(width: width, child: _practiceTypeCard(type)),
          ],
        );
      },
    );
  }

  Widget _practiceTypeCard(PracticeType type) {
    final selected = _practiceType == type;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _practiceType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected
                ? AppTheme.primary.withValues(alpha: 0.12)
                : const Color(0xFFF4F7F9),
            border: Border.all(
              color: selected ? AppTheme.primary : const Color(0xFFD8E4EA),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _iconForPracticeType(type),
                color: selected ? AppTheme.primary : const Color(0xFF55717B),
              ),
              const SizedBox(height: 8),
              Text(
                type.label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected ? AppTheme.primary : const Color(0xFF2E4650),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _typeSubtitle(type),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF5E7780),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLengthMode() {
    final isQuestionMode = _lengthMode == SessionLengthMode.questionCount;
    final minValue = isQuestionMode ? 5.0 : 1.0;
    final maxValue = isQuestionMode ? 50.0 : 6.0;
    final currentValue = isQuestionMode ? _questionCount : _durationMinutes;
    final safeCurrentValue = currentValue
        .clamp(minValue.toInt(), maxValue.toInt())
        .toInt();
    final sections = isQuestionMode
        ? const [5, 10, 15, 20, 30, 40, 50]
        : const [1, 2, 3, 4, 5, 6];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              _questionCount = _questionCount.clamp(5, 50).toInt();
              _durationMinutes = _durationMinutes.clamp(1, 6).toInt();
            });
          },
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8FCFD), Color(0xFFEEF7FA)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    isQuestionMode
                        ? Icons.format_list_numbered_rounded
                        : Icons.timer_rounded,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isQuestionMode
                          ? 'اسحب لتحديد عدد الأسئلة'
                          : 'اسحب لتحديد مدة المؤقت',
                      style: const TextStyle(
                        color: Color(0xFF31545E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: MonoNumbersText(
                      '${arabicInt(minValue.toInt())}-${arabicInt(maxValue.toInt())}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.98,
                            end: 1,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: MonoNumbersText(
                        arabicInt(safeCurrentValue),
                        key: ValueKey(safeCurrentValue),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 38,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      isQuestionMode ? 'سؤال' : 'دقيقة',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A6871),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 10,
                        activeTrackColor: AppTheme.primary,
                        inactiveTrackColor: const Color(0xFFDCE6EB),
                        thumbColor: Colors.white,
                        overlayColor: AppTheme.primary.withValues(alpha: 0.12),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 11,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 18,
                        ),
                        tickMarkShape: SliderTickMarkShape.noTickMark,
                      ),
                      child: Slider(
                        value: safeCurrentValue.toDouble(),
                        min: minValue,
                        max: maxValue,
                        divisions: (maxValue - minValue).toInt(),
                        onChanged: (value) {
                          setState(() {
                            if (isQuestionMode) {
                              _questionCount = value.round();
                            } else {
                              _durationMinutes = value.round();
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final section in sections)
                          ChoiceChip(
                            selected: section == safeCurrentValue,
                            showCheckmark: false,
                            label: MonoNumbersText(
                              arabicInt(section),
                              style: TextStyle(
                                color: section == safeCurrentValue
                                    ? Colors.white
                                    : const Color(0xFF325962),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            selectedColor: AppTheme.primary,
                            backgroundColor: const Color(0xFFF2F7FA),
                            side: BorderSide(
                              color: section == safeCurrentValue
                                  ? AppTheme.primary
                                  : AppTheme.primary.withValues(alpha: 0.12),
                            ),
                            onSelected: (_) {
                              setState(() {
                                if (isQuestionMode) {
                                  _questionCount = section;
                                } else {
                                  _durationMinutes = section;
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        MonoNumbersText(
          isQuestionMode
              ? 'من ${arabicInt(5)} إلى ${arabicInt(50)} سؤال'
              : 'من ${arabicInt(1)} إلى ${arabicInt(6)} دقائق',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF4D6770),
          ),
        ),
      ],
    );
  }

  Widget _buildScope(List<TajweedRule> availableRules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<PracticeScope>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(
              value: PracticeScope.all,
              label: Text('كل الأحكام'),
              icon: Icon(Icons.public_rounded),
            ),
            ButtonSegment(
              value: PracticeScope.section,
              label: Text('قسم محدد'),
              icon: Icon(Icons.view_list_rounded),
            ),
            ButtonSegment(
              value: PracticeScope.rule,
              label: Text('حكم محدد'),
              icon: Icon(Icons.my_library_books_rounded),
            ),
          ],
          selected: {_scope},
          onSelectionChanged: (values) {
            final scope = values.first;
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
        if (_scope != PracticeScope.all) ...[
          const SizedBox(height: 12),
          const Text('القسم', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey(
              'section_${_selectedSectionId ?? widget.sections.first.id}',
            ),
            initialValue: _selectedSectionId ?? widget.sections.first.id,
            items: [
              for (final section in widget.sections)
                DropdownMenuItem<String>(
                  value: section.id,
                  child: Text(section.title),
                ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedSectionId = value;
                _selectedRuleId = null;
              });
            },
          ),
        ],
        if (_scope == PracticeScope.rule) ...[
          const SizedBox(height: 12),
          const Text('الحكم', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (availableRules.isEmpty)
            const Text('لا توجد أحكام متاحة في هذا القسم.')
          else
            DropdownButtonFormField<String>(
              key: ValueKey(
                'rule_${_selectedSectionId ?? "all"}_${availableRules.length}_${_selectedRuleId ?? "none"}',
              ),
              initialValue: _selectedRuleId,
              hint: const Text('اختر حكمًا'),
              items: [
                for (final rule in availableRules)
                  DropdownMenuItem<String>(
                    value: rule.id,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 5, backgroundColor: rule.color),
                        const SizedBox(width: 8),
                        Text(rule.name, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRuleId = value;
                });
              },
            ),
        ],
      ],
    );
  }

  Widget _buildStartButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
          _isGenerating
              ? (_lengthMode == SessionLengthMode.duration
                    ? 'جاري تجهيز جلسة مؤقتة...'
                    : 'جاري تجهيز ${arabicInt(_estimatedQuestionCount)} سؤال...')
              : 'ابدأ التدريب الآن',
          style: const TextStyle(fontSize: 17),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(56),
        ),
      ),
    );
  }

  IconData _iconForPracticeType(PracticeType type) {
    switch (type) {
      case PracticeType.mcq:
        return Icons.quiz_rounded;
      case PracticeType.trueFalse:
        return Icons.check_circle_rounded;
      case PracticeType.letterMatch:
        return Icons.font_download_rounded;
      case PracticeType.sectionMatch:
        return Icons.account_tree_rounded;
      case PracticeType.definitionMatch:
        return Icons.menu_book_rounded;
    }
  }

  String _typeSubtitle(PracticeType type) {
    switch (type) {
      case PracticeType.mcq:
        return 'تعرف الحكم من المثال أو الإشارة.';
      case PracticeType.trueFalse:
        return 'تحقق من صحة العبارات الدقيقة.';
      case PracticeType.letterMatch:
        return 'اختر الحرف الصحيح وسط خيارات متقاربة.';
      case PracticeType.sectionMatch:
        return 'اربط الحكم أو المثال بالقسم الصحيح.';
      case PracticeType.definitionMatch:
        return 'استخرج الحكم من الوصف العلمي المباشر.';
    }
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
      questionCount: _estimatedQuestionCount,
      scope: _scope,
      sectionId: _selectedSectionId,
      ruleId: _selectedRuleId,
      useOnlineSource: false,
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
    widget.onOpenAnalysis();
    _showMessage('تم حفظ النتيجة وتحديث التحليل.');
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

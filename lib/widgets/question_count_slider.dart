import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';
import '../utils/theme_helper.dart';
import '../l10n/app_localizations.dart';

class QuestionCountSlider extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int> onChanged;
  final int minValue;
  final int maxValue;

  const QuestionCountSlider({
    super.key,
    required this.initialValue,
    required this.onChanged,
    this.minValue = QuestionCounts.minCount,
    this.maxValue = QuestionCounts.maxCount,
  });

  @override
  State<QuestionCountSlider> createState() => _QuestionCountSliderState();
}

class _QuestionCountSliderState extends State<QuestionCountSlider>
    with TickerProviderStateMixin {
  late double _currentValue;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.toDouble();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onSliderChanged(double value) {
    setState(() {
      _currentValue = value;
    });
    widget.onChanged(value.round());

    // Animation de pulsation
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        gradient: ThemeHelper.getBackgroundGradient(context),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: ThemeHelper.getShadowColor(context),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).numberOfQuestions,
                style: ThemeHelper.getHeadlineStyle(context),
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingMedium,
                        vertical: AppSizes.paddingSmall,
                      ),
                      decoration: BoxDecoration(
                        gradient: ThemeHelper.getPrimaryGradient(context),
                        borderRadius: BorderRadius.circular(
                          AppSizes.borderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeHelper.getPrimaryColor(
                              context,
                            ).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${_currentValue.round()}',
                        style: ThemeHelper.getHeadlineStyle(context).copyWith(
                          color: ThemeHelper.getOnPrimaryColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // Slider personnalisé avec dégradé
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbShape: const CustomSliderThumb(),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: ThemeHelper.getUnselectedAnswerColor(context),
              thumbColor: ThemeHelper.getOnPrimaryColor(context),
              overlayColor: ThemeHelper.getPrimaryColor(
                context,
              ).withValues(alpha: 0.2),
            ),
            child: Stack(
              children: [
                // Track avec dégradé
                Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: ThemeHelper.getPrimaryGradient(context),
                  ),
                ),
                // Slider transparent par-dessus
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    thumbShape: const CustomSliderThumb(),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                  ),
                  child: Slider(
                    value: _currentValue,
                    min: widget.minValue.toDouble(),
                    max: widget.maxValue.toDouble(),
                    divisions: widget.maxValue - widget.minValue,
                    onChanged: _onSliderChanged,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Indicateurs de valeurs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildValueIndicator(widget.minValue, 'Min'),
                _buildValueIndicator(widget.maxValue, 'Max'),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          // Suggestions rapides
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: AppSizes.paddingSmall,
                runSpacing: AppSizes.paddingSmall,
                alignment: WrapAlignment.center,
                children:
                    QuestionCounts.available.map((count) {
                      final bool isSelected = _currentValue.round() == count;
                      return GestureDetector(
                            onTap: () => _onSliderChanged(count.toDouble()),
                            child: AnimatedContainer(
                              duration: AppDurations.short,
                              constraints: BoxConstraints(
                                maxWidth: (constraints.maxWidth - 40) / 6,
                                minWidth: 35,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingSmall,
                                vertical: AppSizes.paddingSmall,
                              ),
                              decoration: BoxDecoration(
                                gradient:
                                    isSelected
                                        ? ThemeHelper.getPrimaryGradient(
                                          context,
                                        )
                                        : null,
                                color:
                                    isSelected
                                        ? null
                                        : ThemeHelper.getUnselectedAnswerColor(
                                          context,
                                        ),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.borderRadius,
                                ),
                                border:
                                    isSelected
                                        ? null
                                        : Border.all(
                                          color: ThemeHelper.getBorderColor(
                                            context,
                                          ),
                                        ),
                              ),
                              child: Text(
                                count.toString(),
                                style: ThemeHelper.getBodyStyle(
                                  context,
                                ).copyWith(
                                  color:
                                      isSelected
                                          ? ThemeHelper.getOnPrimaryColor(
                                            context,
                                          )
                                          : ThemeHelper.getOnSurfaceColor(
                                            context,
                                          ),
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .animate(target: isSelected ? 1 : 0)
                          .scale(duration: 200.ms, curve: Curves.elasticOut);
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValueIndicator(int value, String label) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: ThemeHelper.getBodyStyle(
            context,
          ).copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: ThemeHelper.getSecondaryTextStyle(context)),
      ],
    );
  }
}

// Thumb personnalisé pour le slider
class CustomSliderThumb extends SliderComponentShape {
  const CustomSliderThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(24, 24);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Utilisons les couleurs du thème depuis sliderTheme
    final Color primaryColor =
        sliderTheme.thumbColor ?? const Color(0xFF8B5CF6);
    final Color shadowColor = Colors.black.withValues(alpha: 0.3);

    // Ombre
    final Paint shadowPaint =
        Paint()
          ..color = shadowColor
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(center + const Offset(0, 2), 12, shadowPaint);

    // Cercle principal
    final Paint thumbPaint = Paint()..color = primaryColor;

    canvas.drawCircle(center, 12, thumbPaint);

    // Cercle intérieur blanc
    final Paint innerPaint = Paint()..color = Colors.white;

    canvas.drawCircle(center, 6, innerPaint);
  }
}

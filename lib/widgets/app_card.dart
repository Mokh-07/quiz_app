import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/constants.dart';
import '../utils/theme_helper.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool useGlassmorphism;
  final Gradient? gradient;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.onTap,
    this.borderRadius,
    this.useGlassmorphism = false,
    this.gradient,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.short,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? AppSizes.cardElevation,
      end: (widget.elevation ?? AppSizes.cardElevation) * 2,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child:
                  widget.useGlassmorphism
                      ? _buildGlassmorphismCard()
                      : _buildRegularCard(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlassmorphismCard() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 200,
      borderRadius:
          (widget.borderRadius ?? BorderRadius.circular(AppSizes.borderRadius))
              .topLeft
              .x,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 2,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.1),
          Colors.white.withValues(alpha: 0.05),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.2),
        ],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(AppSizes.borderRadius),
        child: Container(
          padding:
              widget.padding ?? const EdgeInsets.all(AppSizes.paddingMedium),
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildRegularCard() {
    return AnimatedContainer(
          duration: AppDurations.short,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color:
                widget.gradient == null
                    ? (widget.backgroundColor ??
                        ThemeHelper.getCardColor(context))
                    : null,
            borderRadius:
                widget.borderRadius ??
                BorderRadius.circular(AppSizes.borderRadius),
            boxShadow: [
              BoxShadow(
                color: ThemeHelper.getShadowColor(
                  context,
                ).withValues(alpha: _isHovered ? 0.25 : 0.15),
                blurRadius: _elevationAnimation.value * 2,
                offset: Offset(0, _elevationAnimation.value),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius:
                  widget.borderRadius ??
                  BorderRadius.circular(AppSizes.borderRadius),
              child: Container(
                padding:
                    widget.padding ??
                    const EdgeInsets.all(AppSizes.paddingMedium),
                child: widget.child,
              ),
            ),
          ),
        )
        .animate(target: _isHovered ? 1 : 0)
        .shimmer(duration: 1000.ms, color: Colors.white.withValues(alpha: 0.3));
  }
}

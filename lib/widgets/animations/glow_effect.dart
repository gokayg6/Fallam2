import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class GlowEffect extends StatefulWidget {
  final Widget child;
  final Color? glowColor;
  final double glowRadius;
  final double glowIntensity;
  final Duration animationDuration;
  final bool isActive;
  final GlowType type;
  final double? width;
  final double? height;

  const GlowEffect({
    super.key,
    required this.child,
    this.glowColor,
    this.glowRadius = 20.0,
    this.glowIntensity = 0.5,
    this.animationDuration = const Duration(seconds: 2),
    this.isActive = true,
    this.type = GlowType.pulse,
    this.width,
    this.height,
  });

  @override
  State<GlowEffect> createState() => _GlowEffectState();
}

enum GlowType {
  pulse,
  breathing,
  wave,
  flicker,
  rainbow,
  mystical,
}

class _GlowEffectState extends State<GlowEffect>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(GlowEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
      } else {
        _controller.stop();
      }
    }
  }

  void _startAnimation() {
    switch (widget.type) {
      case GlowType.pulse:
        _controller.repeat(reverse: true);
        break;
      case GlowType.breathing:
        _controller.repeat(reverse: true);
        break;
      case GlowType.wave:
        _controller.repeat();
        break;
      case GlowType.flicker:
        _controller.repeat();
        break;
      case GlowType.rainbow:
        _controller.repeat();
        break;
      case GlowType.mystical:
        _controller.repeat(reverse: true);
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return widget.child;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return _buildGlowEffect();
        },
      ),
    );
  }

  Widget _buildGlowEffect() {
    switch (widget.type) {
      case GlowType.pulse:
        return _buildPulseGlow();
      case GlowType.breathing:
        return _buildBreathingGlow();
      case GlowType.wave:
        return _buildWaveGlow();
      case GlowType.flicker:
        return _buildFlickerGlow();
      case GlowType.rainbow:
        return _buildRainbowGlow();
      case GlowType.mystical:
        return _buildMysticalGlow();
    }
  }

  Widget _buildPulseGlow() {
    final intensity = 0.3 + (_animation.value * 0.7);
    final radius = widget.glowRadius * (0.8 + _animation.value * 0.4);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (widget.glowColor ?? AppColors.primary)
                .withValues(alpha: intensity * widget.glowIntensity),
            blurRadius: radius,
            spreadRadius: 2,
          ),
        ],
      ),
      child: widget.child,
    );
  }

  Widget _buildBreathingGlow() {
    final intensity = 0.2 + (sin(_animation.value * 2 * 3.14159) + 1) / 2 * 0.6;
    final radius = widget.glowRadius * (0.5 + intensity * 0.5);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (widget.glowColor ?? AppColors.primary)
                .withValues(alpha: intensity * widget.glowIntensity),
            blurRadius: radius,
            spreadRadius: 1,
          ),
        ],
      ),
      child: widget.child,
    );
  }

  Widget _buildWaveGlow() {
    final waveValue = sin(_animation.value * 2 * 3.14159);
    final intensity = (waveValue + 1) / 2;
    final radius = widget.glowRadius * (0.6 + intensity * 0.4);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (widget.glowColor ?? AppColors.primary)
                .withValues(alpha: intensity * widget.glowIntensity),
            blurRadius: radius,
            spreadRadius: 2,
          ),
        ],
      ),
      child: widget.child,
    );
  }

  Widget _buildFlickerGlow() {
    final flickerValue = sin(_animation.value * 4 * 3.14159);
    final intensity = (flickerValue + 1) / 2;
    final radius = widget.glowRadius * (0.7 + intensity * 0.3);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (widget.glowColor ?? AppColors.primary)
                .withValues(alpha: intensity * widget.glowIntensity),
            blurRadius: radius,
            spreadRadius: 1,
          ),
        ],
      ),
      child: widget.child,
    );
  }

  Widget _buildRainbowGlow() {
    final hue = (_animation.value * 360) % 360;
    final color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    final intensity = 0.4 + sin(_animation.value * 2 * 3.14159) * 0.3;
    final radius = widget.glowRadius * (0.8 + intensity * 0.2);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: intensity * widget.glowIntensity),
            blurRadius: radius,
            spreadRadius: 2,
          ),
        ],
      ),
      child: widget.child,
    );
  }

  Widget _buildMysticalGlow() {
    final mysticalValue = sin(_animation.value * 3.14159);
    final intensity = 0.3 + mysticalValue * 0.4;
    final radius = widget.glowRadius * (0.6 + mysticalValue * 0.4);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (widget.glowColor ?? AppColors.primary)
                .withValues(alpha: intensity * widget.glowIntensity),
            blurRadius: radius,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: (widget.glowColor ?? AppColors.primary)
                .withValues(alpha: intensity * 0.3),
            blurRadius: radius * 1.5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: widget.child,
    );
  }
}

// Özel glow widget'ları
class PulseGlow extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;
  final bool isActive;

  const PulseGlow({
    super.key,
    required this.child,
    this.color,
    this.radius = 20.0,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlowEffect(
      child: child,
      glowColor: color,
      glowRadius: radius,
      type: GlowType.pulse,
      isActive: isActive,
    );
  }
}

class BreathingGlow extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;
  final bool isActive;

  const BreathingGlow({
    super.key,
    required this.child,
    this.color,
    this.radius = 20.0,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlowEffect(
      child: child,
      glowColor: color,
      glowRadius: radius,
      type: GlowType.breathing,
      isActive: isActive,
    );
  }
}

class MysticalGlow extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double radius;
  final bool isActive;

  const MysticalGlow({
    super.key,
    required this.child,
    this.color,
    this.radius = 25.0,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlowEffect(
      child: child,
      glowColor: color,
      glowRadius: radius,
      type: GlowType.mystical,
      isActive: isActive,
    );
  }
}

class RainbowGlow extends StatelessWidget {
  final Widget child;
  final double radius;
  final bool isActive;

  const RainbowGlow({
    super.key,
    required this.child,
    this.radius = 20.0,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlowEffect(
      child: child,
      glowRadius: radius,
      type: GlowType.rainbow,
      isActive: isActive,
    );
  }
}

// Glow Container - Basit glow efekti
class GlowContainer extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final double glowRadius;
  final double glowIntensity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const GlowContainer({
    super.key,
    required this.child,
    this.glowColor,
    this.glowRadius = 15.0,
    this.glowIntensity = 0.6,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? AppColors.primary)
                .withValues(alpha: glowIntensity),
            blurRadius: glowRadius,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
        child: child,
      ),
    );
  }
}

// Matematik fonksiyonları
double sin(double radians) => math.sin(radians);

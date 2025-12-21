import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animasyon yönetimi servisi
/// Tüm animasyonları merkezi olarak yönetir
class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  // Animation durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration verySlowDuration = Duration(milliseconds: 800);

  // Animation curves
  static const Curve fastCurve = Curves.easeInOut;
  static const Curve normalCurve = Curves.easeInOutCubic;
  static const Curve slowCurve = Curves.easeInOutQuart;
  static const Curve mysticalCurve = Curves.easeInOutSine;

  // Mystical animation curves
  static const Curve cosmicCurve = Curves.easeInOutCubic;
  static const Curve etherealCurve = Curves.easeInOutSine;
  static const Curve magicalCurve = Curves.easeInOutQuart;

  /// Create fade in animation
  static Animation<double> createFadeInAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = normalCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create fade out animation
  static Animation<double> createFadeOutAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = normalCurve,
  }) {
    return Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create slide in from top animation
  static Animation<Offset> createSlideInFromTopAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = normalCurve,
  }) {
    return Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create slide in from bottom animation
  static Animation<Offset> createSlideInFromBottomAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = normalCurve,
  }) {
    return Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create slide in from left animation
  static Animation<Offset> createSlideInFromLeftAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = normalCurve,
  }) {
    return Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create slide in from right animation
  static Animation<Offset> createSlideInFromRightAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = normalCurve,
  }) {
    return Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create scale animation
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Duration duration = normalDuration,
    Curve curve = normalCurve,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create rotation animation
  static Animation<double> createRotationAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 2 * math.pi,
    Duration duration = normalDuration,
    Curve curve = normalCurve,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create mystical pulse animation
  static Animation<double> createMysticalPulseAnimation(
    AnimationController controller, {
    Duration duration = slowDuration,
    Curve curve = mysticalCurve,
  }) {
    return Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create cosmic glow animation
  static Animation<double> createCosmicGlowAnimation(
    AnimationController controller, {
    Duration duration = verySlowDuration,
    Curve curve = cosmicCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create ethereal float animation
  static Animation<double> createEtherealFloatAnimation(
    AnimationController controller, {
    Duration duration = verySlowDuration,
    Curve curve = etherealCurve,
  }) {
    return Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create magical shimmer animation
  static Animation<double> createMagicalShimmerAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = magicalCurve,
  }) {
    return Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create card flip animation
  static Animation<double> createCardFlipAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = normalCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create particle float animation
  static Animation<double> createParticleFloatAnimation(
    AnimationController controller, {
    Duration duration = verySlowDuration,
    Curve curve = etherealCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create mystical wave animation
  static Animation<double> createMysticalWaveAnimation(
    AnimationController controller, {
    Duration duration = slowDuration,
    Curve curve = mysticalCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create energy pulse animation
  static Animation<double> createEnergyPulseAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = cosmicCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create cosmic rotation animation
  static Animation<double> createCosmicRotationAnimation(
    AnimationController controller, {
    Duration duration = verySlowDuration,
    Curve curve = cosmicCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create ethereal scale animation
  static Animation<double> createEtherealScaleAnimation(
    AnimationController controller, {
    Duration duration = slowDuration,
    Curve curve = etherealCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create magical opacity animation
  static Animation<double> createMagicalOpacityAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = magicalCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create mystical color animation
  static Animation<Color?> createMysticalColorAnimation(
    AnimationController controller,
    Color beginColor,
    Color endColor, {
    Duration duration = slowDuration,
    Curve curve = mysticalCurve,
  }) {
    return ColorTween(
      begin: beginColor,
      end: endColor,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create cosmic shimmer animation
  static Animation<double> createCosmicShimmerAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = cosmicCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create ethereal glow animation
  static Animation<double> createEtherealGlowAnimation(
    AnimationController controller, {
    Duration duration = verySlowDuration,
    Curve curve = etherealCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create magical particle animation
  static Animation<double> createMagicalParticleAnimation(
    AnimationController controller, {
    Duration duration = slowDuration,
    Curve curve = magicalCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create cosmic wave animation
  static Animation<double> createCosmicWaveAnimation(
    AnimationController controller, {
    Duration duration = verySlowDuration,
    Curve curve = cosmicCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create ethereal float animation with offset
  static Animation<Offset> createEtherealFloatOffsetAnimation(
    AnimationController controller, {
    Duration duration = verySlowDuration,
    Curve curve = etherealCurve,
  }) {
    return Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, -20.0),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create mystical rotation with scale animation
  static Animation<double> createMysticalRotationScaleAnimation(
    AnimationController controller, {
    Duration duration = slowDuration,
    Curve curve = mysticalCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create cosmic pulse animation
  static Animation<double> createCosmicPulseAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = cosmicCurve,
  }) {
    return Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create ethereal shimmer animation
  static Animation<double> createEtherealShimmerAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = etherealCurve,
  }) {
    return Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create magical glow animation
  static Animation<double> createMagicalGlowAnimation(
    AnimationController controller, {
    Duration duration = slowDuration,
    Curve curve = magicalCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create cosmic float animation
  static Animation<double> createCosmicFloatAnimation(
    AnimationController controller, {
    Duration duration = verySlowDuration,
    Curve curve = cosmicCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create ethereal pulse animation
  static Animation<double> createEtherealPulseAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = etherealCurve,
  }) {
    return Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create magical wave animation
  static Animation<double> createMagicalWaveAnimation(
    AnimationController controller, {
    Duration duration = slowDuration,
    Curve curve = magicalCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create cosmic shimmer animation
  static Animation<double> createCosmicShimmerWaveAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = cosmicCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create ethereal rotation animation
  static Animation<double> createEtherealRotationAnimation(
    AnimationController controller, {
    Duration duration = verySlowDuration,
    Curve curve = etherealCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create magical scale animation
  static Animation<double> createMagicalScaleAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = magicalCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create cosmic glow pulse animation
  static Animation<double> createCosmicGlowPulseAnimation(
    AnimationController controller, {
    Duration duration = slowDuration,
    Curve curve = cosmicCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create ethereal shimmer wave animation
  static Animation<double> createEtherealShimmerWaveAnimation(
    AnimationController controller, {
    Duration duration = normalDuration,
    Curve curve = etherealCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// Create magical rotation glow animation
  static Animation<double> createMagicalRotationGlowAnimation(
    AnimationController controller, {
    Duration duration = verySlowDuration,
    Curve curve = magicalCurve,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }
}

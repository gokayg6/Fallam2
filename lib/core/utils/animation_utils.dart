import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimationUtils {
  // Card flip animation
  static AnimationController createCardFlipController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
  }

  static Animation<double> createCardFlipAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  // Mystical particle animation
  static AnimationController createParticleController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(seconds: 3),
      vsync: vsync,
    );
  }

  static Animation<double> createFloatingAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  // Glow animation
  static AnimationController createGlowController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );
  }

  static Animation<double> createGlowAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  // Scale animation
  static AnimationController createScaleController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
  }

  static Animation<double> createScaleAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
  }

  // Fade animation
  static AnimationController createFadeController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: vsync,
    );
  }

  static Animation<double> createFadeAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    ));
  }

  // Slide animation
  static AnimationController createSlideController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
  }

  static Animation<Offset> createSlideAnimation(AnimationController controller) {
    return Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));
  }

  // Rotation animation
  static AnimationController createRotationController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    );
  }

  static Animation<double> createRotationAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
    ));
  }

  // Shimmer animation
  static AnimationController createShimmerController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );
  }

  static Animation<double> createShimmerAnimation(AnimationController controller) {
    return Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  // Bounce animation
  static AnimationController createBounceController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
  }

  static Animation<double> createBounceAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.bounceOut,
    ));
  }

  // Pulse animation
  static AnimationController createPulseController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );
  }

  static Animation<double> createPulseAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  // Stagger animation helper
  static List<Animation<double>> createStaggeredAnimations({
    required AnimationController controller,
    required int itemCount,
    double interval = 0.1,
  }) {
    final animations = <Animation<double>>[];
    
    for (int i = 0; i < itemCount; i++) {
      final start = i * interval;
      final end = start + interval;
      
      animations.add(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              start.clamp(0.0, 1.0),
              end.clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        ),
      );
    }
    
    return animations;
  }

  // Custom curve for mystical effects
  static const Curve mysticalCurve = Curves.easeInOutCubic;
  static const Curve cardFlipCurve = Curves.easeInOut;
  static const Curve magicalAppearCurve = Curves.elasticOut;
  
  // Animation durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration cardFlipDuration = Duration(milliseconds: 800);
  static const Duration mysticalDuration = Duration(milliseconds: 1200);
  
  // Helper method to create custom tween
  static Animation<T> createCustomTween<T>({
    required AnimationController controller,
    required T begin,
    required T end,
    Curve curve = Curves.linear,
  }) {
    return Tween<T>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  // Helper method to create interval animation
  static Animation<double> createIntervalAnimation({
    required AnimationController controller,
    required double start,
    required double end,
    Curve curve = Curves.linear,
  }) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: curve),
    ));
  }

  // Helper method to create color animation
  static Animation<Color?> createColorAnimation({
    required AnimationController controller,
    required Color begin,
    required Color end,
    Curve curve = Curves.linear,
  }) {
    return ColorTween(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  // Helper method to create size animation
  static Animation<Size?> createSizeAnimation({
    required AnimationController controller,
    required Size begin,
    required Size end,
    Curve curve = Curves.linear,
  }) {
    return SizeTween(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  // Helper method to dispose multiple controllers
  static void disposeControllers(List<AnimationController> controllers) {
    for (final controller in controllers) {
      controller.dispose();
    }
  }

  // Helper method to start multiple animations
  static void startAnimations(List<AnimationController> controllers) {
    for (final controller in controllers) {
      controller.forward();
    }
  }

  // Helper method to reset multiple animations
  static void resetAnimations(List<AnimationController> controllers) {
    for (final controller in controllers) {
      controller.reset();
    }
  }

  // Helper method to reverse multiple animations
  static void reverseAnimations(List<AnimationController> controllers) {
    for (final controller in controllers) {
      controller.reverse();
    }
  }
}
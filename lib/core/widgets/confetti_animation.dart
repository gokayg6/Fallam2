import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ConfettiAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const ConfettiAnimation({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<ConfettiAnimation> createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create confetti particles
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1 - _random.nextDouble() * 0.2,
        color: _getRandomColor(),
        size: 4 + _random.nextDouble() * 6,
        rotation: _random.nextDouble() * 2 * math.pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 4,
        fallSpeed: 0.3 + _random.nextDouble() * 0.5,
        horizontalSpeed: (_random.nextDouble() - 0.5) * 0.3,
      ));
    }

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  Color _getRandomColor() {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.karma,
      Colors.yellow,
      Colors.orange,
      Colors.pink,
      Colors.purple,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  double rotation;
  final double rotationSpeed;
  final double fallSpeed;
  final double horizontalSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.fallSpeed,
    required this.horizontalSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final opacity = (1 - progress).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      final x = particle.x * size.width;
      final y = particle.y * size.height + progress * size.height * particle.fallSpeed;
      final currentRotation = particle.rotation + progress * particle.rotationSpeed * 10;
      final currentX = x + progress * size.width * particle.horizontalSpeed;

      canvas.save();
      canvas.translate(currentX, y);
      canvas.rotate(currentRotation);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}


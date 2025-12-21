import 'dart:math';
import 'package:flutter/material.dart';

class SnowfallOverlay extends StatefulWidget {
  final Widget child;
  final int particleCount;

  const SnowfallOverlay({
    super.key,
    required this.child,
    this.particleCount = 50,
  });

  @override
  State<SnowfallOverlay> createState() => _SnowfallOverlayState();
}

class _SnowfallOverlayState extends State<SnowfallOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<SnowParticle> _particles = [];
  final Random _random = Random();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Long duration loop
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initParticles(Size size) {
    _particles.clear();
    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_generateParticle(size));
    }
    _initialized = true;
  }
  
  SnowParticle _generateParticle(Size size) {
     return SnowParticle(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        radius: _random.nextDouble() * 2 + 1.0,
        speed: _random.nextDouble() * 2 + 1.0,
        opacity: _random.nextDouble() * 0.6 + 0.2,
     );
  }

  void _updateParticles(Size size) {
    for (var particle in _particles) {
      particle.y += particle.speed;
      if (particle.y > size.height) {
        particle.y = -10;
        particle.x = _random.nextDouble() * size.width;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
          return widget.child;
        }

        if (!_initialized) {
          _initParticles(Size(constraints.maxWidth, constraints.maxHeight));
        }

        return Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    _updateParticles(Size(constraints.maxWidth, constraints.maxHeight));
                    return RepaintBoundary(
                      child: CustomPaint(
                        painter: SnowPainter(_particles),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SnowParticle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double opacity;

  SnowParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class SnowPainter extends CustomPainter {
  final List<SnowParticle> particles;

  SnowPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var particle in particles) {
      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(Offset(particle.x, particle.y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

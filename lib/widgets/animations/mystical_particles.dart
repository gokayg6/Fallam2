import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MysticalParticles extends StatefulWidget {
  final int particleCount;
  final Color? particleColor;
  final double particleSize;
  final Duration animationDuration;
  final bool isActive;
  final ParticleType type;

  const MysticalParticles({
    super.key,
    this.particleCount = 20,
    this.particleColor,
    this.particleSize = 3.0,
    this.animationDuration = const Duration(seconds: 3),
    this.isActive = true,
    this.type = ParticleType.floating,
  });

  @override
  State<MysticalParticles> createState() => _MysticalParticlesState();
}

enum ParticleType {
  floating,
  swirling,
  sparkle,
  aura,
  cosmic,
}

class _MysticalParticlesState extends State<MysticalParticles>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _initializeParticles();
    
    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(MysticalParticles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  void _initializeParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      return Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: widget.particleSize + _random.nextDouble() * 2,
        speed: 0.5 + _random.nextDouble() * 1.5,
        direction: _random.nextDouble() * 2 * math.pi,
        opacity: 0.3 + _random.nextDouble() * 0.7,
        color: widget.particleColor ?? AppColors.primary,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            animationValue: _controller.value,
            type: widget.type,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double direction;
  double opacity;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.direction,
    required this.opacity,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;
  final ParticleType type;

  _ParticlePainter({
    required this.particles,
    required this.animationValue,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      _updateParticle(particle, size);
      _drawParticle(canvas, particle);
    }
  }

  void _updateParticle(Particle particle, Size size) {
    switch (type) {
      case ParticleType.floating:
        _updateFloatingParticle(particle, size);
        break;
      case ParticleType.swirling:
        _updateSwirlingParticle(particle, size);
        break;
      case ParticleType.sparkle:
        _updateSparkleParticle(particle, size);
        break;
      case ParticleType.aura:
        _updateAuraParticle(particle, size);
        break;
      case ParticleType.cosmic:
        _updateCosmicParticle(particle, size);
        break;
    }
  }

  void _updateFloatingParticle(Particle particle, Size size) {
    particle.x += cos(particle.direction) * particle.speed * 0.01;
    particle.y += sin(particle.direction) * particle.speed * 0.01;

    // Wrap around screen
    if (particle.x < 0) particle.x = size.width;
    if (particle.x > size.width) particle.x = 0;
    if (particle.y < 0) particle.y = size.height;
    if (particle.y > size.height) particle.y = 0;
  }

  void _updateSwirlingParticle(Particle particle, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final angle = particle.direction + particle.speed * 0.02;
    final radius = 50 + sin(animationValue * 2 * math.pi) * 20;
    
    particle.x = centerX + cos(angle) * radius;
    particle.y = centerY + sin(angle) * radius;
    particle.direction = angle;
  }

  void _updateSparkleParticle(Particle particle, Size size) {
    particle.x += (math.Random().nextDouble() - 0.5) * particle.speed;
    particle.y += (math.Random().nextDouble() - 0.5) * particle.speed;
    
    // Fade in and out
    particle.opacity = (sin(animationValue * 2 * math.pi + particle.x * 0.01) + 1) / 2;
    
    // Wrap around
    if (particle.x < 0) particle.x = size.width;
    if (particle.x > size.width) particle.x = 0;
    if (particle.y < 0) particle.y = size.height;
    if (particle.y > size.height) particle.y = 0;
  }

  void _updateAuraParticle(Particle particle, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    final distance = sqrt(pow(particle.x - centerX, 2) + pow(particle.y - centerY, 2));
    final angle = atan2(particle.y - centerY, particle.x - centerX);
    
    particle.x = centerX + cos(angle + particle.speed * 0.01) * distance;
    particle.y = centerY + sin(angle + particle.speed * 0.01) * distance;
  }

  void _updateCosmicParticle(Particle particle, Size size) {
    particle.x += cos(particle.direction) * particle.speed * 0.005;
    particle.y += sin(particle.direction) * particle.speed * 0.005;
    
    // Add some randomness
    particle.direction += (math.Random().nextDouble() - 0.5) * 0.1;
    
    // Wrap around
    if (particle.x < 0) particle.x = size.width;
    if (particle.x > size.width) particle.x = 0;
    if (particle.y < 0) particle.y = size.height;
    if (particle.y > size.height) particle.y = 0;
  }

  void _drawParticle(Canvas canvas, Particle particle) {
    final paint = Paint()
      ..color = particle.color.withValues(alpha: particle.opacity)
      ..style = PaintingStyle.fill;

    switch (type) {
      case ParticleType.floating:
        canvas.drawCircle(
          Offset(particle.x, particle.y),
          particle.size,
          paint,
        );
        break;
      case ParticleType.swirling:
        canvas.drawCircle(
          Offset(particle.x, particle.y),
          particle.size,
          paint,
        );
        break;
      case ParticleType.sparkle:
        _drawSparkle(canvas, particle, paint);
        break;
      case ParticleType.aura:
        canvas.drawCircle(
          Offset(particle.x, particle.y),
          particle.size,
          paint,
        );
        break;
      case ParticleType.cosmic:
        _drawCosmicParticle(canvas, particle, paint);
        break;
    }
  }

  void _drawSparkle(Canvas canvas, Particle particle, Paint paint) {
    final center = Offset(particle.x, particle.y);
    
    // Draw star shape
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * math.pi / 5;
      final x = center.dx + cos(angle) * particle.size;
      final y = center.dy + sin(angle) * particle.size;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawCosmicParticle(Canvas canvas, Particle particle, Paint paint) {
    // Draw with glow effect
    final center = Offset(particle.x, particle.y);
    
    // Outer glow
    paint.color = particle.color.withValues(alpha: particle.opacity * 0.3);
    canvas.drawCircle(center, particle.size * 2, paint);
    
    // Inner core
    paint.color = particle.color.withValues(alpha: particle.opacity);
    canvas.drawCircle(center, particle.size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Özel particle widget'ları
class FloatingParticles extends StatelessWidget {
  final int count;
  final Color? color;
  final bool isActive;

  const FloatingParticles({
    super.key,
    this.count = 15,
    this.color,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return MysticalParticles(
      particleCount: count,
      particleColor: color,
      type: ParticleType.floating,
      isActive: isActive,
    );
  }
}

class SwirlingParticles extends StatelessWidget {
  final int count;
  final Color? color;
  final bool isActive;

  const SwirlingParticles({
    super.key,
    this.count = 12,
    this.color,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return MysticalParticles(
      particleCount: count,
      particleColor: color,
      type: ParticleType.swirling,
      isActive: isActive,
    );
  }
}

class SparkleParticles extends StatelessWidget {
  final int count;
  final Color? color;
  final bool isActive;

  const SparkleParticles({
    super.key,
    this.count = 8,
    this.color,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return MysticalParticles(
      particleCount: count,
      particleColor: color,
      type: ParticleType.sparkle,
      isActive: isActive,
    );
  }
}

class AuraParticles extends StatelessWidget {
  final int count;
  final Color? color;
  final bool isActive;

  const AuraParticles({
    super.key,
    this.count = 10,
    this.color,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return MysticalParticles(
      particleCount: count,
      particleColor: color,
      type: ParticleType.aura,
      isActive: isActive,
    );
  }
}

class CosmicParticles extends StatelessWidget {
  final int count;
  final Color? color;
  final bool isActive;

  const CosmicParticles({
    super.key,
    this.count = 6,
    this.color,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return MysticalParticles(
      particleCount: count,
      particleColor: color,
      type: ParticleType.cosmic,
      isActive: isActive,
    );
  }
}

// Matematik fonksiyonları
double cos(double radians) => math.cos(radians);
double sin(double radians) => math.sin(radians);
double sqrt(double value) => math.sqrt(value);
double pow(double base, double exponent) => math.pow(base, exponent.toInt()).toDouble();
double atan2(double y, double x) => math.atan2(y, x);

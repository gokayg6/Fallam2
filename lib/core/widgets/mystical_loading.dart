import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import '../utils/animation_utils.dart';
import 'cached_falla_logo.dart';

enum MysticalLoadingType {
  spinner,
  dots,
  pulse,
  wave,
  crystal,
  cards,
  stars,
}

class MysticalLoading extends StatefulWidget {
  final MysticalLoadingType type;
  final double size;
  final Color? color;
  final String? message;
  final bool showMessage;
  final Duration duration;
  final double strokeWidth;

  const MysticalLoading({
    Key? key,
    this.type = MysticalLoadingType.spinner,
    this.size = 50.0,
    this.color,
    this.message,
    this.showMessage = false,
    this.duration = const Duration(seconds: 2),
    this.strokeWidth = 3.0,
  }) : super(key: key);

  @override
  State<MysticalLoading> createState() => _MysticalLoadingState();
}

class _MysticalLoadingState extends State<MysticalLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<AnimationController> _multiControllers = [];
  List<Animation<double>> _multiAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    switch (widget.type) {
      case MysticalLoadingType.spinner:
        _animation = AnimationUtils.createRotationAnimation(_controller);
        break;
      case MysticalLoadingType.pulse:
        _animation = AnimationUtils.createPulseAnimation(_controller);
        break;
      case MysticalLoadingType.wave:
        _animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );
        break;
      case MysticalLoadingType.dots:
      case MysticalLoadingType.stars:
        _initializeMultiAnimations(3);
        break;
      case MysticalLoadingType.crystal:
        _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
          CurvedAnimation(parent: _controller, curve: Curves.linear),
        );
        break;
      case MysticalLoadingType.cards:
        _initializeMultiAnimations(5);
        break;
    }
  }

  void _initializeMultiAnimations(int count) {
    _multiControllers = List.generate(
      count,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _multiAnimations = _multiControllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  void _startAnimations() {
    switch (widget.type) {
      case MysticalLoadingType.spinner:
      case MysticalLoadingType.crystal:
        _controller.repeat();
        break;
      case MysticalLoadingType.pulse:
      case MysticalLoadingType.wave:
        _controller.repeat(reverse: true);
        break;
      case MysticalLoadingType.dots:
      case MysticalLoadingType.stars:
      case MysticalLoadingType.cards:
        _startStaggeredAnimations();
        break;
    }
  }

  void _startStaggeredAnimations() {
    for (int i = 0; i < _multiControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _multiControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: _buildLoadingWidget(),
        ),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: widget.color ?? AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingWidget() {
    switch (widget.type) {
      case MysticalLoadingType.spinner:
        return _buildSpinner();
      case MysticalLoadingType.dots:
        return _buildDots();
      case MysticalLoadingType.pulse:
        return _buildPulse();
      case MysticalLoadingType.wave:
        return _buildWave();
      case MysticalLoadingType.crystal:
        return _buildCrystal();
      case MysticalLoadingType.cards:
        return _buildCards();
      case MysticalLoadingType.stars:
        return _buildStars();
    }
  }

  Widget _buildSpinner() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: SpinnerPainter(
              color: widget.color ?? AppColors.primary,
              strokeWidth: widget.strokeWidth,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_multiAnimations.length, (index) {
        return AnimatedBuilder(
          animation: _multiAnimations[index],
          builder: (context, child) {
            return Transform.scale(
              scale: 0.5 + (_multiAnimations[index].value * 0.5),
              child: Container(
                width: widget.size / 5,
                height: widget.size / 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (widget.color ?? AppColors.primary)
                      .withValues(alpha: 0.3 + (_multiAnimations[index].value * 0.7)),
                  boxShadow: [
                    BoxShadow(
                      color: (widget.color ?? AppColors.primary)
                          .withValues(alpha: _multiAnimations[index].value * 0.5),
                      blurRadius: 10 * _multiAnimations[index].value,
                      spreadRadius: 2 * _multiAnimations[index].value,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPulse() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_animation.value * 0.4),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (widget.color ?? AppColors.primary)
                      .withValues(alpha: 0.8 * _animation.value),
                  (widget.color ?? AppColors.primary)
                      .withValues(alpha: 0.2 * _animation.value),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.color ?? AppColors.primary)
                      .withValues(alpha: _animation.value * 0.6),
                  blurRadius: 20 * _animation.value,
                  spreadRadius: 5 * _animation.value,
                ),
              ],
            ),
            child: CachedFallaLogo(
              size: widget.size * 0.4,
              color: Colors.white.withValues(alpha: _animation.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWave() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: WavePainter(
            color: widget.color ?? AppColors.primary,
            animationValue: _animation.value,
          ),
        );
      },
    );
  }

  Widget _buildCrystal() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: CrystalPainter(
              color: widget.color ?? AppColors.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCards() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(_multiAnimations.length, (index) {
        return AnimatedBuilder(
          animation: _multiAnimations[index],
          builder: (context, child) {
            final angle = (index * 2 * math.pi / _multiAnimations.length) +
                (_multiAnimations[index].value * 2 * math.pi);
            final radius = widget.size * 0.3;
            final x = radius * math.cos(angle);
            final y = radius * math.sin(angle);

            return Transform.translate(
              offset: Offset(x, y),
              child: Transform.rotate(
                angle: angle,
                child: Container(
                  width: widget.size * 0.2,
                  height: widget.size * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.color ?? AppColors.primary,
                        (widget.color ?? AppColors.primary).withValues(alpha: 0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.color ?? AppColors.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStars() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(_multiAnimations.length, (index) {
        return AnimatedBuilder(
          animation: _multiAnimations[index],
          builder: (context, child) {
            final scale = 0.5 + (_multiAnimations[index].value * 0.5);
            final opacity = 0.3 + (_multiAnimations[index].value * 0.7);
            final angle = index * 2 * math.pi / _multiAnimations.length;
            final radius = widget.size * 0.3 * _multiAnimations[index].value;
            final x = radius * math.cos(angle);
            final y = radius * math.sin(angle);

            return Transform.translate(
              offset: Offset(x, y),
              child: Transform.scale(
                scale: scale,
                child: Icon(
                  Icons.star,
                  size: widget.size * 0.15,
                  color: (widget.color ?? AppColors.primary)
                      .withValues(alpha: opacity),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_multiControllers.isNotEmpty) {
      for (final controller in _multiControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }
}

// Custom Painters
class SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  SpinnerPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw the arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 1.5,
      false,
      paint,
    );

    // Draw gradient effect
    final gradientPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.1),
          color,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 1.5,
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WavePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  WavePainter({
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = size.height * 0.1;
    final waveLength = size.width;
    final phase = animationValue * 2 * math.pi;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 +
          waveHeight * math.sin((x / waveLength * 2 * math.pi) + phase);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Draw second wave
    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 +
          waveHeight *
              0.7 *
              math.sin((x / waveLength * 2 * math.pi) + phase + math.pi / 2);
      path2.lineTo(x, y);
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CrystalPainter extends CustomPainter {
  final Color color;

  CrystalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw crystal shape (hexagon)
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Gradient effect
    paint.shader = RadialGradient(
      colors: [
        color,
        color.withValues(alpha: 0.3),
        Colors.transparent,
      ],
      stops: const [0.0, 0.7, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, paint);

    // Draw inner lines
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      canvas.drawLine(center, Offset(x, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Convenience constructors
class MysticalLoadingWidget {
  static Widget spinner({
    double size = 50.0,
    Color? color,
    String? message,
    bool showMessage = false,
  }) {
    return MysticalLoading(
      type: MysticalLoadingType.spinner,
      size: size,
      color: color,
      message: message,
      showMessage: showMessage,
    );
  }

  static Widget dots({
    double size = 50.0,
    Color? color,
    String? message,
    bool showMessage = false,
  }) {
    return MysticalLoading(
      type: MysticalLoadingType.dots,
      size: size,
      color: color,
      message: message,
      showMessage: showMessage,
    );
  }

  static Widget pulse({
    double size = 50.0,
    Color? color,
    String? message,
    bool showMessage = false,
  }) {
    return MysticalLoading(
      type: MysticalLoadingType.pulse,
      size: size,
      color: color,
      message: message,
      showMessage: showMessage,
    );
  }

  static Widget cards({
    double size = 50.0,
    Color? color,
    String? message,
    bool showMessage = false,
  }) {
    return MysticalLoading(
      type: MysticalLoadingType.cards,
      size: size,
      color: color,
      message: message,
      showMessage: showMessage,
    );
  }

  static Widget stars({
    double size = 50.0,
    Color? color,
    String? message,
    bool showMessage = false,
  }) {
    return MysticalLoading(
      type: MysticalLoadingType.stars,
      size: size,
      color: color,
      message: message,
      showMessage: showMessage,
    );
  }
}

class MysticLoading {
  static Completer<void>? _c;

  static void show(BuildContext context, {String? message}) {
    if (_c != null) return;
    _c = Completer<void>();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => _MysticLoadingDialog(message: message),
    ).then((_) {
      _c?.complete();
      _c = null;
    });
  }

  static Future<void> hide(BuildContext context) async {
    if (_c == null) return;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    await _c!.future;
  }
}

class _MysticLoadingDialog extends StatefulWidget {
  final String? message;
  const _MysticLoadingDialog({this.message});

  @override
  State<_MysticLoadingDialog> createState() => _MysticLoadingDialogState();
}

class _MysticLoadingDialogState extends State<_MysticLoadingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final Animation<double> _glow;
  Timer? _timer;
  int _chars = 0;

  static String get _default => AppStrings.isEnglish
      ? 'Mystical symbols appearing through the mist...\n\nPreparing your fortune.'
      : 'Misty sisler arasında semboller beliriyor...\n\nFal hazırlanıyor.';

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.2, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    final text = widget.message ?? _default;
    _timer = Timer.periodic(const Duration(milliseconds: 35), (t) {
      if (_chars >= text.length) return;
      setState(() => _chars++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.message ?? _default;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2144), Color(0xFF3E2E6F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _glow,
              child: CachedFallaLogo(
                size: 36,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                minHeight: 4,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.white24,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              text.substring(0, _chars),
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
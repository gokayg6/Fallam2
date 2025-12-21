import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CardFlipAnimation extends StatefulWidget {
  final Widget frontChild;
  final Widget backChild;
  final Duration duration;
  final bool isFlipped;
  final VoidCallback? onFlip;
  final double? width;
  final double? height;
  final bool autoFlip;
  final Duration autoFlipDelay;

  const CardFlipAnimation({
    super.key,
    required this.frontChild,
    required this.backChild,
    this.duration = const Duration(milliseconds: 600),
    this.isFlipped = false,
    this.onFlip,
    this.width,
    this.height,
    this.autoFlip = false,
    this.autoFlipDelay = const Duration(seconds: 3),
  });

  @override
  State<CardFlipAnimation> createState() => _CardFlipAnimationState();
}

class _CardFlipAnimationState extends State<CardFlipAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _isFlipped = widget.isFlipped;
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.autoFlip) {
      _startAutoFlip();
    }
  }

  @override
  void didUpdateWidget(CardFlipAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      _isFlipped = widget.isFlipped;
      if (_isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _startAutoFlip() {
    Future.delayed(widget.autoFlipDelay, () {
      if (mounted) {
        _flip();
        _startAutoFlip();
      }
    });
  }

  void _flip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });

    if (_isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    widget.onFlip?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final isShowingFront = _animation.value < 0.5;
            final rotation = _animation.value * 3.14159; // 180 derece

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspective
                ..rotateY(rotation),
              child: isShowingFront
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(0),
                      child: widget.frontChild,
                    )
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: widget.backChild,
                    ),
            );
          },
        ),
      ),
    );
  }
}

// Mystical Card Flip - Özel tema ile
class MysticalCardFlip extends StatefulWidget {
  final Widget frontChild;
  final Widget backChild;
  final bool isFlipped;
  final VoidCallback? onFlip;
  final double? width;
  final double? height;
  final bool showGlow;
  final Color? glowColor;

  const MysticalCardFlip({
    super.key,
    required this.frontChild,
    required this.backChild,
    this.isFlipped = false,
    this.onFlip,
    this.width,
    this.height,
    this.showGlow = true,
    this.glowColor,
  });

  @override
  State<MysticalCardFlip> createState() => _MysticalCardFlipState();
}

class _MysticalCardFlipState extends State<MysticalCardFlip>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _glowController;
  late Animation<double> _flipAnimation;
  late Animation<double> _glowAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _isFlipped = widget.isFlipped;

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.showGlow) {
      // Blinking animation disabled
      // _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(MysticalCardFlip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      _isFlipped = widget.isFlipped;
      if (_isFlipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  void _flip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });

    if (_isFlipped) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }

    widget.onFlip?.call();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: Container(
        width: widget.width,
        height: widget.height,
        child: Stack(
          children: [
            // Glow effect
            if (widget.showGlow)
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.glowColor ?? AppColors.primary)
                              .withValues(alpha: _glowAnimation.value * 0.3),
                          blurRadius: 20 * _glowAnimation.value,
                          spreadRadius: 5 * _glowAnimation.value,
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Card content
            AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) {
                final isShowingFront = _flipAnimation.value < 0.5;
                final rotation = _flipAnimation.value * 3.14159;

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(rotation),
                  child: isShowingFront
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(0),
                          child: widget.frontChild,
                        )
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(3.14159),
                          child: widget.backChild,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Tarot Card Flip - Özel tarot kartı animasyonu
class TarotCardFlip extends StatefulWidget {
  final Widget frontChild;
  final Widget backChild;
  final bool isFlipped;
  final VoidCallback? onFlip;
  final double? width;
  final double? height;

  const TarotCardFlip({
    super.key,
    required this.frontChild,
    required this.backChild,
    this.isFlipped = false,
    this.onFlip,
    this.width,
    this.height,
  });

  @override
  State<TarotCardFlip> createState() => _TarotCardFlipState();
}

class _TarotCardFlipState extends State<TarotCardFlip>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _isFlipped = widget.isFlipped;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(TarotCardFlip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      _isFlipped = widget.isFlipped;
      if (_isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _flip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });

    if (_isFlipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    widget.onFlip?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final isShowingFront = _animation.value < 0.5;
            final rotation = _animation.value * 3.14159;
            final scale = _scaleAnimation.value;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotation)
                ..scale(scale),
              child: isShowingFront
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(0),
                      child: widget.frontChild,
                    )
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: widget.backChild,
                    ),
            );
          },
        ),
      ),
    );
  }
}

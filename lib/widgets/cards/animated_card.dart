import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/animation_service.dart';

/// Animasyonlu kart bileşeni
/// Mistik animasyonlar ile kart gösterimi
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final double? elevation;
  final bool enableGlow;
  final bool enablePulse;
  final bool enableFloat;
  final bool enableShimmer;
  final bool enableRotation;
  final bool enableScale;
  final bool enableFade;
  final bool enableSlide;
  final String animationType;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final bool isPremium;
  final bool isMystical;
  final bool isInteractive;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation,
    this.enableGlow = true,
    this.enablePulse = false,
    this.enableFloat = false,
    this.enableShimmer = false,
    this.enableRotation = false,
    this.enableScale = false,
    this.enableFade = true,
    this.enableSlide = false,
    this.animationType = 'normal',
    this.animationDuration,
    this.animationCurve,
    this.isPremium = false,
    this.isMystical = true,
    this.isInteractive = true,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    final duration = widget.animationDuration ?? const Duration(milliseconds: 300);

    // Main controller
    _mainController = AnimationController(
      duration: duration,
      vsync: this,
    );

    // Glow controller
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Pulse controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Float controller
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Shimmer controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Rotation controller
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Scale controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Fade controller
    _fadeController = AnimationController(
      duration: duration,
      vsync: this,
    );

    // Slide controller
    _slideController = AnimationController(
      duration: duration,
      vsync: this,
    );

    // Initialize animations
    _glowAnimation = AnimationService.createCosmicGlowAnimation(_glowController);
    _pulseAnimation = AnimationService.createMysticalPulseAnimation(_pulseController);
    _floatAnimation = AnimationService.createEtherealFloatAnimation(_floatController);
    _shimmerAnimation = AnimationService.createMagicalShimmerAnimation(_shimmerController);
    _rotationAnimation = AnimationService.createCosmicRotationAnimation(_rotationController);
    // If scale is not enabled, keep scale at 1.0 so the card is visible
    _scaleAnimation = widget.enableScale
        ? AnimationService.createScaleAnimation(_scaleController)
        : const AlwaysStoppedAnimation<double>(1.0);
    _fadeAnimation = AnimationService.createFadeInAnimation(_fadeController);
    _slideAnimation = AnimationService.createSlideInFromBottomAnimation(_slideController);
  }

  void _startAnimations() {
    if (widget.enableFade) {
      _fadeController.forward();
    }
    if (widget.enableSlide) {
      _slideController.forward();
    }
    if (widget.enableGlow) {
      // Blinking animation disabled
      // _glowController.repeat(reverse: true);
    }
    if (widget.enablePulse) {
      // Blinking animation disabled
      // _pulseController.repeat(reverse: true);
    }
    if (widget.enableFloat) {
      _floatController.repeat(reverse: true); // Keep float animation
    }
    if (widget.enableShimmer) {
      // Blinking animation disabled
      // _shimmerController.repeat();
    }
    if (widget.enableRotation) {
      // Blinking animation disabled
      // _rotationController.repeat();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isInteractive) {
      setState(() {
        _isPressed = true;
      });
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.isInteractive) {
      setState(() {
        _isPressed = false;
      });
      _scaleController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.isInteractive) {
      setState(() {
        _isPressed = false;
      });
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _glowAnimation,
        _pulseAnimation,
        _floatAnimation,
        _shimmerAnimation,
        _rotationAnimation,
        _scaleAnimation,
        _fadeAnimation,
        _slideAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    margin: widget.margin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? 16,
                      ),
                      boxShadow: _buildBoxShadow(),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius ?? 16,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getBackgroundColor(),
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius ?? 16,
                          ),
                          border: _buildBorder(),
                          gradient: _buildGradient(),
                        ),
                        child: Stack(
                          children: [
                            // Shimmer effect
                            if (widget.enableShimmer)
                              _buildShimmerEffect(),
                            
                            // Main content
                            Padding(
                              padding: widget.padding ?? const EdgeInsets.all(16),
                              child: widget.child,
                            ),
                            
                            // Glow effect overlay
                            if (widget.enableGlow)
                              _buildGlowOverlay(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<BoxShadow> _buildBoxShadow() {
    final shadows = <BoxShadow>[];
    
    if (widget.elevation != null && widget.elevation! > 0) {
      shadows.add(BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: widget.elevation! * 2,
        offset: Offset(0, widget.elevation!),
      ));
    }

    if (widget.enableGlow) {
      final glowColor = widget.isPremium 
          ? AppColors.premium 
          : widget.isMystical 
              ? AppColors.primary 
              : AppColors.secondary;
      
      shadows.add(BoxShadow(
        color: glowColor.withValues(alpha: _glowAnimation.value * 0.3),
        blurRadius: 20 + (_glowAnimation.value * 10),
        spreadRadius: 2 + (_glowAnimation.value * 2),
      ));
    }

    if (_isPressed) {
      shadows.add(BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ));
    }

    return shadows;
  }

  Color _getBackgroundColor() {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }
    
    if (widget.isPremium) {
      return AppColors.premium.withValues(alpha: 0.1);
    }
    
    if (widget.isMystical) {
      return AppColors.surface;
    }
    
    return Colors.white;
  }

  Border? _buildBorder() {
    if (widget.borderColor != null) {
      return Border.all(
        color: widget.borderColor!,
        width: 1,
      );
    }
    
    if (widget.enableGlow) {
      final borderColor = widget.isPremium 
          ? AppColors.premium 
          : AppColors.secondary;
      
      return Border.all(
        color: borderColor.withValues(alpha: _glowAnimation.value * 0.5),
        width: 1 + (_glowAnimation.value * 0.5),
      );
    }
    
    return null;
  }

  Gradient? _buildGradient() {
    if (widget.isPremium) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.premium.withValues(alpha: 0.1),
          AppColors.premium.withValues(alpha: 0.05),
        ],
        stops: [0.0, 1.0],
      );
    }
    
    if (widget.isMystical && widget.enableGlow) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: _glowAnimation.value * 0.1),
          AppColors.secondary.withValues(alpha: _glowAnimation.value * 0.05),
        ],
        stops: [0.0, 1.0],
      );
    }
    
    return null;
  }

  Widget _buildShimmerEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _shimmerAnimation.value * 2, -1.0),
                end: Alignment(1.0 + _shimmerAnimation.value * 2, 1.0),
                colors: [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGlowOverlay() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8 + (_glowAnimation.value * 0.2),
                colors: [
                  (widget.isPremium ? AppColors.premium : AppColors.primary)
                      .withValues(alpha: _glowAnimation.value * 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// iOS 26 Premium Liquid Glass Widget Library
/// Premium transparent, blurry, and glassy components

// ==================== LIQUID GLASS COLORS ====================

class LiquidGlassColors {
  // Glass base colors
  static Color get glassWhite => Colors.white.withOpacity(0.10);
  static Color get glassBorder => Colors.white.withOpacity(0.15);
  static Color get glassHighlight => Colors.white.withOpacity(0.25);
  static Color get glassInnerGlow => Colors.white.withOpacity(0.08);
  
  // Premium glow colors - Soft purple/lavender palette
  static const Color glassGlow = Color(0xFFB8A4E0);
  static const Color shimmerColor = Color(0xFFD4C4F0);
  static const Color activeGlow = Color(0xFFA78BFA);
  
  // Active/selected state colors
  static const Color liquidGlassActive = Color(0xFFB8A4E0);
  static const Color liquidGlassSecondary = Color(0xFF9B8ED0);
  static const Color liquidGlassTertiary = Color(0xFF8B7BC0);
  
  // Gradient for active state
  static LinearGradient get activeGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      liquidGlassActive.withOpacity(0.6),
      liquidGlassSecondary.withOpacity(0.4),
      liquidGlassTertiary.withOpacity(0.3),
    ],
  );
  
  // Glass gradient
  static LinearGradient get glassGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withOpacity(0.15),
      Colors.white.withOpacity(0.05),
      Colors.white.withOpacity(0.02),
    ],
  );
  
  // Premium shimmer gradient
  static LinearGradient shimmerGradient(double shimmerPosition) => LinearGradient(
    begin: Alignment(-1.0 + shimmerPosition * 2, 0),
    end: Alignment(1.0 + shimmerPosition * 2, 0),
    colors: [
      Colors.transparent,
      Colors.white.withOpacity(0.15),
      Colors.transparent,
    ],
  );
}

// ==================== LIQUID GLASS SCREEN WRAPPER ====================

/// Wraps a screen with zoom/blur entrance animation
class LiquidGlassScreenWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool enableBlurAnimation;
  final bool enableZoomAnimation;

  const LiquidGlassScreenWrapper({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.enableBlurAnimation = true,
    this.enableZoomAnimation = true,
  }) : super(key: key);

  @override
  State<LiquidGlassScreenWrapper> createState() => _LiquidGlassScreenWrapperState();
}

class _LiquidGlassScreenWrapperState extends State<LiquidGlassScreenWrapper>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _opacityAnimation;
  bool _hasAnimated = false;

  @override
  bool get wantKeepAlive => true; // Keep state alive in PageView

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.enableZoomAnimation ? 0.85 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    ));

    _blurAnimation = Tween<double>(
      begin: widget.enableBlurAnimation ? 15.0 : 0.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Only animate once
    if (!_hasAnimated) {
      _controller.forward();
      _hasAnimated = true;
    } else {
      // Skip animation if already played
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // If animation completed, skip expensive filters
    if (_controller.isCompleted) {
      return widget.child;
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value.clamp(0.0, 1.0),
            child: _blurAnimation.value > 0.5
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
                    ),
                    child: widget.child,
                  )
                : widget.child,
          ),
        );
      },
    );
  }
}


// ==================== LIQUID GLASS CARD ====================

/// Premium glass card with blur, shimmer, and glow effects
class LiquidGlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool enableShimmer;
  final Color? glowColor;
  final double blurAmount;
  final int animationDelayMs;

  const LiquidGlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
    this.isSelected = false,
    this.enableShimmer = true,
    this.glowColor,
    this.blurAmount = 25,
    this.animationDelayMs = 0,
  }) : super(key: key);

  @override
  State<LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<LiquidGlassCard>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _entranceController;
  late AnimationController _pressController;
  late AnimationController _glowController; // NEW: Glow fade-in controller
  late Animation<double> _shimmerAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pressAnimation;
  late Animation<double> _glowAnimation; // NEW: Glow fade-in animation
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    if (widget.enableShimmer) {
      Future.delayed(Duration(milliseconds: widget.animationDelayMs + 1500), () {
        if (mounted) {
          _shimmerController.repeat();
        }
      });
    }

    // Entrance animation
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );
    Future.delayed(Duration(milliseconds: widget.animationDelayMs), () {
      if (mounted) _entranceController.forward();
    });

    // Press animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );

    // NEW: Glow fade-in animation - smooth fade-in for glow effect
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOutCubic),
    );
    // Start glow animation with delay after entrance
    Future.delayed(Duration(milliseconds: widget.animationDelayMs + 300), () {
      if (mounted) _glowController.forward();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _entranceController.dispose();
    _pressController.dispose();
    _glowController.dispose(); // NEW: Dispose glow controller
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? LiquidGlassColors.glassGlow;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _pressController, _glowController]),
      builder: (context, child) {
        final glowOpacity = _glowAnimation.value; // NEW: Use glow animation value
        
        return Transform.scale(
          scale: _scaleAnimation.value * _pressAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onTap != null ? _handleTapDown : null,
            onTapUp: widget.onTap != null ? _handleTapUp : null,
            onTapCancel: widget.onTap != null ? _handleTapCancel : null,
            child: Container(
              margin: widget.margin,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: widget.blurAmount,
                    sigmaY: widget.blurAmount,
                  ),
                  child: AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: widget.padding,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: widget.isSelected
                                ? [
                                    glowColor.withOpacity(0.25 * glowOpacity),
                                    glowColor.withOpacity(0.15 * glowOpacity),
                                    glowColor.withOpacity(0.08 * glowOpacity),
                                  ]
                                : [
                                    Colors.white.withOpacity(0.12),
                                    Colors.white.withOpacity(0.06),
                                    Colors.white.withOpacity(0.03),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(widget.borderRadius),
                          border: Border.all(
                            color: widget.isSelected
                                ? glowColor.withOpacity(0.5 * glowOpacity)
                                : Colors.white.withOpacity(0.15),
                            width: widget.isSelected ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.isSelected
                                  ? glowColor.withOpacity(0.3 * glowOpacity)
                                  : Colors.black.withOpacity(0.2 * glowOpacity),
                              blurRadius: widget.isSelected ? 25 : 20,
                              spreadRadius: widget.isSelected ? 2 : 0,
                              offset: const Offset(0, 8),
                            ),
                            if (widget.isSelected && glowOpacity > 0.1)
                              BoxShadow(
                                color: glowColor.withOpacity(0.15 * glowOpacity),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            widget.child,
                            // Shimmer overlay
                            if (widget.enableShimmer)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LiquidGlassColors.shimmerGradient(
                                        _shimmerAnimation.value,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        widget.borderRadius - 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== LIQUID GLASS CHIP ====================

/// Premium glass filter chip
class LiquidGlassChip extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const LiquidGlassChip({
    Key? key,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  }) : super(key: key);

  @override
  State<LiquidGlassChip> createState() => _LiquidGlassChipState();
}

class _LiquidGlassChipState extends State<LiquidGlassChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor ?? LiquidGlassColors.liquidGlassActive;
    
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: widget.isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                selectedColor.withOpacity(0.5),
                                selectedColor.withOpacity(0.3),
                              ],
                            )
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.12),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.isSelected
                            ? selectedColor.withOpacity(0.6)
                            : Colors.white.withOpacity(0.15),
                        width: widget.isSelected ? 1.5 : 1,
                      ),
                      boxShadow: widget.isSelected
                          ? [
                              BoxShadow(
                                color: selectedColor.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 16,
                            color: widget.isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          widget.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: widget.isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.8),
                            fontWeight: widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== LIQUID GLASS BUTTON ====================

/// Premium glass button with glow effect
class LiquidGlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double height;
  final double? width;
  final Color? color;
  final bool isPrimary;

  const LiquidGlassButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.height = 52,
    this.width,
    this.color,
    this.isPrimary = true,
  }) : super(key: key);

  @override
  State<LiquidGlassButton> createState() => _LiquidGlassButtonState();
}

class _LiquidGlassButtonState extends State<LiquidGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? LiquidGlassColors.liquidGlassActive;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.height / 2),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: widget.height,
                  width: widget.width,
                  decoration: BoxDecoration(
                    gradient: widget.isPrimary
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              buttonColor.withOpacity(0.7),
                              buttonColor.withOpacity(0.5),
                              buttonColor.withOpacity(0.4),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.08),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    border: Border.all(
                      color: widget.isPrimary
                          ? buttonColor.withOpacity(0.6)
                          : Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isPrimary
                            ? buttonColor.withOpacity(0.4)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      if (widget.isPrimary)
                        BoxShadow(
                          color: buttonColor.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 3,
                        ),
                    ],
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(
                                  widget.icon,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(
                                widget.text,
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==================== LIQUID GLASS STAT ITEM ====================

/// Premium glass stat item for profile/stats display
class LiquidGlassStatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const LiquidGlassStatItem({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: iconColor ?? LiquidGlassColors.liquidGlassActive,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppTextStyles.headingSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== LIQUID GLASS HEADER ====================

/// Premium animated header with liquid glass styling
class LiquidGlassHeader extends StatefulWidget {
  final String title;
  final Widget? trailing;
  final int animationDelayMs;

  const LiquidGlassHeader({
    Key? key,
    required this.title,
    this.trailing,
    this.animationDelayMs = 0,
  }) : super(key: key);

  @override
  State<LiquidGlassHeader> createState() => _LiquidGlassHeaderState();
}

class _LiquidGlassHeaderState extends State<LiquidGlassHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.animationDelayMs), () {
      if (mounted) _controller.forward();
    });
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
        return Opacity(
          opacity: _fadeAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.white,
                        LiquidGlassColors.shimmerColor,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      widget.title,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const Spacer(),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== LIQUID GLASS SETTING ITEM ====================

/// Premium glass setting item
class LiquidGlassSettingItem extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  const LiquidGlassSettingItem({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  State<LiquidGlassSettingItem> createState() => _LiquidGlassSettingItemState();
}

class _LiquidGlassSettingItemState extends State<LiquidGlassSettingItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(_isPressed ? 0.15 : 0.10),
                    Colors.white.withOpacity(_isPressed ? 0.08 : 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LiquidGlassColors.liquidGlassActive.withOpacity(0.3),
                          LiquidGlassColors.liquidGlassSecondary.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  widget.trailing ??
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.5),
                        size: 20,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== LIQUID GLASS SECTION ====================

/// Premium glass section container
class LiquidGlassSection extends StatelessWidget {
  final String? title;
  final Widget child;
  final double blurAmount;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const LiquidGlassSection({
    Key? key,
    this.title,
    required this.child,
    this.blurAmount = 20,
    this.padding = const EdgeInsets.all(20),
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LiquidGlassColors.glassGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

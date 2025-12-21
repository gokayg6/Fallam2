import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/animation_utils.dart';

class MysticalCard extends StatefulWidget {
  final String? imageUrl;               // büyük görsel istersen
  final String? iconAsset;              // küçük PNG ikon (kahve, tarot…)
  final double iconSize;                // PNG ikon boyutu
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;

  final bool isSelected;
  final bool isFlipped;
  final bool showGlow;

  // Compat: AspectRatio kullanınca width/height yok sayılır
  final double width;
  final double height;

  final Widget? backWidget;
  final Widget? frontWidget;
  final bool autoFlip;
  final Duration flipDuration;
  final bool enableHover;
  final Color? glowColor;
  final double glowIntensity;
  final bool showShimmer;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Widget? child;

  /// Grid ile tutarlılık için sabit oran
  final double aspectRatio;

  /// Karta tıklayınca flip toggle olsun mu?
  final bool toggleFlipOnTap;
  final bool enforceAspectRatio;

  const MysticalCard({
    super.key,
    this.imageUrl,
    this.iconAsset,
    this.iconSize = 28,
    this.title,
    this.subtitle,
    this.onTap,
    this.isSelected = false,
    this.isFlipped = false,
    this.showGlow = false,
    this.width = 120,
    this.height = 180,
    this.backWidget,
    this.frontWidget,
    this.autoFlip = false,
    this.flipDuration = const Duration(milliseconds: 800),
    this.enableHover = true,
    this.glowColor,
    this.glowIntensity = 1.0,
    this.showShimmer = false,
    this.padding,
    this.borderRadius,
    this.child,
    this.aspectRatio = 3 / 4,
    this.toggleFlipOnTap = true,
    this.enforceAspectRatio = true,
  });

  @override
  State<MysticalCard> createState() => _MysticalCardState();
}

class _MysticalCardState extends State<MysticalCard> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _glowController;
  late AnimationController _scaleController;
  late AnimationController _shimmerController;

  late Animation<double> _flipAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  bool _isHovered = false;
  bool _flipped = false; // LateInitializationError fix: default değeri var

  @override
  void initState() {
    super.initState();
    _flipped = widget.isFlipped; // önce state al
    _initializeAnimations();     // sonra controller/animasyonları kur

    if (_flipped) _flipController.value = 1.0;
    if (widget.autoFlip) _startAutoFlip();
    // Glow and shimmer animations disabled to prevent blinking
    // if (widget.showGlow) _glowController.repeat(reverse: true);
    // if (widget.showShimmer) _shimmerController.repeat();
  }

  void _initializeAnimations() {
    _flipController = AnimationUtils.createCardFlipController(this);
    _glowController = AnimationUtils.createGlowController(this);
    _scaleController = AnimationUtils.createScaleController(this);
    _shimmerController = AnimationUtils.createShimmerController(this);

    _flipAnimation = AnimationUtils.createCardFlipAnimation(_flipController);
    _glowAnimation = AnimationUtils.createGlowAnimation(_glowController);
    _scaleAnimation = AnimationUtils.createScaleAnimation(_scaleController);
    _shimmerAnimation = AnimationUtils.createShimmerAnimation(_shimmerController);
  }

  void _startAutoFlip() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _flipped = true;
      _flipController.forward();
    });
  }

  @override
  void didUpdateWidget(MysticalCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFlipped != oldWidget.isFlipped) {
      _flipped = widget.isFlipped;
      _flipped ? _flipController.forward() : _flipController.reverse();
    }
    // Glow and shimmer animations disabled to prevent blinking
    // if (widget.showGlow != oldWidget.showGlow) {
    //   widget.showGlow ? _glowController.repeat(reverse: true) : _glowController.stop();
    // }
    // if (widget.showShimmer != oldWidget.showShimmer) {
    //   widget.showShimmer ? _shimmerController.repeat() : _shimmerController.stop();
    // }
  }

  // Bas-bırak animasyonu ve aksiyon sıralı çalışsın
  Future<void> _handleTap() async {
    await _scaleController.forward(from: 0);
    await _scaleController.reverse();

    if (widget.toggleFlipOnTap) {
      _flipped = !_flipped;
      _flipped ? _flipController.forward() : _flipController.reverse();
    }

    widget.onTap?.call();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableHover) return;
    setState(() => _isHovered = isHovered);
    isHovered ? _scaleController.forward() : _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleTap, // onTapDown/Up yok -> takılma biter
        child: AnimatedBuilder(
          animation: Listenable.merge([_flipAnimation, _glowAnimation, _scaleAnimation, _shimmerAnimation]),
          builder: (context, _) {
            final card = Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                boxShadow: _buildShadows(),
              ),
              child: _buildCardContent(),
            );
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.enforceAspectRatio
                  ? AspectRatio(
                      aspectRatio: widget.aspectRatio,
                      child: card,
                    )
                  : card,
            );
          },
        ),
      ),
    );
  }

  List<BoxShadow> _buildShadows() {
    final shadows = <BoxShadow>[
      BoxShadow(
        color: AppColors.shadowColor.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];

    if (widget.showGlow || widget.isSelected) {
      final glowColor = widget.glowColor ?? AppColors.cardGlow;
      final intensity = widget.glowIntensity * _glowAnimation.value;
      shadows.add(
        BoxShadow(
          color: glowColor.withValues(alpha: 0.6 * intensity),
          blurRadius: 20 * intensity,
          spreadRadius: 2 * intensity,
        ),
      );
    }

    if (_isHovered) {
      shadows.add(
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      );
    }
    return shadows;
  }

  Widget _buildCardContent() {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      child: Stack(
        children: [
          // flip
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * math.pi),
            child: _flipAnimation.value <= 0.5
                ? _buildFrontSide()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBackSide(),
                  ),
          ),
          if (widget.showShimmer) _buildShimmerEffect(),
          if (widget.isSelected) _buildSelectionIndicator(),
        ],
      ),
    );
  }

  Widget _buildFrontSide() {
    if (widget.frontWidget != null) return widget.frontWidget!;
    if (widget.child != null) return widget.child!;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      ),
      padding: widget.padding ?? const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.iconAsset != null) ...[
            Image.asset(
              widget.iconAsset!,
              height: widget.iconSize,
              width: widget.iconSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
          ],
          if (widget.imageUrl != null) ...[
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(widget.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.title != null)
            Text(
              widget.title!,
              style: AppTextStyles.cardTitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              widget.subtitle!,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBackSide() {
    if (widget.backWidget != null) return widget.backWidget!;
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.mysticalGradient,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(Icons.auto_awesome, size: 48, color: AppColors.accent),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [
              _shimmerAnimation.value - 0.3,
              _shimmerAnimation.value,
              _shimmerAnimation.value + 0.3,
            ],
            colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      ),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }
}

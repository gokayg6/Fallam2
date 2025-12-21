import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../utils/animation_utils.dart';
import 'mystical_loading.dart';

enum MysticalButtonType {
  primary,
  secondary,
  accent,
  premium,
  ghost,
}

enum MysticalButtonSize {
  small,
  medium,
  large,
}

class MysticalButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final MysticalButtonType type;
  final MysticalButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final bool showGlow;
  final bool showPulse;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Gradient? customGradient;
  final Color? customColor;
  final TextStyle? customTextStyle;

  const MysticalButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = MysticalButtonType.primary,
    this.size = MysticalButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.showGlow = false,
    this.showPulse = false,
    this.width,
    this.padding,
    this.borderRadius,
    this.customGradient,
    this.customColor,
    this.customTextStyle,
  }) : super(key: key);

  @override
  State<MysticalButton> createState() => _MysticalButtonState();

  // Static convenience constructors
  static Widget primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isEnabled = true,
    bool showGlow = false,
    MysticalButtonSize size = MysticalButtonSize.medium,
    double? width,
  }) {
    return MysticalButton(
      key: key,
      text: text,
      onPressed: onPressed,
      type: MysticalButtonType.primary,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      showGlow: showGlow,
      size: size,
      width: width,
    );
  }

  static Widget secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isEnabled = true,
    bool showGlow = false,
    MysticalButtonSize size = MysticalButtonSize.medium,
    double? width,
  }) {
    return MysticalButton(
      key: key,
      text: text,
      onPressed: onPressed,
      type: MysticalButtonType.secondary,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      showGlow: showGlow,
      size: size,
      width: width,
    );
  }

  static Widget accent({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isEnabled = true,
    bool showGlow = false,
    MysticalButtonSize size = MysticalButtonSize.medium,
    double? width,
  }) {
    return MysticalButton(
      key: key,
      text: text,
      onPressed: onPressed,
      type: MysticalButtonType.accent,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      showGlow: showGlow,
      size: size,
      width: width,
    );
  }

  static Widget ghost({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isEnabled = true,
    bool showGlow = false,
    MysticalButtonSize size = MysticalButtonSize.medium,
    double? width,
  }) {
    return MysticalButton(
      key: key,
      text: text,
      onPressed: onPressed,
      type: MysticalButtonType.ghost,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      showGlow: showGlow,
      size: size,
      width: width,
    );
  }

  static Widget premium({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isEnabled = true,
    bool showGlow = true,
    bool showPulse = true,
    MysticalButtonSize size = MysticalButtonSize.medium,
    double? width,
  }) {
    return MysticalButton(
      key: key,
      text: text,
      onPressed: onPressed,
      type: MysticalButtonType.premium,
      icon: icon,
      isLoading: isLoading,
      isEnabled: isEnabled,
      showGlow: showGlow,
      showPulse: showPulse,
      size: size,
      width: width,
    );
  }
}

class _MysticalButtonState extends State<MysticalButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _loadingController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _loadingAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.showGlow) {
      // Glow animation disabled to prevent blinking
      // _glowController.repeat(reverse: true);
    }
    
    if (widget.showPulse) {
      // Pulse animation disabled to prevent blinking
      // _pulseController.repeat(reverse: true);
    }
    
    if (widget.isLoading) {
      _loadingController.repeat();
    }
  }

  void _initializeAnimations() {
    _scaleController = AnimationUtils.createScaleController(this);
    _glowController = AnimationUtils.createGlowController(this);
    _pulseController = AnimationUtils.createPulseController(this);
    _loadingController = AnimationUtils.createRotationController(this);
    
    _scaleAnimation = AnimationUtils.createScaleAnimation(_scaleController);
    _glowAnimation = AnimationUtils.createGlowAnimation(_glowController);
    _pulseAnimation = AnimationUtils.createPulseAnimation(_pulseController);
    _loadingAnimation = AnimationUtils.createRotationAnimation(_loadingController);
  }

  @override
  void didUpdateWidget(MysticalButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.showGlow != oldWidget.showGlow) {
      if (widget.showGlow) {
        // Glow animation disabled to prevent blinking
      // _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
      }
    }
    
    if (widget.showPulse != oldWidget.showPulse) {
      if (widget.showPulse) {
        // Pulse animation disabled to prevent blinking
      // _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
    
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _loadingController.repeat();
      } else {
        _loadingController.stop();
      }
    }
  }

  void _handleTap() {
    if (widget.onPressed != null && widget.isEnabled && !widget.isLoading) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
      
      widget.onPressed!();
    }
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: _handleTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _glowAnimation,
            _pulseAnimation,
            _loadingAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: widget.showPulse 
                  ? _pulseAnimation.value 
                  : _scaleAnimation.value,
              child: Container(
                width: widget.width,
                padding: widget.padding ?? _getDefaultPadding(),
                decoration: BoxDecoration(
                  gradient: _getGradient(),
                  borderRadius: widget.borderRadius ?? _getDefaultBorderRadius(),
                  border: _getBorder(),
                  boxShadow: _getBoxShadows(),
                ),
                child: _buildButtonContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  EdgeInsetsGeometry _getDefaultPadding() {
    switch (widget.size) {
      case MysticalButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case MysticalButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case MysticalButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  BorderRadius _getDefaultBorderRadius() {
    switch (widget.size) {
      case MysticalButtonSize.small:
        return BorderRadius.circular(8);
      case MysticalButtonSize.medium:
        return BorderRadius.circular(12);
      case MysticalButtonSize.large:
        return BorderRadius.circular(16);
    }
  }

  Gradient? _getGradient() {
    if (widget.customGradient != null) {
      return widget.customGradient;
    }
    
    if (!widget.isEnabled) {
      return LinearGradient(
        colors: [AppColors.textSecondary, AppColors.textSecondary],
      );
    }
    
    switch (widget.type) {
      case MysticalButtonType.primary:
        return AppColors.primaryGradient;
      case MysticalButtonType.secondary:
        return AppColors.secondaryGradient;
      case MysticalButtonType.accent:
        return AppColors.accentGradient;
      case MysticalButtonType.premium:
        return AppColors.premiumGradient;
      case MysticalButtonType.ghost:
        return null;
    }
  }

  Border? _getBorder() {
    if (widget.type == MysticalButtonType.ghost) {
      return Border.all(
        color: widget.isEnabled ? AppColors.primary : AppColors.textSecondary,
        width: 1.5,
      );
    }
    return null;
  }

  List<BoxShadow> _getBoxShadows() {
    final shadows = <BoxShadow>[];
    
    if (!widget.isEnabled) {
      return shadows;
    }
    
    // Base shadow
    shadows.add(
      BoxShadow(
        color: AppColors.shadowColor.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    );
    
    // Glow effect
    if (widget.showGlow || _isHovered) {
      Color glowColor;
      switch (widget.type) {
        case MysticalButtonType.primary:
          glowColor = AppColors.primary;
          break;
        case MysticalButtonType.secondary:
          glowColor = AppColors.secondary;
          break;
        case MysticalButtonType.accent:
          glowColor = AppColors.accent;
          break;
        case MysticalButtonType.premium:
          glowColor = AppColors.premium;
          break;
        case MysticalButtonType.ghost:
          glowColor = AppColors.primary;
          break;
      }
      
      shadows.add(
        BoxShadow(
          color: glowColor.withValues(alpha: 0.5 * _glowAnimation.value),
          blurRadius: 20 * _glowAnimation.value,
          spreadRadius: 2 * _glowAnimation.value,
        ),
      );
    }
    
    // Pressed effect
    if (_isPressed) {
      shadows.add(
        BoxShadow(
          color: AppColors.shadowColor.withValues(alpha: 0.5),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      );
    }
    
    return shadows;
  }

  Widget _buildButtonContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          _buildLoadingIndicator()
        else if (widget.icon != null)
          _buildIcon(),
        
        if (widget.isLoading && widget.icon != null)
          const SizedBox(width: 8)
        else if (widget.icon != null && widget.text.isNotEmpty)
          const SizedBox(width: 8),
        
        if (widget.text.isNotEmpty)
          Flexible(
            child: Text(
              widget.text,
              style: widget.customTextStyle ?? _getTextStyle(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return MysticalLoading(
      type: MysticalLoadingType.spinner,
      size: _getIconSize(),
      strokeWidth: 2,
      color: _getTextColor(),
    );
  }

  Widget _buildIcon() {
    return Icon(
      widget.icon,
      size: _getIconSize(),
      color: _getTextColor(),
    );
  }

  double _getIconSize() {
    switch (widget.size) {
      case MysticalButtonSize.small:
        return 16;
      case MysticalButtonSize.medium:
        return 20;
      case MysticalButtonSize.large:
        return 24;
    }
  }

  TextStyle _getTextStyle() {
    TextStyle baseStyle;
    
    switch (widget.size) {
      case MysticalButtonSize.small:
        baseStyle = AppTextStyles.buttonSmall;
        break;
      case MysticalButtonSize.medium:
        baseStyle = AppTextStyles.button;
        break;
      case MysticalButtonSize.large:
        baseStyle = AppTextStyles.buttonLarge;
        break;
    }
    
    return baseStyle.copyWith(
      color: _getTextColor(),
      fontWeight: FontWeight.w600,
    );
  }

  Color _getTextColor() {
    if (!widget.isEnabled) {
      return AppColors.textDisabled;
    }
    
    switch (widget.type) {
      case MysticalButtonType.primary:
      case MysticalButtonType.secondary:
      case MysticalButtonType.accent:
      case MysticalButtonType.premium:
        return Colors.white;
      case MysticalButtonType.ghost:
        return AppColors.primary;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    _loadingController.dispose();
    super.dispose();
  }
}
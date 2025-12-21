import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// iOS 26 Premium Glassmorphism Component Library
/// Reusable widgets for the Falla Premium Design System

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isSelected;
  final bool isHero;
  final VoidCallback? onTap;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 22,
    this.padding = const EdgeInsets.all(20),
    this.isSelected = false,
    this.isHero = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutQuart,
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isHero ? 45 : (isSelected ? 40 : 35),
                sigmaY: isHero ? 45 : (isSelected ? 40 : 35),
              ),
              child: Container(
                padding: padding,
                decoration: _getDecoration(),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    if (isHero) {
      return AppColors.premiumHeroCardDecoration;
    } else if (isSelected) {
      return AppColors.premiumSelectedCardDecoration;
    } else {
      return AppColors.premiumGlassCardDecoration;
    }
  }
}

class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;

  const GlassButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 54,
    this.width,
  }) : super(key: key);

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutQuart,
        child: RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.height / 2),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  gradient: AppColors.champagneGoldGradient,
                  borderRadius: BorderRadius.circular(widget.height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.champagneGold.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
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
                              AppColors.premiumDarkBg,
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
                                color: AppColors.premiumDarkBg,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.premiumDarkBg,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassBadge extends StatelessWidget {
  final String text;
  final bool isGold;
  final IconData? icon;

  const GlassBadge({
    Key? key,
    required this.text,
    this.isGold = true,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: isGold ? AppColors.champagneGoldGradient : null,
        color: isGold ? null : Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isGold
            ? [
                BoxShadow(
                  color: AppColors.champagneGold.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isGold ? AppColors.premiumDarkBg : Colors.white,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'SF Pro Text',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isGold ? AppColors.premiumDarkBg : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blurRadius;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    Key? key,
    required this.child,
    this.blurRadius = 35,
    this.borderRadius = 20,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: AppColors.premiumGlassGradient,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: AppColors.premiumGlassBorder,
                  width: 1,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const PremiumScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.premiumDarkBg,
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.premiumDarkGradient,
        ),
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const GlassAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 8,
              right: 8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.04),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.10),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                if (onBackPressed != null)
                  IconButton(
                    onPressed: onBackPressed,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.warmIvory,
                      size: 22,
                    ),
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmIvory,
                    ),
                  ),
                ),
                if (actions != null)
                  Row(mainAxisSize: MainAxisSize.min, children: actions!)
                else
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium text styles for easy use
class PremiumTextStyles {
  static TextStyle get display => TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: AppColors.warmIvory,
        letterSpacing: -0.5,
        height: 1.1,
      );

  static TextStyle get headline => TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.warmIvory,
      );

  static TextStyle get section => TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.9),
      );

  static TextStyle get body => TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.7),
      );

  static TextStyle get caption => TextStyle(
        fontFamily: 'SF Pro Text',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.5),
      );

  static TextStyle get price => TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.champagneGold,
      );

  static TextStyle get karma => TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.champagneGold,
      );
}

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/mystical_loading.dart';

enum CustomButtonType {
  primary,
  secondary,
  premium,
  danger,
  success,
  ghost,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height = 48,
    this.padding,
    this.textStyle,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = this.isDisabled || onPressed == null || isLoading;
    
    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDisabled ? null : _getShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: MysticalLoading(
                      type: MysticalLoadingType.spinner,
                      size: 20,
                      color: _getTextColor(),
                    ),
                  ),
                  const SizedBox(width: 12),
                ] else if (icon != null) ...[
                  Icon(icon, color: _getTextColor(), size: 20),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: textStyle ?? TextStyle(
                      color: _getTextColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient? _getGradient() {
    if (type == CustomButtonType.ghost) return null;
    
    switch (type) {
      case CustomButtonType.primary:
        return AppColors.primaryGradient;
      case CustomButtonType.secondary:
        return AppColors.secondaryGradient;
      case CustomButtonType.premium:
        return AppColors.premiumGradient;
      case CustomButtonType.danger:
        return const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFE53E3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CustomButtonType.success:
        return const LinearGradient(
          colors: [Color(0xFF48BB78), Color(0xFF38A169)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CustomButtonType.ghost:
        return null;
    }
  }

  List<BoxShadow>? _getShadow() {
    switch (type) {
      case CustomButtonType.primary:
        return [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
      case CustomButtonType.premium:
        return [
          BoxShadow(
            color: AppColors.premium.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ];
    }
  }

  Color _getTextColor() {
    if (type == CustomButtonType.ghost) {
      return AppColors.primary;
    }
    return Colors.white;
  }
}

// Özel buton varyantları
class MysticalButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const MysticalButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: CustomButtonType.primary,
      isLoading: isLoading,
      isFullWidth: true,
      icon: icon,
      height: 52,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: CustomButtonType.premium,
      isLoading: isLoading,
      isFullWidth: true,
      icon: icon,
      height: 56,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
        shadows: [
          Shadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );
  }
}

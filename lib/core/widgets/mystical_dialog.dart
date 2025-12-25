import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

enum MysticalDialogType {
  info,
  success,
  warning,
  error,
  confirm,
  custom,
}

class MysticalDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final MysticalDialogType type;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? customIcon;
  final Color? customIconColor;
  final bool barrierDismissible;

  const MysticalDialog({
    Key? key,
    required this.title,
    this.message,
    this.content,
    this.type = MysticalDialogType.info,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.customIcon,
    this.customIconColor,
    this.barrierDismissible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return PopScope(
      canPop: barrierDismissible,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? AppColors.surface.withValues(alpha: 0.95) : AppColors.premiumLightSurface.withValues(alpha: 0.95),
                    isDark ? AppColors.surface.withValues(alpha: 0.9) : AppColors.premiumLightSurface.withValues(alpha: 0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.champagneGold.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: -5,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: _getTypeColor().withValues(alpha: 0.1),
                    blurRadius: 40,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildIcon(context, isDark),
                        const SizedBox(height: 20),
                        _buildTitle(context, isDark),
                        if (message != null || content != null) ...[
                          const SizedBox(height: 12),
                          _buildContent(context, isDark),
                        ],
                        // Always show actions for error, success, warning, info, and confirm types
                        if (onConfirm != null || 
                            onCancel != null || 
                            type == MysticalDialogType.error ||
                            type == MysticalDialogType.success ||
                            type == MysticalDialogType.warning ||
                            type == MysticalDialogType.info ||
                            type == MysticalDialogType.confirm) ...[
                          const SizedBox(height: 24),
                          _buildActions(context, isDark),
                        ],
                      ],
                    ),
                  ),
                  // Kapatma butonu (sağ üst köşe)
                  if (barrierDismissible)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.premiumLightTextSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.premiumLightTextSecondary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.getIconColor(isDark),
                            size: 18,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          onCancel?.call();
                        },
                        tooltip: AppStrings.close,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, bool isDark) {
    IconData icon;
    Color color;

    if (customIcon != null) {
      icon = customIcon!;
      color = customIconColor ?? _getTypeColor();
    } else {
      switch (type) {
        case MysticalDialogType.success:
          icon = Icons.check_circle_rounded;
          color = AppColors.success;
          break;
        case MysticalDialogType.error:
          icon = Icons.error_rounded;
          color = AppColors.error;
          break;
        case MysticalDialogType.warning:
          icon = Icons.warning_rounded;
          color = AppColors.warning;
          break;
        case MysticalDialogType.confirm:
          icon = Icons.help_rounded;
          color = AppColors.info;
          break;
        default:
          icon = Icons.info_rounded;
          color = AppColors.info;
      }
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 32,
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(
        color: AppColors.getTextPrimary(isDark),
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    if (content != null) {
      return content!;
    }

    return Text(
      message ?? '',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.getTextSecondary(isDark),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    final hasCancel = onCancel != null || (type == MysticalDialogType.confirm);
    // Show confirm button if onConfirm is provided, or for error/success/warning/info/confirm types
    final hasConfirm = onConfirm != null || 
                       type == MysticalDialogType.confirm ||
                       type == MysticalDialogType.error ||
                       type == MysticalDialogType.success ||
                       type == MysticalDialogType.warning ||
                       type == MysticalDialogType.info;

    return Row(
      children: [
        if (hasCancel) ...[
          Expanded(
            child: _buildActionButton(
              context,
              isDark,
              text: cancelText ?? AppStrings.cancel,
              onPressed: () {
                Navigator.of(context).pop(false);
                onCancel?.call();
              },
              isPrimary: false,
            ),
          ),
          if (hasConfirm) const SizedBox(width: 12),
        ],
        if (hasConfirm)
          Expanded(
            child: _buildActionButton(
              context,
              isDark,
              text: confirmText ?? (type == MysticalDialogType.confirm ? AppStrings.confirm : AppStrings.ok),
              onPressed: () {
                Navigator.of(context).pop(true);
                onConfirm?.call();
              },
              isPrimary: true,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    bool isDark, {
    required String text,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getTypeColor(),
              _getTypeColor().withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _getTypeColor().withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                text,
                style: AppTextStyles.buttonMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.premiumLightTextSecondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.premiumLightTextSecondary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Text(
                text,
                style: AppTextStyles.buttonMedium.copyWith(
                  color: isDark ? Colors.white70 : AppColors.getTextSecondary(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case MysticalDialogType.success:
        return AppColors.success;
      case MysticalDialogType.error:
        return AppColors.error;
      case MysticalDialogType.warning:
        return AppColors.warning;
      case MysticalDialogType.confirm:
        return AppColors.primary;
      default:
        return AppColors.info;
    }
  }

  // Static helper methods for easy usage
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    MysticalDialogType type = MysticalDialogType.info,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    IconData? customIcon,
    Color? customIconColor,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => MysticalDialog(
        title: title,
        message: message,
        content: content,
        type: type,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        customIcon: customIcon,
        customIconColor: customIconColor,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmText,
    String? cancelText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: MysticalDialogType.confirm,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: onConfirm,
      onCancel: onCancel,
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: MysticalDialogType.success,
      confirmText: confirmText ?? AppStrings.ok,
      onConfirm: onConfirm,
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: MysticalDialogType.error,
      confirmText: confirmText ?? AppStrings.ok,
      onConfirm: onConfirm,
    );
  }

  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: MysticalDialogType.warning,
      confirmText: confirmText ?? AppStrings.ok,
      onConfirm: onConfirm,
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      type: MysticalDialogType.info,
      confirmText: confirmText ?? AppStrings.ok,
      onConfirm: onConfirm,
    );
  }
}


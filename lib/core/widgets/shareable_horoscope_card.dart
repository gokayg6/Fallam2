import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_strings.dart';

class ShareableHoroscopeCard extends StatelessWidget {
  final String zodiacName;
  final String emoji;
  final String horoscopeText;
  final GlobalKey? repaintKey;

  const ShareableHoroscopeCard({
    super.key,
    required this.zodiacName,
    required this.emoji,
    required this.horoscopeText,
    this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    // Instagram story format: 1080x1920 (9:16 aspect ratio)
        return RepaintBoundary(
          key: repaintKey,
          child: Container(
            width: 1080,
            height: 1920,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.accent.withValues(alpha: 0.2),
                  AppColors.background,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Background decorative elements
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: CustomPaint(
                      painter: _StarPatternPainter(),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(80),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo/Header
                      Column(
                        children: [
                          Text(
                            'Falla Aura',
                            style: AppTextStyles.headingLarge.copyWith(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 200,
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      
                      // Horoscope content
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Zodiac emoji and name
                              Text(
                                emoji,
                                style: const TextStyle(fontSize: 120),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                zodiacName,
                                style: AppTextStyles.headingMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 48),
                              // Horoscope text (1-2 sentences)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 32,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  horoscopeText,
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontSize: 36,
                                    height: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Footer
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              AppStrings.isEnglish
                                  ? 'Get your reading with Falla Aura'
                                  : 'Falla Aura ile falını baktır',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'falla.app',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

class _StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw stars pattern
    for (int i = 0; i < 50; i++) {
      final x = (i * 137.5) % size.width;
      final y = (i * 197.3) % size.height;
      _drawStar(canvas, Offset(x, y), 3, paint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


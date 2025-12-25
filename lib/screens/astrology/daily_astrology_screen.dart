import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/ai_service.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/models/love_candidate_model.dart';

class DailyAstrologyScreen extends StatefulWidget {
  final LoveCandidateModel? candidate;
  
  const DailyAstrologyScreen({super.key, this.candidate});

  @override
  State<DailyAstrologyScreen> createState() => _DailyAstrologyScreenState();
}

class _DailyAstrologyScreenState extends State<DailyAstrologyScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, int> _scores = {};
  bool _loading = false;
  final AIService _aiService = AIService();

  @override
  void initState() {
    super.initState();
    _calculateScores();
  }

  Future<void> _calculateScores() async {
    setState(() {
      _loading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      final userZodiacSign = user?.zodiacSign;
      
      if (userZodiacSign == null) {
        setState(() {
          _scores = {'social': 50, 'love': 50, 'passion': 50};
          _loading = false;
        });
        return;
      }

      // If candidate is provided, use love compatibility scores
      if (widget.candidate != null) {
        final scores = await _aiService.generateLoveCandidateAstrologyScores(
          userZodiacSign: userZodiacSign,
          candidateZodiacSign: widget.candidate!.zodiacSign,
          candidateName: widget.candidate!.name,
          date: _selectedDate,
          english: AppStrings.isEnglish,
        );
        
        if (mounted) {
          setState(() {
            _scores = scores;
            _loading = false;
          });
        }
      } else {
        // Get scores from AI for user's own zodiac
        final scores = await _aiService.generateDailyAstrologyScores(
          zodiacSign: userZodiacSign,
          date: _selectedDate,
          english: AppStrings.isEnglish,
        );
        
        if (mounted) {
          setState(() {
            _scores = scores;
            _loading = false;
          });
        }
      }
    } catch (e) {
      // Fallback to simple calculation if AI fails
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = userProvider.user;
        final userZodiacSign = user?.zodiacSign;
        
        if (userZodiacSign != null) {
          final dayOfYear = _selectedDate.difference(DateTime(_selectedDate.year, 1, 1)).inDays;
          
          if (widget.candidate != null) {
            // Compatibility-based fallback
            final userIndex = _getZodiacIndex(userZodiacSign);
            final candidateIndex = _getZodiacIndex(widget.candidate!.zodiacSign);
            final compatibilityFactor = (12 - (userIndex - candidateIndex).abs()) / 12;
            
            final baseSocial = (60 + (compatibilityFactor * 30) + (dayOfYear % 20)).clamp(0, 100).toInt();
            final baseLove = (50 + (compatibilityFactor * 40) + ((dayOfYear + 7) % 25)).clamp(0, 100).toInt();
            final basePassion = (55 + (compatibilityFactor * 35) + ((dayOfYear + 14) % 20)).clamp(0, 100).toInt();
            
            setState(() {
              _scores = {
                'social': baseSocial,
                'love': baseLove,
                'passion': basePassion,
              };
              _loading = false;
            });
          } else {
            final zodiacIndex = _getZodiacIndex(userZodiacSign);
            
            final baseSocial = 60 + (zodiacIndex * 3) + (dayOfYear % 30);
            final baseLove = 50 + (zodiacIndex * 2) + ((dayOfYear + 7) % 25);
            final basePassion = 55 + (zodiacIndex * 2.5) + ((dayOfYear + 14) % 20);
            
            setState(() {
              _scores = {
                'social': baseSocial.clamp(0, 100).toInt(),
                'love': baseLove.clamp(0, 100).toInt(),
                'passion': basePassion.clamp(0, 100).toInt(),
              };
              _loading = false;
            });
          }
        } else {
          setState(() {
            _scores = {'social': 50, 'love': 50, 'passion': 50};
            _loading = false;
          });
        }
      }
    }
  }

  int _getZodiacIndex(String zodiacSign) {
    final signs = ['Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 
                   'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'];
    final englishSigns = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                          'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
    
    final lower = zodiacSign.toLowerCase().trim();
    
    // Check Turkish signs
    for (int i = 0; i < signs.length; i++) {
      final signLower = signs[i].toLowerCase();
      if (lower == signLower || lower.contains(signLower.substring(0, 2))) {
        return i;
      }
    }
    
    // Check English signs
    for (int i = 0; i < englishSigns.length; i++) {
      final signLower = englishSigns[i].toLowerCase();
      if (lower == signLower || lower.contains(signLower.substring(0, 3))) {
        return i;
      }
    }
    
    return 0; // Default to first sign if not found
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _calculateScores();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, UserProvider>(
      builder: (context, themeProvider, userProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final textColor = AppColors.getTextPrimary(isDark);
        final textSecondaryColor = AppColors.getTextSecondary(isDark);
        final cardBg = AppColors.getCardBackground(isDark);
        final user = userProvider.user;
        final zodiacSign = widget.candidate != null 
            ? widget.candidate!.zodiacSign 
            : (user?.zodiacSign ?? AppStrings.notSpecified);
        final displayName = widget.candidate != null 
            ? widget.candidate!.name 
            : null;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(gradient: themeProvider.backgroundGradient),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = constraints.maxWidth > constraints.maxHeight;
                  
                  return Column(
                    children: [
                      _buildHeader(isDark, textColor, displayName),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: isLandscape
                              ? _buildLandscapeLayout(
                                  isDark, textColor, textSecondaryColor, cardBg, zodiacSign)
                              : _buildPortraitLayout(
                                  isDark, textColor, textSecondaryColor, cardBg, zodiacSign),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPortraitLayout(
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
    Color cardBg,
    String zodiacSign,
  ) {
    return Column(
      children: [
        _buildDateSelector(isDark, textColor, cardBg),
        const SizedBox(height: 24),
        _buildAstrologicalChart(isDark, textColor, zodiacSign, isLandscape: false),
        const SizedBox(height: 32),
        _buildScoresSection(isDark, textColor, textSecondaryColor, cardBg),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
    Color cardBg,
    String zodiacSign,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildDateSelector(isDark, textColor, cardBg),
              const SizedBox(height: 24),
              _buildAstrologicalChart(isDark, textColor, zodiacSign, isLandscape: true),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildScoresSection(isDark, textColor, textSecondaryColor, cardBg),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark, Color textColor, String? candidateName) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidateName != null 
                      ? (AppStrings.isEnglish ? 'Love Compatibility Chart' : 'Aşk Uyum Grafiği')
                      : AppStrings.dailyHoroscope,
                  style: AppTextStyles.headingLarge.copyWith(color: textColor),
                ),
                if (candidateName != null)
                  Text(
                    candidateName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(bool isDark, Color textColor, Color cardBg) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final isToday = _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;
    final isYesterday = _selectedDate.year == yesterday.year &&
        _selectedDate.month == yesterday.month &&
        _selectedDate.day == yesterday.day;
    final isTomorrow = _selectedDate.year == tomorrow.year &&
        _selectedDate.month == tomorrow.month &&
        _selectedDate.day == tomorrow.day;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDateButton(
              AppStrings.isEnglish ? 'Yesterday' : 'Dün',
              isYesterday,
              () => _selectDate(yesterday),
              isDark,
              textColor,
              cardBg,
            ),
          ),
          Expanded(
            child: _buildDateButton(
              AppStrings.today,
              isToday,
              () => _selectDate(today),
              isDark,
              textColor,
              cardBg,
            ),
          ),
          Expanded(
            child: _buildDateButton(
              AppStrings.isEnglish ? 'Tomorrow' : 'Yarın',
              isTomorrow,
              () => _selectDate(tomorrow),
              isDark,
              textColor,
              cardBg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
    Color textColor,
    Color cardBg,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAstrologicalChart(
    bool isDark,
    Color textColor,
    String zodiacSign, {
    required bool isLandscape,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartSize = isLandscape
            ? math.min(constraints.maxWidth, constraints.maxHeight * 0.8)
            : math.min(constraints.maxWidth, 280.0);
        final center = chartSize / 2;
        final radius = chartSize * 0.32; // Slightly smaller radius to fit better
        final emojiSize = chartSize * 0.10; // Smaller emoji
        final emojiContainerSize = chartSize * 0.12; // Smaller container
        
        // Find the selected zodiac index (only if candidate is provided)
        final selectedZodiacIndex = widget.candidate != null 
            ? _getZodiacIndex(zodiacSign) 
            : null;
        
        return Center(
          child: Container(
            height: chartSize,
            width: chartSize,
            decoration: BoxDecoration(
              color: AppColors.getCardBackground(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Central geometric pattern
                CustomPaint(
                  size: Size(chartSize, chartSize),
                  painter: _AstrologicalChartPainter(isDark, radius, selectedZodiacIndex),
                ),
                // Zodiac signs around the circle
                ...List.generate(12, (index) {
                  final angle = (index * 30 - 90) * math.pi / 180;
                  final x = math.cos(angle) * radius;
                  final y = math.sin(angle) * radius;
                  
                  final emojis = ['♈', '♉', '♊', '♋', '♌', '♍',
                                '♎', '♏', '♐', '♑', '♒', '♓'];
                  
                  // Zodiac colors matching the image
                  final zodiacColors = [
                    const Color(0xFFFF4444), // Koç - Kırmızı
                    const Color(0xFFFF8800), // Boğa - Turuncu
                    const Color(0xFFFFAA00), // İkizler - Sarı-turuncu
                    const Color(0xFFFFDD00), // Yengeç - Sarı
                    const Color(0xFFFFFF00), // Aslan - Parlak sarı
                    const Color(0xFF88FF88), // Başak - Açık yeşil
                    const Color(0xFF00FF88), // Terazi - Yeşil
                    const Color(0xFF00DDFF), // Akrep - Turkuaz
                    const Color(0xFF0088FF), // Yay - Mavi
                    const Color(0xFF8800FF), // Oğlak - Mor
                    const Color(0xFF6600CC), // Kova - Koyu mor
                    const Color(0xFFFF88CC), // Balık - Pembe
                  ];
                  
                  final isSelected = selectedZodiacIndex != null && index == selectedZodiacIndex;
                  final capsuleWidth = isSelected 
                      ? emojiContainerSize * 1.9  // Larger for selected
                      : emojiContainerSize * 1.6;
                  final capsuleHeight = isSelected
                      ? emojiContainerSize * 1.2  // Larger for selected
                      : emojiContainerSize * 1.0;
                  
                  return Positioned(
                    left: center + x - (capsuleWidth / 2),
                    top: center + y - (capsuleHeight / 2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: capsuleWidth,
                      height: capsuleHeight,
                      padding: EdgeInsets.symmetric(
                        horizontal: capsuleWidth * 0.15,
                        vertical: capsuleHeight * 0.1,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? zodiacColors[index] : Colors.transparent,
                        borderRadius: BorderRadius.circular(capsuleHeight / 2),
                        border: isSelected
                            ? Border.all(
                                color: Colors.white,
                                width: 3,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: zodiacColors[index].withValues(alpha: 0.8),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 0),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 0),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            emojis[index],
                            style: TextStyle(
                              fontSize: isSelected ? emojiSize * 1.2 : emojiSize,
                              color: isSelected ? Colors.white : zodiacColors[index],
                              height: 1.0,
                              shadows: isSelected
                                  ? [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
              }),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildScoresSection(
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
    Color cardBg,
  ) {
    if (_loading) {
      return Center(
        child: MysticalLoading(
          type: MysticalLoadingType.spinner,
          color: AppColors.primary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.isEnglish ? 'Scores' : 'Skorlar',
          style: AppTextStyles.headingMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildScoreCard(
          AppStrings.isEnglish ? 'Social' : 'Sosyal',
          Icons.people,
          _scores['social'] ?? 0,
          const Color(0xFF00BCD4),
          isDark,
          textColor,
          cardBg,
        ),
        const SizedBox(height: 12),
        _buildScoreCard(
          AppStrings.loveTest,
          Icons.favorite,
          _scores['love'] ?? 0,
          const Color(0xFFE91E63),
          isDark,
          textColor,
          cardBg,
        ),
        const SizedBox(height: 12),
        _buildScoreCard(
          AppStrings.isEnglish ? 'Passion' : 'Tutku',
          Icons.local_fire_department,
          _scores['passion'] ?? 0,
          const Color(0xFF9C27B0),
          isDark,
          textColor,
          cardBg,
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    String label,
    IconData icon,
    int score,
    Color color,
    bool isDark,
    Color textColor,
    Color cardBg,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$score',
            style: AppTextStyles.headingSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AstrologicalChartPainter extends CustomPainter {
  final bool isDark;
  final double radius;
  final int? selectedZodiacIndex;

  _AstrologicalChartPainter(this.isDark, this.radius, [this.selectedZodiacIndex]);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final centralCircleRadius = radius * 0.15;

    // Bright magenta/pink color for lines matching the image
    final lineColor = const Color(0xFFFF00FF).withValues(alpha: 0.6);
    
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centerPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // Draw lines from center to each zodiac point
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      
      // Highlight line to selected zodiac
      final isSelected = selectedZodiacIndex != null && i == selectedZodiacIndex;
      final paint = isSelected
          ? (Paint()
            ..color = lineColor.withValues(alpha: 1.0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0)
          : linePaint;
      
      // Draw lines from center to points
      canvas.drawLine(center, Offset(x, y), paint);
    }
    
    // Draw connecting lines between adjacent points (polygon)
    for (int i = 0; i < 12; i++) {
      final angle1 = (i * 30) * math.pi / 180;
      final angle2 = ((i + 1) % 12 * 30) * math.pi / 180;
      
      final x1 = center.dx + math.cos(angle1) * radius;
      final y1 = center.dy + math.sin(angle1) * radius;
      final x2 = center.dx + math.cos(angle2) * radius;
      final y2 = center.dy + math.sin(angle2) * radius;
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
    }
    
    // Draw central bright circle
    canvas.drawCircle(center, centralCircleRadius, centerPaint);
    
    // Add glow effect to center
    final glowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, centralCircleRadius * 1.5, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _AstrologicalChartPainter oldDelegate) =>
      oldDelegate.isDark != isDark || 
      oldDelegate.radius != radius ||
      oldDelegate.selectedZodiacIndex != selectedZodiacIndex;
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/ai_service.dart';
import '../../providers/theme_provider.dart';
import '../../core/models/love_candidate_model.dart';

class AstrologyCalendarScreen extends StatefulWidget {
  final LoveCandidateModel? candidate;
  
  const AstrologyCalendarScreen({super.key, this.candidate});

  @override
  State<AstrologyCalendarScreen> createState() => _AstrologyCalendarScreenState();
}

class _AstrologyCalendarScreenState extends State<AstrologyCalendarScreen> {
  DateTime _selectedMonth = DateTime.now();
  String _selectedTab = 'social'; // 'social', 'passion', 'love'
  Map<String, Map<String, int>> _dailyScores = {};
  final AIService _aiService = AIService();
  bool _loading = false;
  
  // Static cache for scores: key = 'zodiacSign_dateKey', value = {scores, timestamp}
  static final Map<String, _CachedScore> _scoreCache = {};
  static const Duration _cacheDuration = Duration(hours: 1);

  @override
  void initState() {
    super.initState();
    _generateScores();
  }

  Future<void> _generateScores() async {
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    final userZodiacSign = user?.zodiacSign;
    
    if (userZodiacSign == null) {
      setState(() {
        _dailyScores = {};
        _loading = false;
      });
      return;
    }

    // Determine cache key and zodiac sign based on whether candidate is provided
    final zodiacSign = widget.candidate != null 
        ? widget.candidate!.zodiacSign 
        : userZodiacSign;
    final cachePrefix = widget.candidate != null 
        ? '${userZodiacSign}_${widget.candidate!.zodiacSign}_${widget.candidate!.id}'
        : userZodiacSign;

    // First, load from cache and show immediately
    final cachedScores = <String, Map<String, int>>{};
    final missingDates = <DateTime>[];
    
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final dateKey = '${date.year}-${date.month}-${date.day}';
      final cacheKey = '${cachePrefix}_$dateKey';
      
      final cached = _scoreCache[cacheKey];
      if (cached != null && 
          DateTime.now().difference(cached.timestamp) < _cacheDuration) {
        // Cache is valid
        cachedScores[dateKey] = cached.scores;
      } else {
        // Cache miss or expired
        missingDates.add(date);
      }
    }
    
    // Show cached scores immediately
    if (cachedScores.isNotEmpty || missingDates.isEmpty) {
      setState(() {
        _dailyScores = cachedScores;
        _loading = missingDates.isNotEmpty; // Only show loading if we need to fetch
      });
    } else {
      setState(() {
        _loading = true;
      });
    }

    // Fetch missing scores in parallel
    if (missingDates.isNotEmpty) {
      final scores = <String, Map<String, int>>{...cachedScores};
      
      // Fetch in batches to avoid overwhelming the API
      final batchSize = 5;
      for (int i = 0; i < missingDates.length; i += batchSize) {
        final batch = missingDates.skip(i).take(batchSize).toList();
        
        await Future.wait(
          batch.map((date) async {
            final dateKey = '${date.year}-${date.month}-${date.day}';
            final cacheKey = '${cachePrefix}_$dateKey';
            
            try {
              Map<String, int> dayScores;
              
              // If candidate is provided, use love compatibility scores
              if (widget.candidate != null) {
                dayScores = await _aiService.generateLoveCandidateAstrologyScores(
                  userZodiacSign: userZodiacSign,
                  candidateZodiacSign: widget.candidate!.zodiacSign,
                  candidateName: widget.candidate!.name,
                  date: date,
                  english: AppStrings.isEnglish,
                );
              } else {
                // Get scores from AI for user's own zodiac
                dayScores = await _aiService.generateDailyAstrologyScores(
                  zodiacSign: zodiacSign,
                  date: date,
                  english: AppStrings.isEnglish,
                );
              }
              
              // Cache the result
              _scoreCache[cacheKey] = _CachedScore(
                scores: dayScores,
                timestamp: DateTime.now(),
              );
              
              scores[dateKey] = dayScores;
            } catch (e) {
              // Fallback to simple calculation if AI fails
              final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
              
              Map<String, int> fallbackScores;
              
              if (widget.candidate != null) {
                // Compatibility-based fallback
                final userIndex = _getZodiacIndex(userZodiacSign);
                final candidateIndex = _getZodiacIndex(widget.candidate!.zodiacSign);
                final compatibilityFactor = (12 - (userIndex - candidateIndex).abs()) / 12;
                
                final baseSocial = (60 + (compatibilityFactor * 30) + (dayOfYear % 20)).clamp(0, 100).toInt();
                final basePassion = (55 + (compatibilityFactor * 35) + ((dayOfYear + 7) % 25)).clamp(0, 100).toInt();
                final baseLove = (50 + (compatibilityFactor * 40) + ((dayOfYear + 14) % 20)).clamp(0, 100).toInt();
                
                fallbackScores = {
                  'social': baseSocial,
                  'passion': basePassion,
                  'love': baseLove,
                };
              } else {
                final zodiacIndex = _getZodiacIndex(zodiacSign);
                
                final baseSocial = 60 + (zodiacIndex * 3) + (dayOfYear % 30);
                final basePassion = 55 + (zodiacIndex * 2.5) + ((dayOfYear + 7) % 25);
                final baseLove = 50 + (zodiacIndex * 2) + ((dayOfYear + 14) % 20);
                
                fallbackScores = {
                  'social': baseSocial.clamp(0, 100).toInt(),
                  'passion': basePassion.clamp(0, 100).toInt(),
                  'love': baseLove.clamp(0, 100).toInt(),
                };
              }
              
              // Cache fallback scores too
              _scoreCache[cacheKey] = _CachedScore(
                scores: fallbackScores,
                timestamp: DateTime.now(),
              );
              
              scores[dateKey] = fallbackScores;
            }
          }),
        );
        
        // Update UI after each batch
        if (mounted) {
          setState(() {
            _dailyScores = Map<String, Map<String, int>>.from(scores);
          });
        }
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  int _getZodiacIndex(String zodiacSign) {
    final signs = ['Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 
                   'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'];
    final lower = zodiacSign.toLowerCase();
    for (int i = 0; i < signs.length; i++) {
      if (lower.contains(signs[i].toLowerCase().substring(0, 2))) {
        return i;
      }
    }
    return 0;
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    });
    _generateScores();
  }

  int? _getScoreForDate(DateTime date) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    return _dailyScores[dateKey]?[_selectedTab];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, UserProvider>(
      builder: (context, themeProvider, userProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final textColor = AppColors.getTextPrimary(isDark);
        final textSecondaryColor = AppColors.getTextSecondary(isDark);
        final cardBg = AppColors.getCardBackground(isDark);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(gradient: themeProvider.backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark, textColor),
                  _buildTabSelector(isDark, textColor, cardBg),
                  Expanded(
                    child: _loading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppStrings.isEnglish ? 'Loading scores...' : 'Skorlar yükleniyor...',
                                  style: AppTextStyles.bodyMedium.copyWith(color: textSecondaryColor),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildMonthSelector(isDark, textColor, cardBg),
                                const SizedBox(height: 20),
                                _buildCalendar(isDark, textColor, textSecondaryColor, cardBg),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark, Color textColor) {
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
                  widget.candidate != null
                      ? (AppStrings.isEnglish ? 'Love Compatibility Calendar' : 'Aşk Uyum Takvimi')
                      : (AppStrings.isEnglish ? 'Calendar' : 'Takvim'),
                  style: AppTextStyles.headingLarge.copyWith(color: textColor),
                ),
                if (widget.candidate != null)
                  Text(
                    widget.candidate!.name,
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

  Widget _buildTabSelector(bool isDark, Color textColor, Color cardBg) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            child: _buildTabButton(
              AppStrings.isEnglish ? 'Social' : 'Sosyal',
              'social',
              isDark,
              textColor,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              AppStrings.isEnglish ? 'Passion' : 'Tutku',
              'passion',
              isDark,
              textColor,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              AppStrings.loveTest,
              'love',
              isDark,
              textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    String label,
    String value,
    bool isDark,
    Color textColor,
  ) {
    final isSelected = _selectedTab == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = value;
        });
      },
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

  Widget _buildMonthSelector(bool isDark, Color textColor, Color cardBg) {
    final monthName = DateFormat('MMMM yyyy', AppStrings.isEnglish ? 'en' : 'tr')
        .format(_selectedMonth);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: Icon(Icons.chevron_left, color: textColor),
          ),
          Text(
            monthName,
            style: AppTextStyles.headingSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => _changeMonth(1),
            icon: Icon(Icons.chevron_right, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
    Color cardBg,
  ) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday % 7; // 0 = Sunday, 6 = Saturday
    
    final weeks = <List<DateTime?>>[];
    List<DateTime?> currentWeek = [];
    
    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      currentWeek.add(null);
    }
    
    // Add all days of the month
    for (int day = 1; day <= lastDay.day; day++) {
      currentWeek.add(DateTime(_selectedMonth.year, _selectedMonth.month, day));
      if (currentWeek.length == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }
    
    // Add empty cells for the last week if needed
    while (currentWeek.length < 7 && currentWeek.isNotEmpty) {
      currentWeek.add(null);
    }
    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: textSecondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          // Calendar grid
          ...weeks.map((week) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: week.map((date) => Expanded(
                        child: date == null
                            ? const SizedBox()
                            : _buildDayCell(
                                date,
                                isDark,
                                textColor,
                                textSecondaryColor,
                              ),
                      )).toList(),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDayCell(
    DateTime date,
    bool isDark,
    Color textColor,
    Color textSecondaryColor,
  ) {
    final score = _getScoreForDate(date);
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Container(
      margin: const EdgeInsets.all(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              border: Border.all(
                color: score != null
                    ? const Color(0xFF00BCD4)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tarih numarası - her zaman göster
                  Text(
                    '${date.day}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  // Skor - varsa göster
                  if (score != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$score',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF00BCD4),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Cache entry for scores
class _CachedScore {
  final Map<String, int> scores;
  final DateTime timestamp;

  _CachedScore({
    required this.scores,
    required this.timestamp,
  });
}


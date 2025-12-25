import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/love_candidate_model.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/ai_service.dart';
import '../../core/providers/user_provider.dart';
import '../../core/utils/helpers.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../providers/theme_provider.dart';

class LoveCompatibilityResultScreen extends StatefulWidget {
  final LoveCandidateModel candidate;

  const LoveCompatibilityResultScreen({
    super.key,
    required this.candidate,
  });

  @override
  State<LoveCompatibilityResultScreen> createState() => _LoveCompatibilityResultScreenState();
}

class _LoveCompatibilityResultScreenState extends State<LoveCompatibilityResultScreen> {
  final _firebaseService = FirebaseService();
  final _aiService = AIService();
  
  Map<String, dynamic>? _result;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calculateCompatibility();
  }

  Future<void> _calculateCompatibility() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış. Lütfen giriş yapın.');
      }

      // Burç bilgisini al - eğer yoksa doğum tarihinden hesapla
      String? userZodiac = user.zodiacSign;
      if (userZodiac == null || userZodiac.isEmpty) {
        if (user.birthDate != null) {
          userZodiac = Helpers.calculateZodiacSign(user.birthDate!);
        } else {
          throw Exception('Burç bilgisi bulunamadı. Lütfen profil sayfasından doğum tarihinizi girin.');
        }
      }

      final analysis = await _aiService.generateLoveCompatibilityAnalysis(
        userZodiac: userZodiac,
        candidateZodiac: widget.candidate.zodiacSign,
        candidateName: widget.candidate.name,
        relationshipType: widget.candidate.relationshipType,
        english: AppStrings.isEnglish,
      );

      // Save result to Firebase
      final userId = user.id;
      await _firebaseService.saveCompatibilityResult(
        userId,
        widget.candidate.id,
        analysis,
      );

      if (mounted) {
        setState(() {
          _result = analysis;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Hata: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final textColor = AppColors.getTextPrimary(isDark);
        final textSecondaryColor = AppColors.getTextSecondary(isDark);
        final cardBg = AppColors.getCardBackground(isDark);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.candidate.name),
            backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
            foregroundColor: textColor,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loading ? null : _calculateCompatibility,
                tooltip: 'Yeni Rapor Oluştur',
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: themeProvider.backgroundGradient,
            ),
            child: SafeArea(
              child: _loading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MysticalLoading(
                            type: MysticalLoadingType.spinner,
                            size: 40,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Uyum analizi hesaplanıyor...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _error!,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                if (_error!.contains('doğum tarihi') || _error!.contains('profil'))
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.person),
                                    label: const Text('Geri Dön'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: _calculateCompatibility,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Tekrar Dene'),
                                  ),
                              ],
                            ),
                          ),
                        )
                      : _result == null
                          ? const SizedBox.shrink()
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Overall score
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '%${_getNumericValue(_result!['overallScore']).toInt()}',
                                            style: AppTextStyles.headingLarge.copyWith(
                                              color: Colors.white,
                                              fontSize: 48,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Aşk Uyumu',
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Category bars
                                  _buildCategoryBar(
                                    'Duygusal Uyum',
                                    _getNumericValue(_result!['emotionalCompatibility']),
                                    isDark,
                                    textColor,
                                    cardBg,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCategoryBar(
                                    'İletişim Uyumu',
                                    _getNumericValue(_result!['communicationCompatibility']),
                                    isDark,
                                    textColor,
                                    cardBg,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCategoryBar(
                                    'Uzun Vadeli Uyum',
                                    _getNumericValue(_result!['longTermCompatibility']),
                                    isDark,
                                    textColor,
                                    cardBg,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCategoryBar(
                                    'Çekim / Tutku Uyumu',
                                    _getNumericValue(_result!['passionCompatibility']),
                                    isDark,
                                    textColor,
                                    cardBg,
                                  ),
                                  const SizedBox(height: 32),
                                  // Analysis text
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Detaylı Analiz',
                                          style: AppTextStyles.headingSmall.copyWith(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _result!['analysis'] as String,
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: textColor,
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Strengths
                                  _buildSection(
                                    'Güçlü Yanlar',
                                    _result!['strengths'] as List<dynamic>,
                                    AppColors.success,
                                    isDark,
                                    textColor,
                                    cardBg,
                                  ),
                                  const SizedBox(height: 16),
                                  // Challenges
                                  _buildSection(
                                    'Dikkat Edilmesi Gerekenler',
                                    _result!['challenges'] as List<dynamic>,
                                    AppColors.warning,
                                    isDark,
                                    textColor,
                                    cardBg,
                                  ),
                                ],
                              ),
                            ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to safely convert dynamic to double
  double _getNumericValue(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Widget _buildCategoryBar(
    String label,
    double value,
    bool isDark,
    Color textColor,
    Color cardBg,
  ) {
    final percentage = value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '%${percentage.toInt()}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<dynamic> items,
    Color accentColor,
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
          color: accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.headingSmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: accentColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}


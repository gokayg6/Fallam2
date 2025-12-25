import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:gif/gif.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/test_model.dart';
import '../../core/models/quiz_test_model.dart';
import '../../core/providers/test_provider.dart';
import '../../core/providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/services/quiz_test_service.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/widgets/liquid_glass_widgets.dart';
import '../tests/general_test_screen.dart';
import '../tests/test_result_screen.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/ads/banner_ad_widget.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({Key? key}) : super(key: key);

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen>
    with TickerProviderStateMixin {
  
  String _selectedCategory = 'available';

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  void _loadTests() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final testProvider = Provider.of<TestProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (userProvider.currentUser != null) {
        testProvider.initialize(userProvider.currentUser!.id);
      }
    });
  }

  String _getTestTypeIcon(TestType type) {
    switch (type) {
      case TestType.love:
        return '❤️';
      case TestType.personality:
        return '🧠';
      case TestType.compatibility:
        return '💕';
      case TestType.career:
        return '💼';
      case TestType.friendship:
        return '👥';
      case TestType.family:
        return '👨‍👩‍👧‍👦';
    }
  }

  Color _getTestTypeColor(TestType type, bool isDark) {
    switch (type) {
      case TestType.love:
        return const Color(0xFFE88BC4);
      case TestType.personality:
        return LiquidGlassColors.liquidGlassActive(isDark);
      case TestType.compatibility:
        return const Color(0xFF9B8ED0);
      case TestType.career:
        return const Color(0xFFE6D3A3);
      case TestType.friendship:
        return const Color(0xFF7CC4A4);
      case TestType.family:
        return const Color(0xFF82B4D9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: themeProvider.backgroundGradient,
          ),
          child: SafeArea(
            child: LiquidGlassScreenWrapper(
              duration: const Duration(milliseconds: 700),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildCategorySelector(isDark),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Consumer<TestProvider>(
                            builder: (context, testProvider, child) {
                              if (testProvider.isLoading) {
                                return Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                      child: Container(
                                        padding: const EdgeInsets.all(30),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.15),
                                          ),
                                        ),
                                        child: const MysticalLoading(
                                          type: MysticalLoadingType.stars,
                                          message: 'Testler yükleniyor...',
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return _selectedCategory == 'available'
                                  ? _buildAvailableTests(testProvider, isDark)
                                  : _buildCompletedTests(testProvider, isDark);
                            },
                          ),
                        ),
                        const BannerAdWidget(
                          margin: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ],
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

  Widget _buildHeader() {
    return LiquidGlassHeader(
      title: AppStrings.tests,
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _buildLiquidGlassCategoryButton(
              'available',
              AppStrings.all,
              isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildLiquidGlassCategoryButton(
              'completed',
              AppStrings.completedTests,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidGlassCategoryButton(String value, String label, bool isDark) {
    final isSelected = _selectedCategory == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.5),
                        LiquidGlassColors.liquidGlassSecondary(isDark).withOpacity(0.4),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isDark ? Colors.white.withOpacity(0.12) : AppColors.premiumLightSurface,
                        isDark ? Colors.white.withOpacity(0.05) : AppColors.premiumLightSurface.withOpacity(0.8),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.5)
                    : (isDark ? Colors.white.withOpacity(0.15) : AppColors.premiumLightTextSecondary.withOpacity(0.2)),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.getTextPrimary(false).withOpacity(0.7)),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableTests(TestProvider testProvider, bool isDark) {
    final quizTestService = QuizTestService();
    final allTests = quizTestService.getAllTests();
    
    final popularTestIds = ['personality', 'friendship', 'love', 'compatibility', 'love_what_you_want'];
    final popularTests = allTests.where((test) => 
      popularTestIds.contains(test.id)
    ).toList();
    
    final otherTests = allTests.where((test) => 
      !popularTestIds.contains(test.id)
    ).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (popularTests.isNotEmpty) ...[
            _buildSectionHeader(AppStrings.popularTests, 0, isDark),
            const SizedBox(height: 16),
            _buildPopularTestsList(popularTests, isDark),
            const SizedBox(height: 32),
          ],
          if (otherTests.isNotEmpty) ...[
            _buildSectionHeader(AppStrings.otherTests, 200, isDark),
            const SizedBox(height: 16),
            _buildOtherTestsList(otherTests, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int delayMs, bool isDark) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(-20 * (1 - value), 0),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  AppColors.getTextPrimary(isDark),
                  LiquidGlassColors.shimmerColor(isDark),
                ],
              ).createShader(bounds),
              child: Text(
                title,
                style: AppTextStyles.headingLarge.copyWith(
                  color: AppColors.getTextPrimary(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularTestsList(List<QuizTestDefinition> tests, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return _buildPopularTestCard(test, isDark, index);
      },
    );
  }

  Widget _buildOtherTestsList(List<QuizTestDefinition> tests, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return _buildOtherTestCard(test, isDark, index);
      },
    );
  }

  String? _getTestGifPath(QuizTestDefinition test) {
    switch (test.id) {
      case 'personality':
        return 'assets/gif/populer_testler/kisilik_testi/kisilik_testi.gif';
      case 'friendship':
        return 'assets/gif/populer_testler/arkadaslik_testi/arkadaslik_testi.gif';
      case 'love':
        return 'assets/gif/populer_testler/ask_testi/ask_testi.gif';
      case 'compatibility':
        return 'assets/gif/populer_testler/iliski_uyum_testi/iliski_uyum_testi.gif';
      case 'love_what_you_want':
        return 'assets/gif/populer_testler/iliskinde_gercekten_ne_istiyorsun/iliskinde_gercekten_ne_istiyorsun.gif';
      default:
        return null;
    }
  }

  String _getLocalizedQuizTitle(QuizTestDefinition test) {
    if (!AppStrings.isEnglish) return test.title;
    final lower = test.title.toLowerCase();
    if (lower.contains('kişilik testi')) {
      return AppStrings.personalityTest;
    } else if (lower.contains('arkadaşlık testi')) {
      return AppStrings.friendshipTest;
    } else if (lower.contains('aşk testi')) {
      return AppStrings.loveTest;
    } else if (lower.contains('ilişkinde gerçekten ne istiyorsun')) {
      return AppStrings.relationshipWhatYouWantTest;
    } else if (lower.contains('aşkta kırmızı bayrakları görebiliyor musun')) {
      return AppStrings.loveRedFlagsTest;
    } else if (lower.contains('burcuna göre ne kadar eğlencelisin')) {
      return AppStrings.zodiacFunLevelTest;
    } else if (lower.contains('burcuna göre ne kadar kaotiksin')) {
      return AppStrings.zodiacChaosLevelTest;
    }
    return test.title;
  }

  String _getLocalizedQuizSubtitle(QuizTestDefinition test) {
    if (!AppStrings.isEnglish) return test.description;
    switch (test.id) {
      case 'personality':
        return AppStrings.personalityTestSubtitle;
      case 'friendship':
        return AppStrings.friendshipTestSubtitle;
      case 'love':
        return AppStrings.loveTestSubtitle;
      case 'compatibility':
        return AppStrings.relationshipCompatibilitySubtitle;
      case 'love_what_you_want':
        return AppStrings.relationshipWhatYouWantSubtitle;
      default:
        return test.description;
    }
  }

  Color _getTestColor(String testId, bool isDark) {
    switch (testId) {
      case 'personality':
        return LiquidGlassColors.liquidGlassActive(isDark);
      case 'friendship':
        return const Color(0xFF7CC4A4);
      case 'love':
        return const Color(0xFFE88BC4);
      case 'compatibility':
        return const Color(0xFF9B8ED0);
      case 'love_what_you_want':
        return const Color(0xFFE6D3A3);
      default:
        return LiquidGlassColors.liquidGlassActive(isDark);
    }
  }

  Widget _buildPopularTestCard(QuizTestDefinition test, bool isDark, int index) {
    final gifPath = _getTestGifPath(test);
    final testColor = _getTestColor(test.id, isDark);
    
    return LiquidGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      animationDelayMs: index * 80,
      glowColor: testColor,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GeneralTestScreen(testDefinition: test),
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedQuizTitle(test),
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.getTextPrimary(isDark),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getLocalizedQuizSubtitle(test),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (gifPath != null) ...[
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        testColor.withOpacity(0.3),
                        testColor.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: testColor.withOpacity(0.4),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Gif(
                      image: AssetImage(gifPath),
                      autostart: Autostart.loop,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      placeholder: (context) => Center(
                        child: Text(
                          test.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtherTestCard(QuizTestDefinition test, bool isDark, int index) {
    return LiquidGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      animationDelayMs: 200 + (index * 60),
      blurAmount: 20,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GeneralTestScreen(testDefinition: test),
          ),
        );
      },
      child: Row(
        children: [
          // Emoji icon
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.3),
                      LiquidGlassColors.liquidGlassSecondary(isDark).withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white.withOpacity(0.15) : AppColors.premiumLightTextSecondary.withOpacity(0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    test.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  test.title,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.getTextPrimary(isDark),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  test.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.getTextSecondary(isDark),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedTests(TestProvider testProvider, bool isDark) {
    final completedTests = testProvider.userTests
        .where((test) => test.status == TestStatus.completed)
        .toList();
    final quizTestResults = testProvider.quizTestResults;

    if (completedTests.isEmpty && quizTestResults.isEmpty) {
      return _buildEmptyCompletedState(isDark);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          if (quizTestResults.isNotEmpty) ...[
            _buildSectionHeader(AppStrings.testResults, 0, isDark),
            const SizedBox(height: 16),
            _buildQuizTestResultsList(quizTestResults, isDark),
            if (completedTests.isNotEmpty) const SizedBox(height: 24),
          ],
          if (completedTests.isNotEmpty) ...[
            if (quizTestResults.isNotEmpty)
              _buildSectionHeader(AppStrings.otherTests, 100, isDark),
            if (quizTestResults.isEmpty) const SizedBox(height: 16),
            _buildTestsList(completedTests, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildTestsList(List<TestModel> tests, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return _buildTestCard(test, isDark, index);
      },
    );
  }

  Widget _buildQuizTestResultsList(List<QuizTestResult> results, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildQuizTestResultCard(result, isDark, index);
      },
    );
  }

  Widget _buildQuizTestResultCard(QuizTestResult result, bool isDark, int index) {
    return LiquidGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      animationDelayMs: index * 80,
      glowColor: AppColors.success,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TestResultScreen(result: result),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.3),
                          LiquidGlassColors.liquidGlassSecondary(isDark).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    child: Text(
                      result.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.testTitle,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(result.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.success.withOpacity(0.4),
                          AppColors.success.withOpacity(0.25),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          AppStrings.testCompleted,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Text(
                  () {
                    final cleaned = Helpers.cleanMarkdown(result.resultText);
                    return cleaned.length > 150
                        ? '${cleaned.substring(0, 150)}...'
                        : cleaned;
                  }(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildTestCard(TestModel test, bool isDark, int index) {
    final testColor = _getTestTypeColor(test.type, isDark);
    
    return LiquidGlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      animationDelayMs: index * 80,
      glowColor: testColor,
      onTap: () {
        final testProvider = Provider.of<TestProvider>(context, listen: false);
        if (test.status == TestStatus.completed) {
          try {
            final result = testProvider.quizTestResults.firstWhere(
              (r) => r.testId == test.id || r.testTitle == test.title,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TestResultScreen(result: result),
              ),
            );
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Test result not found for test ${test.id}: $e');
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.isEnglish ? 'Test result not found' : 'Test sonucu bulunamadı'),
              ),
            );
          }
        } else {
          testProvider.setCurrentTest(test);
          final quizTestService = QuizTestService();
          final quizTest = quizTestService.getTestById(_getQuizTestIdFromTest(test));
          if (quizTest != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GeneralTestScreen(testDefinition: quizTest),
              ),
            );
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          testColor.withOpacity(0.4),
                          testColor.withOpacity(0.25),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: testColor.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      _getTestTypeIcon(test.type),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test.title,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      test.getDisplayName(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: testColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (test.isFavorite)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.pink[300],
                        size: 16,
                      ),
                    ),
                  if (test.status == TestStatus.completed) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            test.description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.quiz,
                color: Colors.white.withOpacity(0.5),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${test.questions.length} ${AppStrings.questions}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              if (test.status == TestStatus.completed) ...[
                Icon(
                  Icons.score,
                  color: Colors.white.withOpacity(0.5),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${test.score}%',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ] else if (test.karmaReward > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.karma.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.karma.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.karma,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${test.karmaReward}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.karma,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getQuizTestIdFromTest(TestModel test) {
    switch (test.type) {
      case TestType.personality:
        return 'personality';
      case TestType.love:
        return 'love';
      case TestType.friendship:
        return 'friendship';
      case TestType.compatibility:
        return 'compatibility';
      default:
        return 'personality';
    }
  }

  Widget _buildEmptyCompletedState(bool isDark) {
    return Center(
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.3),
                    LiquidGlassColors.liquidGlassSecondary(isDark).withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.noCompletedTests,
              style: AppTextStyles.headingMedium.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.completeFirstTest,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
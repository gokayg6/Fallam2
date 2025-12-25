import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'fortune_result_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/models/fortune_model.dart' as fm;
import '../../core/models/fortune_type.dart';
import '../../core/services/fortune_service.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/services/ads_service.dart';
import '../../widgets/fortune/karma_cost_badge.dart';
import '../../core/widgets/liquid_glass_navbar.dart';
import '../../core/widgets/liquid_glass_widgets.dart';
import '../../core/widgets/mystical_button.dart';
import '../../providers/theme_provider.dart';
import 'dart:async';

class DreamInterpretationScreen extends StatefulWidget {
  const DreamInterpretationScreen({Key? key}) : super(key: key);

  @override
  State<DreamInterpretationScreen> createState() => _DreamInterpretationScreenState();
}

class _DreamInterpretationScreenState extends State<DreamInterpretationScreen> {
  final FortuneService _fortuneService = FortuneService();
  final AdsService _ads = AdsService();
  final TextEditingController _controller = TextEditingController();

  bool _canGenerate = false;

  Future<void> _generate() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      MysticLoading.show(context);
      final result = await _fortuneService.generateFortune(
        type: FortuneType.dream,
        inputData: {
          'dreamDescription': text,
        },
      );

      final fm.FortuneModel adapted = fm.FortuneModel(
        id: result.id,
        userId: result.userId,
        type: fm.FortuneType.dream,
        status: fm.FortuneStatus.completed,
        title: result.title,
        interpretation: result.interpretation,
        inputData: const {},
        selectedCards: result.selectedCards,
        imageUrls: result.imageUrls,
        question: result.question,
        createdAt: result.createdAt,
        completedAt: result.createdAt,
        isFavorite: result.isFavorite,
        rating: result.rating.toInt(),
        notes: null,
        isForSelf: true,
        targetPersonName: null,
        metadata: result.metadata,
        karmaUsed: 0,
        isPremium: false,
      );

      if (!mounted) return;
      await MysticLoading.hide(context);

      // Show interstitial after sending fortune
      try {
        final loaded = Completer<bool>();
        await _ads.createInterstitialAd(
          adUnitId: _ads.interstitialAdUnitId,
          onAdLoaded: (_) => loaded.complete(true),
          onAdFailedToLoad: (_) => loaded.complete(false),
        );
        bool ok = false;
        try { 
          ok = await loaded.future.timeout(const Duration(seconds: 2)); 
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Interstitial ad load timeout or error: $e');
          }
        }
        if (ok) { await _ads.showInterstitialAd(); }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error showing interstitial ad: $e');
        }
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FortuneResultScreen(fortune: adapted),
        ),
      );
    } catch (e) {
      await MysticLoading.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.fortuneCreationError}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: themeProvider.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildIntroCard(),
                      const SizedBox(height: 16),
                      _buildInputCard(),
                    ],
                  ),
                ),
              ),
              _buildGenerateBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = Colors.white;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LiquidGlassCard(
        borderRadius: 20,
        blurAmount: 15,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.dreamInterpretation,
                style: AppTextStyles.headingLarge.copyWith(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            const KarmaCostBadge(fortuneType: 'dream'),
            const SizedBox(width: 12),
            const Text('🌙', style: TextStyle(fontSize: 20)),
             const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return LiquidGlassCard(
          padding: const EdgeInsets.all(24),
          blurAmount: 15,
           glowColor: const Color(0xFFFFD700).withOpacity(0.3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFD700).withOpacity(0.15),
                  boxShadow: [
                     BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text('🌙', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.tellYourDream,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputCard() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final inputHintColor = Colors.white54;
        
        return LiquidGlassCard(
          padding: const EdgeInsets.all(20),
          blurAmount: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.yourDream,
                style: AppTextStyles.headingSmall.copyWith(
                  color: const Color(0xFFFFD700), // Gold
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 100,
                  maxHeight: 220,
                ),
                child: Scrollbar(
                  child: TextField(
                    controller: _controller,
                    onChanged: (v) => setState(() => _canGenerate = v.trim().isNotEmpty),
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: AppStrings.dreamExampleHint,
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: inputHintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.2),
                    ),
                    maxLines: null,
                    minLines: 5,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenerateBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: MysticalButton(
          text: _canGenerate ? AppStrings.createInterpretation : AppStrings.writeYourDream,
          onPressed: _canGenerate ? _generate : null,
          showGlow: _canGenerate,
           customGradient: _canGenerate 
              ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)]) 
              : null,
          customTextStyle: AppTextStyles.buttonLarge.copyWith(
             color: _canGenerate ? Colors.white : Colors.white38,
             fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

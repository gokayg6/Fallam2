import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/pricing_constants.dart';
import '../../core/providers/user_provider.dart';
import '../../providers/theme_provider.dart';

import '../../core/widgets/liquid_glass_widgets.dart'; // Import Liquid Glass Widgets
import '../../core/widgets/mystical_loading.dart'; // Keep for loading state if needed, or replace with glass loading
import 'tarot_fortune_screen.dart';
import 'coffee_fortune_screen.dart';
import 'palm_fortune_screen.dart';
import '../astrology/astrology_screen.dart';
import 'face_fortune_screen.dart';
import 'katina_fortune_screen.dart';
import 'dream_interpretation_screen.dart';

enum FortuneTarget {
  myself,
  someone,
}

class FortuneSelectionScreen extends StatefulWidget {
  const FortuneSelectionScreen({Key? key}) : super(key: key);

  @override
  State<FortuneSelectionScreen> createState() => _FortuneSelectionScreenState();
}

class _FortuneSelectionScreenState extends State<FortuneSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  
  FortuneTarget _selectedTarget = FortuneTarget.myself;
  String? _selectedFortuneType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    _backgroundController.repeat(reverse: true);
  }

  void _selectFortuneType(String fortuneType) {
    setState(() {
      _selectedFortuneType = fortuneType;
    });
  }

  void _startFortune() async {
    if (_selectedFortuneType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.selectFortuneType),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Get the required karma for selected fortune type
    final requiredKarma = PricingConstants.getFortuneCost(_selectedFortuneType!);
    
    // Debug modunda karma kontrolü bypass
    if (!kDebugMode) {
      // Check if user has enough karma or daily fortune available
      if (!(userProvider.user?.canUseDailyFortune ?? false) && (userProvider.user?.karma ?? 0) < requiredKarma) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.notEnoughKarma}. Gerekli: $requiredKarma karma'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Navigate to specific fortune screen based on selection
      Widget fortuneScreen;
      switch (_selectedFortuneType) {
        case 'tarot':
          fortuneScreen = const TarotFortuneScreen();
          break;
        case 'coffee':
          fortuneScreen = const CoffeeFortuneScreen();
          break;
        case 'palm':
          fortuneScreen = const PalmFortuneScreen();
          break;
        case 'astrology':
          fortuneScreen = const AstrologyScreen();
          break;
        case 'face':
          fortuneScreen = const FaceFortuneScreen();
          break;
        case 'katina':
          fortuneScreen = const KatinaFortuneScreen();
          break;
        case 'dream':
          fortuneScreen = const DreamInterpretationScreen();
          break;
        default:
          throw Exception('Unknown fortune type: $_selectedFortuneType');
      }

      await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => fortuneScreen,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.error}: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(),
          body: LiquidGlassScreenWrapper(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2A2438), // Deep purple base
                    Color(0xFF15121E), // Darker purple/black
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Animated background elements could go here
                  Positioned(
                    top: -100,
                    right: -50,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFF9D4EDD).withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  SafeArea(
                    child: _isLoading
                        ? _buildLoadingState()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                _buildHeader(),
                                const SizedBox(height: 30),
                                _buildTargetSelection(),
                                const SizedBox(height: 30),
                                Text(
                                  AppStrings.fortuneTypes,
                                  style: AppTextStyles.headingSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 22,
                                    shadows: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildFortuneTypeGrid(),
                                const SizedBox(height: 40),
                                _buildStartButton(),
                                const SizedBox(height: 100), // Bottom padding
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        AppStrings.selectFortune,
        style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildLoadingState() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MysticalLoadingWidget.stars(
            size: 80,
            color: LiquidGlassColors.glassGlow(isDark),
            message: AppStrings.preparingFortune,
            showMessage: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    return LiquidGlassCard(
      borderRadius: 24,
      enableShimmer: true,
      glowColor: LiquidGlassColors.glassGlow(isDark),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 32,
              color: LiquidGlassColors.glassGlow(isDark),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.chooseYourPath,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.selectFortuneDesc,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.fortuneFor,
          style: AppTextStyles.headingSmall.copyWith(
            color: Colors.white,
            fontSize: 22,
            shadows: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTargetCard(
                target: FortuneTarget.myself,
                title: AppStrings.forMyself,
                // subtitle: AppStrings.forMyselfDesc,
                icon: Icons.person_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTargetCard(
                target: FortuneTarget.someone,
                title: AppStrings.forSomeoneElse,
                // subtitle: AppStrings.forSomeoneDesc,
                icon: Icons.people_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetCard({
    required FortuneTarget target,
    required String title,
    // required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedTarget == target;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return LiquidGlassCard(
      onTap: () {
        setState(() {
          _selectedTarget = target;
        });
      },
      isSelected: isSelected,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      borderRadius: 20,
      glowColor: LiquidGlassColors.activeGlow(isDark),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: isSelected ? Colors.white : Colors.white60,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneTypeGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildFortuneTypeCard(
          type: 'tarot',
          title: AppStrings.tarot,
          subtitle: AppStrings.tarotDesc,
          icon: Icons.style,
          delay: 0,
        ),
        _buildFortuneTypeCard(
          type: 'coffee',
          title: AppStrings.coffee,
          subtitle: AppStrings.coffeeDesc,
          icon: Icons.coffee,
          delay: 100,
        ),
        _buildAstrologyCard(delay: 200), // Custom Astrology Card
        _buildFortuneTypeCard(
          type: 'palm',
          title: AppStrings.palm,
          subtitle: AppStrings.palmDesc,
          icon: Icons.pan_tool,
          delay: 300,
        ),
        _buildFortuneTypeCard(
          type: 'face',
          title: AppStrings.faceFortune,
          subtitle: AppStrings.faceDesc,
          icon: Icons.face_retouching_natural,
          delay: 400,
        ),
        _buildFortuneTypeCard(
          type: 'katina',
          title: AppStrings.katinaFortune,
          subtitle: AppStrings.katinaDesc,
          icon: Icons.favorite, // Changed to hearts for Katina
          delay: 500,
        ),
         _buildFortuneTypeCard(
          type: 'dream',
          title: AppStrings.dreamInterpretation,
          subtitle: AppStrings.dreamDesc,
          icon: Icons.bedtime_outlined,
          delay: 600,
        ),
      ],
    );
  }

  // Specialized card for Astrology
  Widget _buildAstrologyCard({required int delay}) {
    final isSelected = _selectedFortuneType == 'astrology';
    
    return LiquidGlassCard(
      onTap: () => _selectFortuneType('astrology'),
      isSelected: isSelected,
      animationDelayMs: delay,
      padding: EdgeInsets.zero,
      glowColor: Color(0xFF9D4EDD), // Deep purple glow
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          // Subtle radial gradient for "space" feel
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF9D4EDD).withValues(alpha: 0.15),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Custom Astrology Icon/Graphic
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Icon(
                    Icons.star_outline_rounded,
                    size: 40,
                    color: isSelected ? Colors.white : Color(0xFFE0AAFF),
                  ),
                  // Inner star
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.astrology,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "Yıldız Haritası Analizi", // Custom description for Astrology
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white70,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFortuneTypeCard({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
    required int delay,
  }) {
    final isSelected = _selectedFortuneType == type;
    
    return LiquidGlassCard(
      onTap: () => _selectFortuneType(type),
      isSelected: isSelected,
      animationDelayMs: delay,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected 
                  ? Colors.white.withValues(alpha: 0.2) 
                  : Colors.white.withValues(alpha: 0.05),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white60,
              fontSize: 11,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Get required karma for selected fortune type
        final requiredKarma = _selectedFortuneType != null 
            ? PricingConstants.getFortuneCost(_selectedFortuneType!)
            : 10;
        
        // Debug modunda premium özellikleri ücretsiz
        final canUseFortune = kDebugMode || 
                             (userProvider.user?.canUseDailyFortune ?? false) || 
                             (userProvider.user?.karma ?? 0) >= requiredKarma;
        
        return Column(
          children: [
            if (!(userProvider.user?.canUseDailyFortune ?? false) && _selectedFortuneType != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: LiquidGlassColors.glassGlow(isDark),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${AppStrings.karmaRequired}: $requiredKarma ${AppStrings.karma}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
            LiquidGlassButton(
              text: _selectedFortuneType == null 
                  ? AppStrings.selectFortuneType 
                  : _startFortuneButtonText(),
              onPressed: canUseFortune && _selectedFortuneType != null 
                  ? _startFortune 
                  : null,
              isPrimary: canUseFortune && _selectedFortuneType != null,
              isLoading: _isLoading,
              width: double.infinity,
              height: 60,
              color: LiquidGlassColors.activeGlow(isDark),
              icon: Icons.arrow_forward,
            ),
          ],
        );
      },
    );
  }
  
  String _startFortuneButtonText() {
    return AppStrings.startFortune;
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }
}
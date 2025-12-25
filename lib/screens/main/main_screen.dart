import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/fortune_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/mystical_button.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/widgets/liquid_glass_navbar.dart';
import '../../core/widgets/liquid_glass_widgets.dart'; // Add this line
import '../../core/services/ads_service.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../core/services/ai_service.dart';
import '../../core/constants/pricing_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../fortune/fortune_selection_screen.dart';
import '../profile/profile_screen.dart';
import '../history/fortunes_history_screen.dart';
import '../premium/premium_screen.dart';
import '../fortune/coffee_fortune_screen.dart';
import '../social/love_compatibility_screen.dart';
import '../social/soulmate_analysis_screen.dart';
import '../other/biorhythm_screen.dart';
import '../social/live_chat_screen.dart';
import '../fortune/dream_interpretation_screen.dart';
import '../fortune/dream_draw_screen.dart';
import '../fortune/dream_dictionary_screen.dart';
import '../fortune/tarot_fortune_screen.dart';
import '../fortune/palm_fortune_screen.dart';
import '../premium/karma_purchase_screen.dart';
import '../fortune/katina_fortune_screen.dart';
import '../fortune/face_fortune_screen.dart';
import '../astrology/astrology_screen.dart';
import '../premium/spin_wheel_screen.dart';
import '../astrology/horoscope_detail_screen.dart';

import '../other/aura_update_screen.dart';
import '../other/tests_screen.dart';


import '../social/social_screen.dart';
import '../../core/widgets/confetti_animation.dart';
import '../../core/services/firebase_service.dart';
import '../../core/models/love_candidate_model.dart';
import '../social/love_candidate_form_screen.dart';
import '../social/love_compatibility_result_screen.dart';
import '../social/love_candidates_screen.dart';
import '../../core/utils/helpers.dart';
// coins screen used in karma section navigation
// import removed: coins screen not used here

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin, RouteAware {
  late AnimationController _backgroundController;
  late AnimationController _cardController;
  final AdsService _adsService = AdsService();
  final AIService _aiService = AIService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, String> _horoscopes = {};
  bool _loadingHoroscopes = false;
  String? _pendingHistoryFilter;
  
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  int _pendingRequestsCount = 0;
  StreamSubscription<QuerySnapshot>? _pendingRequestsSubscription;
  String? _lastLanguageCode;
  bool _showDailyReward = false;
  bool _showConfetti = false;
  int _currentStreak = 0;
  int _todayKarmaReward = 0;
  final FirebaseService _firebaseService = FirebaseService();
  List<String> _completedQuests = [];
  
  // State for Background Focus/Zoom Effect
  bool _isContentFocused = false;
  
  // Missing fields for features
  List<LoveCandidateModel> _loveCandidates = [];
  bool _loadingLoveCandidates = false;
  bool _loadingQuests = false;
  
  bool get _isEnglish {
    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      return languageProvider.isEnglish;
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleDeepNavigation(Widget page) async {
    setState(() => _isContentFocused = true);
    
    // Push the route (opaque: false is crucial)
    await Navigator.push(context, ZoomBlurPageRoute(page: page));
    
    // When returning, we 'Focus In' (Zoom In)
    if (mounted) {
      setState(() => _isContentFocused = false);
    }
  }

  DateTime? _lastQuestLoadTime;
  bool _isFortuneExpanded = true;
  bool _hasCheckedPremium = false;


  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
    _loadHoroscopes();
    // _loadPendingRequestsCount();
    // _startPendingRequestsListener();
    _loadLoveCandidates();
    // Initialize language code and check daily reward
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      _lastLanguageCode = languageProvider.languageCode;
      // Check daily reward on page load
      await _checkDailyRewardAvailability();
      _checkPremiumStatus();
    });
  }

  Future<void> _checkPremiumStatus() async {
    if (_hasCheckedPremium) return;
    _hasCheckedPremium = true;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isPremium) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PremiumScreen()),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check daily reward when dependencies change (e.g., user login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyRewardAvailability();
      _loadQuests();
    });
  }

  Future<void> _loadQuests() async {
    if (_loadingQuests) return;
    setState(() => _loadingQuests = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;
      if (userId == null) {
        setState(() {
          _completedQuests = [];
          _loadingQuests = false;
        });
        return;
      }

      final completed = await _firebaseService.getCompletedQuests(userId);
      if (mounted) {
        setState(() {
          _completedQuests = completed;
          _loadingQuests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _completedQuests = [];
          _loadingQuests = false;
        });
      }
    }
  }

  Future<void> _loadLoveCandidates() async {
    if (_loadingLoveCandidates) return;
    setState(() => _loadingLoveCandidates = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;
      if (userId == null) {
        setState(() {
          _loveCandidates = [];
          _loadingLoveCandidates = false;
        });
        return;
      }

      final candidates = await _firebaseService.getLoveCandidates(userId);
      if (mounted) {
        setState(() {
          _loveCandidates = candidates;
          _loadingLoveCandidates = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loveCandidates = [];
          _loadingLoveCandidates = false;
        });
      }
    }
  }

  void _initializeAnimations() {
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Removed repeat animation to prevent blinking
    _backgroundController.forward();
    _cardController.forward();
  }


  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final fortuneProvider = Provider.of<FortuneProvider>(context, listen: false);
      
      // Check if daily reward is available
      await _checkDailyRewardAvailability();
      
      final uid = userProvider.user?.id;
      if (uid != null && uid.isNotEmpty) {
        fortuneProvider.loadUserFortunes(uid);
      }
      fortuneProvider.loadTarotCards();
      fortuneProvider.loadFortuneTellers();
    });
  }

  Future<void> _checkDailyRewardAvailability() async {
    if (!mounted) return;
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;
      if (userId == null) {
        setState(() {
          _showDailyReward = false;
          _currentStreak = 0;
          _todayKarmaReward = 0;
        });
        return;
      }

      final hasLoggedToday = await _firebaseService.checkDailyLogin(userId);
      if (hasLoggedToday) {
        setState(() {
          _showDailyReward = false;
          _currentStreak = 0;
          _todayKarmaReward = 0;
        });
        return;
      }

      // Get streak and reward info
      // getLoginStreak returns the next streak if user hasn't logged in today
      // If last login was yesterday, it returns currentStreak + 1
      // If streak is broken, it returns 1
      // If never logged in, it returns 0
      final nextStreak = await _firebaseService.getLoginStreak(userId);
      
      // If nextStreak is 0, user has never logged in - show reward for day 1
      final streakDay = nextStreak > 0 ? nextStreak : 1;
      final reward = PricingConstants.getDailyLoginReward(streakDay);
      
      if (reward != null) {
        setState(() {
          _showDailyReward = true;
          // Display current streak (before claiming today's reward)
          _currentStreak = streakDay - 1;
          _todayKarmaReward = reward['karma'] as int;
        });
      } else {
        setState(() {
          _showDailyReward = false;
          _currentStreak = 0;
          _todayKarmaReward = 0;
        });
      }
    } catch (e) {
      setState(() {
        _showDailyReward = false;
        _currentStreak = 0;
        _todayKarmaReward = 0;
      });
    }
  }

  Future<void> _loadHoroscopes() async {
    if (_loadingHoroscopes) return;
    
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final isEnglish = _isEnglish;
    
    final signs = ['Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak', 'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık'];
    
    // Önce cache'den oku ve göster (hızlı yükleme)
    try {
      final docRef = _firestore.collection('horoscopes').doc(dateKey);
      final doc = await docRef.get();

      Map<String, dynamic> shorts = {};
      bool needsGeneration = false;

      if (doc.exists) {
        final data = doc.data() ?? {};
        final shortKey = isEnglish ? 'shorts_en' : 'shorts';
        shorts = Map<String, dynamic>.from(data[shortKey] ?? {});
        
        // Check if all signs have data
        for (final sign in signs) {
          if (shorts[sign] == null || shorts[sign].toString().isEmpty) {
            needsGeneration = true;
            break;
          }
        }
      } else {
        needsGeneration = true;
      }

      // Önce cache'den gelen veriyi göster
      final cachedHoroscopes = <String, String>{};
      for (final sign in signs) {
        final shortVal = shorts[sign]?.toString();
        if (shortVal != null && shortVal.isNotEmpty) {
          cachedHoroscopes[sign] = shortVal;
        } else {
          cachedHoroscopes[sign] = _getDefaultHoroscope(sign);
        }
      }
      
      // Cache'den gelen veriyi hemen göster
      if (mounted && cachedHoroscopes.isNotEmpty) {
        setState(() {
          _horoscopes = cachedHoroscopes;
          _loadingHoroscopes = false;
        });
      }

      // Eğer veri eksikse, arka planda generate et (API tasarrufu)
      if (needsGeneration) {
        setState(() => _loadingHoroscopes = true);
        
        // Use Firestore transaction to ensure only one user generates
        try {
          await _firestore.runTransaction((transaction) async {
            final freshDoc = await transaction.get(docRef);
            final freshData = freshDoc.data();
            final textKey = isEnglish ? 'texts_en' : 'texts';
            final shortKey = isEnglish ? 'shorts_en' : 'shorts';
            
            Map<String, dynamic> freshTexts = {};
            Map<String, dynamic> freshShorts = {};
            
            if (freshData != null) {
              freshTexts = Map<String, dynamic>.from(freshData[textKey] ?? {});
              freshShorts = Map<String, dynamic>.from(freshData[shortKey] ?? {});
            }
            
            // Check if still needs generation
            bool stillNeedsGen = false;
            for (final sign in signs) {
              if (freshShorts[sign] == null || freshShorts[sign].toString().isEmpty) {
                stillNeedsGen = true;
                break;
              }
            }
            
            if (stillNeedsGen) {
              // Generate missing horoscopes
              for (final sign in signs) {
                if (freshShorts[sign] == null || freshShorts[sign].toString().isEmpty) {
                  final aiSign = isEnglish ? _mapTurkishSignToEnglish(sign) : sign;
                  final fullVal = await _aiService.generateDailyHoroscope(
                    zodiacSign: aiSign,
                    date: today,
                    english: isEnglish,
                  );
                  final shortVal = _summarizeShort(fullVal);
                  freshTexts[sign] = fullVal;
                  freshShorts[sign] = shortVal;
                }
              }
              
              // Update Firestore
              transaction.set(docRef, {
                'date': dateKey,
                textKey: freshTexts,
                shortKey: freshShorts,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            }
            
            shorts = freshShorts;
          });
          
          // Generate edilen veriyi güncelle
          final updatedHoroscopes = <String, String>{};
          for (final sign in signs) {
            final shortVal = shorts[sign]?.toString();
            if (shortVal != null && shortVal.isNotEmpty) {
              updatedHoroscopes[sign] = shortVal;
            } else {
              updatedHoroscopes[sign] = _getDefaultHoroscope(sign);
            }
          }
          
          if (mounted) {
            setState(() {
              _horoscopes = updatedHoroscopes;
              _loadingHoroscopes = false;
            });
          }
        } catch (e) {
          // If transaction fails, keep cached data
          if (mounted) {
            setState(() {
              _loadingHoroscopes = false;
            });
          }
        }
      }
    } catch (e) {
      // Fallback
      final fallbackHoroscopes = <String, String>{};
      for (final sign in signs) {
        fallbackHoroscopes[sign] = _getDefaultHoroscope(sign);
      }
      if (mounted) {
        setState(() {
          _horoscopes = fallbackHoroscopes;
          _loadingHoroscopes = false;
        });
      }
    }
  }
  
  String _summarizeShort(String text) {
    var t = text.trim();
    // Remove persona intro if present
    final introIdx = t.toLowerCase().indexOf('merhaba, ben falla');
    if (introIdx == 0) {
      // Drop first sentence
      final dot = t.indexOf('.');
      if (dot != -1 && dot + 1 < t.length) t = t.substring(dot + 1).trim();
    }
    // Take first sentence up to 90 chars
    final endIdx = t.indexOf('.') != -1 ? t.indexOf('.') + 1 : (t.length);
    var s = t.substring(0, endIdx).trim();
    if (s.length > 90) s = s.substring(0, 90).trimRight() + '…';
    return s;
  }

  String _mapTurkishSignToEnglish(String sign) {
    switch (sign) {
      case 'Koç':
        return 'Aries';
      case 'Boğa':
        return 'Taurus';
      case 'İkizler':
        return 'Gemini';
      case 'Yengeç':
        return 'Cancer';
      case 'Aslan':
        return 'Leo';
      case 'Başak':
        return 'Virgo';
      case 'Terazi':
        return 'Libra';
      case 'Akrep':
        return 'Scorpio';
      case 'Yay':
        return 'Sagittarius';
      case 'Oğlak':
        return 'Capricorn';
      case 'Kova':
        return 'Aquarius';
      case 'Balık':
        return 'Pisces';
      default:
        return sign;
    }
  }

  String _getDefaultHoroscope(String sign) {
    if (_isEnglish) {
      final defaults = {
        'Aries': 'An energetic and courageous day.',
        'Taurus': 'Stay balanced, be patient.',
        'Gemini': 'Social relationships are in the foreground.',
        'Cancer': 'Listen to your emotions.',
        'Leo': 'Time to show yourself.',
        'Virgo': 'Pay attention to details.',
        'Libra': 'Harmony and balance are in the foreground.',
        'Scorpio': 'Deep feelings and intuition.',
        'Sagittarius': 'Adventure awaits you.',
        'Capricorn': 'Focus on your goals.',
        'Aquarius': 'Be open to innovations.',
        'Pisces': 'Use your imagination.',
      };
      return defaults[sign] ?? AppStrings.starsSpeakingToday;
    } else {
    final defaults = {
      'Koç': 'Enerjik ve cesur bir gün.',
      'Boğa': 'Dengede kal, sabırlı ol.',
      'İkizler': 'Sosyal ilişkiler önde.',
      'Yengeç': 'Duygularına kulak ver.',
      'Aslan': 'Kendini gösterme zamanı.',
      'Başak': 'Detaylara dikkat et.',
      'Terazi': 'Uyum ve denge ön planda.',
      'Akrep': 'Derin hisler ve sezgi.',
      'Yay': 'Macera seni bekliyor.',
      'Oğlak': 'Hedeflerine odaklan.',
      'Kova': 'Yeniliklere açık ol.',
      'Balık': 'Hayal gücünü kullan.',
    };
      return defaults[sign] ?? AppStrings.starsSpeakingToday;
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  // Key for background capture shader
  final GlobalKey _backgroundKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // Listen to LanguageProvider to trigger rebuilds on language change
    Provider.of<LanguageProvider>(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          extendBody: true,
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: themeProvider.backgroundGradient,
                ),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    if (index == 0) {
                      _loadQuests();
                    }
                  },
                  children: [
                    _buildHomeTab(),
                    _buildFortunesHistoryTab(),
                    const TestsScreen(),
                    const SocialScreen(),
                    const ProfileScreen(),
                  ],
                ),
              ),
              if (_showConfetti)
                ConfettiAnimation(
                  onComplete: () {
                    setState(() {
                      _showConfetti = false;
                    });
                  },
                ),
              LiquidGlassNavbar(
                currentIndex: _selectedIndex,
                onTap: _onBottomNavTap,
                items: [
                  const NavbarItem(icon: Icons.home_rounded, label: 'Ana Sayfa'),
                  const NavbarItem(icon: Icons.history_rounded, label: 'Geçmiş'),
                  const NavbarItem(icon: Icons.quiz_rounded, label: 'Testler'),
                  const NavbarItem(icon: Icons.favorite_rounded, label: 'Sosyal'),
                  const NavbarItem(icon: Icons.person_rounded, label: 'Profil'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeTab() {
    // Reload quests when home tab is built (user might have completed a quest)
    // But only if it's been more than 2 seconds since last load to avoid excessive calls
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedIndex == 0) {
        final now = DateTime.now();
        if (_lastQuestLoadTime == null || 
            now.difference(_lastQuestLoadTime!).inSeconds > 2) {
          _lastQuestLoadTime = now;
          _loadQuests();
        }
      }
    });
    
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(),
                const SizedBox(height: 16),
                if (_showDailyReward) ...[
                  _buildDailyRewardCard(),
                  const SizedBox(height: 16),
                ],
                _buildQuestsCard(),
                const SizedBox(height: 16),
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                _FalGridHome(onNavigate: _handleDeepNavigation),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  switch (index) {
                    case 0: return const SizedBox(height: 24);
                    case 1: return _buildHoroscopeSection();
                    case 2: return const SizedBox(height: 32);
                    case 3: return _buildLoveCompatibilitySection();
                    case 4: return const SizedBox(height: 32);
                    case 5: return _buildDreamSection();
                    case 6: return const SizedBox(height: 32);
                    case 7: return _buildBiorhythmSection();
                    case 8: return const SizedBox(height: 32);
                    case 9: return _buildKarmaSection();
                    case 10: return const SizedBox(height: 32);
                    case 11: return _buildOtherFeatures();
                    case 12: return const SizedBox(height: 24);
                    case 13: return const BannerAdWidget(margin: EdgeInsets.symmetric(vertical: 8));
                    case 14: return const SizedBox(height: 100);
                    default: return null;
                  }
                },
                childCount: 15,
                addAutomaticKeepAlives: false, // Critical for memory: destroy off-screen items
                addRepaintBoundaries: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer2<UserProvider, ThemeProvider>(
      builder: (context, userProvider, themeProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/fallalogo.png',
                    width: 36,
                    height: 36,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userProvider.user?.name ?? AppStrings.welcome,
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(themeProvider.isDarkMode),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          userProvider.user?.name != null 
                              ? AppStrings.welcomeBack 
                              : AppStrings.guest,
                          style: TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.getTextSecondary(themeProvider.isDarkMode),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildKarmaDisplay(userProvider.user?.karma ?? 0),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PremiumScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.12),
                              Colors.white.withValues(alpha: 0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          color: AppColors.champagneGold,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? textColor, Color? textSecondaryColor]) {
    final primaryColor = textColor ?? Colors.white;
    final secondaryColor = textSecondaryColor ?? Colors.white70;
    
    return Row(
      children: [
        Text(
          '• $label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: secondaryColor,
          ),
        ),
        Expanded(
          child: Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildKarmaDisplay(int karma) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const KarmaPurchaseScreen(),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.champagneGoldGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.champagneGold.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 22,
                  width: 22,
                  child: Image.asset('assets/karma/karma.png', fit: BoxFit.contain),
                ),
                const SizedBox(width: 6),
                Text(
                  karma.toString(),
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.premiumDarkBg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyRewardCard() {
    if (!_showDailyReward) return const SizedBox();

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isDark 
                  ? LinearGradient(
                      colors: [
                        const Color(0xFFFFD700).withValues(alpha: 0.15),
                        const Color(0xFFFFA500).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.champagneGold.withOpacity(0.2),
                        AppColors.champagneGold.withOpacity(0.1),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFFFFD700).withValues(alpha: 0.3) : AppColors.champagneGold.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.champagneGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🎁', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.dailyGift,
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                      Text(
                        AppStrings.dailyGiftDesc,
                        style: TextStyle(
                          fontSize: 13, 
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _claimDailyReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.champagneGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(AppStrings.claim),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _claimDailyReward() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.pleaseLoginFirst),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final hasLoggedToday = await _firebaseService.checkDailyLogin(userId);
      if (hasLoggedToday) {
        setState(() => _showDailyReward = false);
        return;
      }

      // Record login and update streak
      await _firebaseService.recordDailyLogin(userId);
      final currentStreak = await _firebaseService.getLoginStreak(userId);
      final newStreak = currentStreak + 1;
      await _firebaseService.updateLoginStreak(userId, newStreak);

      // Get reward
      final reward = PricingConstants.getDailyLoginReward(newStreak);
      if (reward != null) {
        final karmaAmount = reward['karma'] as int;
        await userProvider.addKarma(
          karmaAmount,
          'Günlük giriş ödülü (Gün $newStreak)',
        );

        // Show confetti and hide card
        if (mounted) {
          setState(() {
            _showConfetti = true;
            _showDailyReward = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildQuestsCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dailyQuests,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2, // Örnek görevler
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      index == 0 ? Icons.coffee_rounded : Icons.star_rounded,
                      color: AppColors.champagneGold, 
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            index == 0 ? 'Bugün bir Kahve Falı baktır' : '5 yıldız ver',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.getTextPrimary(isDark),
                            ),
                          ),
                          Text(
                            '+50 Karma',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.champagneGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white30 : Colors.black26,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 30),
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: themeProvider.isDarkMode 
                        ? AppColors.premiumHeroCardDecoration
                        : AppColors.ios26LightSelectedCardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.champagneGold.withValues(alpha: 0.3),
                                    AppColors.subtleBronze.withValues(alpha: 0.15),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.champagneGold.withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.auto_awesome,
                                  size: 24,
                                  color: AppColors.champagneGold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.dailyFortune,
                                    style: TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.getTextPrimary(isDark),
                                    ),
                                  ),
                                  if (!_isFortuneExpanded)
                                  Text(
                                    AppStrings.tapToSeeDetails,
                                    style: TextStyle(
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 13,
                                      color: AppColors.getTextSecondary(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _isFortuneExpanded = !_isFortuneExpanded;
                                });
                              },
                              icon: Icon(
                                _isFortuneExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ),
                        
                        if (_isFortuneExpanded) ...[
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.dailyFortuneDesc,
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.getTextSecondary(isDark),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _GlassCTAButton(
                            text: AppStrings.startFortune,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FortuneSelectionScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Removed legacy fortune types section
  // Widget _buildFortuneTypes() {}

  // Removed legacy fortune type card

  Widget _buildDreamSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.dreamArea,
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(themeProvider.isDarkMode),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGlassDreamCard(
                title: AppStrings.isEnglish ? 'Dream Dictionary' : 'Rüya Sözlüğü',
                icon: Icons.menu_book_outlined,
                iconColor: AppColors.champagneGold,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const DreamDictionaryScreen(),
                )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGlassDreamCard(
                title: AppStrings.drawMyDream,
                icon: Icons.brush_outlined,
                iconColor: AppColors.subtleBronze,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const DreamDrawScreen(),
                )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGlassDreamCard(
                title: AppStrings.interpretDream,
                icon: Icons.auto_awesome_outlined,
                iconColor: themeProvider.isDarkMode ? AppColors.warmIvory : AppColors.getTextPrimary(false),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const DreamInterpretationScreen(),
                )),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassDreamCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return _GlassFeatureCard(
      title: title,
      icon: icon,
      iconColor: iconColor,
      onTap: onTap,
    );
  }

  Widget _buildLoveCompatibilitySection() {
    return Consumer2<ThemeProvider, UserProvider>(
      builder: (context, themeProvider, userProvider, child) {
        if (_loadingLoveCandidates) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.12) : AppColors.premiumLightSurface.withValues(alpha: 0.9),
                      themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.premiumLightSurface.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: MysticalLoading(
                    type: MysticalLoadingType.spinner,
                    size: 32,
                    color: const Color(0xFFFF6B9D),
                  ),
                ),
              ),
            ),
          );
        }
        
        final hasCandidates = _loveCandidates.isNotEmpty;
        final firstCandidate = hasCandidates ? _loveCandidates.first : null;
        
        return RepaintBoundary(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.14) : AppColors.premiumLightSurface,
                      themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.06) : AppColors.premiumLightSurface.withValues(alpha: 0.9),
                      themeProvider.isDarkMode ? const Color(0xFFFF6B9D).withValues(alpha: 0.08) : AppColors.premiumLightSurface.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    width: 1.5,
                    color: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.4),
                        const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                      ],
                    ).colors.first,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B9D).withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: -5,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFFFF6B9D).withValues(alpha: 0.25),
                                  const Color(0xFFFF8FB1).withValues(alpha: 0.15),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFFFF6B9D).withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '💕',
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.loveCandidate,
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.getTextPrimary(themeProvider.isDarkMode),
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isEnglish ? 'AI-powered love analysis' : 'Yapay zeka destekli aşk analizi',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 13,
                                    color: AppColors.getTextSecondary(themeProvider.isDarkMode),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: hasCandidates && firstCandidate != null
                          ? _buildLiquidGlassCandidateCard(firstCandidate)
                          : _buildEmptyCandidateState(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await _handleDeepNavigation(const LoveCandidateFormScreen());
                              _loadLoveCandidates();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFF6B9D).withValues(alpha: 0.35),
                                        const Color(0xFFFF8FB1).withValues(alpha: 0.25),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFFF6B9D).withValues(alpha: 0.5),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF6B9D).withValues(alpha: 0.25),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        AppStrings.addNewCandidate,
                                        style: TextStyle(
                                          fontFamily: 'SF Pro Display',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          if (hasCandidates) ...[
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                _handleDeepNavigation(const LoveCandidatesScreen());
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.1) : AppColors.premiumLightTextSecondary.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.viewAllCandidates,
                                      style: TextStyle(
                                        fontFamily: 'SF Pro Text',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.8) : AppColors.getTextSecondary(false),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.8) : AppColors.getTextSecondary(false),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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
  
  Widget _buildLiquidGlassCandidateCard(LoveCandidateModel candidate) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoveCompatibilityResultScreen(
              candidate: candidate,
            ),
          ),
        ).then((_) => _loadLoveCandidates());
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.12) : AppColors.premiumLightSurface,
                  themeProvider.isDarkMode ? const Color(0xFFFF6B9D).withValues(alpha: 0.08) : AppColors.premiumLightSurface.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFF6B9D).withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with Liquid Glass effect
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF6B9D).withValues(alpha: 0.4),
                        const Color(0xFFFF8FB1).withValues(alpha: 0.25),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    image: candidate.avatarUrl != null
                        ? DecorationImage(
                            image: ResizeImage(
                              NetworkImage(candidate.avatarUrl!),
                              width: 150,
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: candidate.avatarUrl == null
                      ? Center(
                          child: Text(
                            candidate.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidate.name,
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextPrimary(themeProvider.isDarkMode),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Zodiac Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  Helpers.getZodiacEmoji(candidate.zodiacSign),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  candidate.zodiacSign,
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Text',
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (candidate.lastCompatibilityScore != null) ...[
                            const SizedBox(width: 8),
                            // Score Badge with Glow
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFF6B9D),
                                    const Color(0xFFFF8FB1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${candidate.lastCompatibilityScore!.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow indicator
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyCandidateState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text('💔', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.noLoveCandidate,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }











  Widget _buildBiorhythmSection() {
    return Consumer2<UserProvider, ThemeProvider>(
      builder: (context, userProvider, themeProvider, child) {
        final user = userProvider.user;
        final birthDate = user?.birthDate;
        
        // Calculate biorhythm scores
        Map<String, double> scores = {};
        if (birthDate != null) {
          final days = DateTime.now().difference(birthDate).inDays.toDouble();
          scores = {
            'physical': ((math.sin(2 * math.pi * days / 23) + 1) / 2 * 100).clamp(0, 100),
            'emotional': ((math.sin(2 * math.pi * days / 28) + 1) / 2 * 100).clamp(0, 100),
            'mental': ((math.sin(2 * math.pi * days / 33) + 1) / 2 * 100).clamp(0, 100),
          };
        }
        
        return LiquidGlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: 24,
          glowColor: const Color(0xFF9C27B0), // Purple glow
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_graph, color: Color(0xFFD4C4F0), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.biorhythm,
                            style: TextStyle(
                              color: AppColors.getTextPrimary(themeProvider.isDarkMode),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                          Text(
                            AppStrings.isEnglish ? 'Energy Cycles' : 'Enerji Döngüleri',
                            style: TextStyle(
                              color: AppColors.getTextSecondary(themeProvider.isDarkMode),
                              fontSize: 13,
                              fontFamily: 'SF Pro Text',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  MysticalButton(
                    text: AppStrings.details,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BiorhythmScreen()),
                    ),
                    size: MysticalButtonSize.small,
                    customColor: const Color(0xFF9C27B0).withOpacity(0.3),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              if (birthDate == null) 
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : AppColors.premiumLightSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : AppColors.premiumLightSurface),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFD4C4F0)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppStrings.selectBirthDateFirst,
                          style: TextStyle(
                            color: AppColors.getTextPrimary(themeProvider.isDarkMode),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else 
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCircularIndicator('Physical', scores['physical'] ?? 0, const Color(0xFF4FC3F7), themeProvider.isDarkMode), // Light Blue
                    _buildCircularIndicator('Emotional', scores['emotional'] ?? 0, const Color(0xFFF48FB1), themeProvider.isDarkMode), // Pink
                    _buildCircularIndicator('Mental', scores['mental'] ?? 0, const Color(0xFFA5D6A7), themeProvider.isDarkMode), // Green
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircularIndicator(String label, double score, Color color, bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: score / 100,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '${score.toInt()}%',
              style: TextStyle(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: AppColors.getTextSecondary(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }



  Widget _buildKarmaSection() {
    return const SizedBox();
  }

  Widget _buildGlassInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherFeatures() {
    return const SizedBox();
  }

  Widget _buildHoroscopeSection() {
    return const SizedBox();
  }

  Widget _zodiacCard(Map<String, String> zodiac, String description, [bool isDark = true]) {
    return const SizedBox();
  }
  
  static const List<Map<String, String>> _zodiacList = [];

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return const SizedBox();
  }

  Widget _buildBottomNavigationBar() {
    return LiquidGlassNavbar(
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTap,
      items: [
        NavbarItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: _isEnglish ? 'Home' : 'Ana Sayfa',
        ),
        NavbarItem(
          icon: Icons.history_outlined,
          activeIcon: Icons.history_rounded,
          label: _isEnglish ? 'History' : 'Geçmiş',
        ),
        NavbarItem(
          icon: Icons.quiz_outlined,
          activeIcon: Icons.quiz_rounded,
          label: _isEnglish ? 'Tests' : 'Testler',
        ),
        NavbarItem(
          icon: Icons.people_outline,
          activeIcon: Icons.people_rounded,
          label: _isEnglish ? 'Social' : 'Sosyal',
        ),
        NavbarItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person_rounded,
          label: _isEnglish ? 'Profile' : 'Profil',
        ),
      ],
    );
  }

 /*
 Future<void> _loadPendingRequestsCount() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      try {
        final currentUser = Provider.of<UserProvider>(context, listen: false).user;
        if (currentUser == null) {
          if (mounted) {
            setState(() {
              _pendingRequestsCount = 0;
            });
          }
          return;
        }

        final snapshot = await _firestore
            .collection('social_requests')
            .where('toUserId', isEqualTo: currentUser.id)
            .where('status', isEqualTo: 'pending')
            .get();

        final count = snapshot.docs.length;

        if (mounted) {
          setState(() {
            _pendingRequestsCount = count;
          });
        }
      } catch (e) {
        print('Error loading pending requests count: $e');
      }
    });
  }

  void _startPendingRequestsListener() {
    // Önceki subscription'ı iptal et
    _pendingRequestsSubscription?.cancel();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final currentUser = Provider.of<UserProvider>(context, listen: false).user;
      if (currentUser == null) {
        if (mounted) {
          setState(() {
            _pendingRequestsCount = 0;
          });
        }
        return;
      }

      _pendingRequestsSubscription = _firestore
          .collection('social_requests')
          .where('toUserId', isEqualTo: currentUser.id)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen((snapshot) {
        if (!mounted) return;

        final count = snapshot.docs.length;

        if (mounted) {
          setState(() {
            _pendingRequestsCount = count;
          });
        }
      });
    });
  }

  // HomeScreen'deki "Fallarımı Göster" kartı
  Widget _showResultsCard([String? fortuneTypeFilter]) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _pendingHistoryFilter = fortuneTypeFilter ?? 'all';
          _selectedIndex = 1;
        });
        _pageController.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 1),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFA6EA7), Color(0xFF7E18A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.12),
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.style, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  AppStrings.showMyFortunes,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: .13,
                    shadows: [
                      Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 2)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
 */
  Future<void> _loadPendingRequestsCount() async {}
  void _startPendingRequestsListener() {}
  Widget _showResultsCard([String? fortuneTypeFilter]) { return const SizedBox(); }

  @override
  void dispose() {
    _pendingRequestsSubscription?.cancel();
    _backgroundController.dispose();
    _cardController.dispose();
    _pageController.dispose();
    _adsService.disposeAllAds();
    super.dispose();
  }

  // Rewarded Ad akışı

  Widget _buildFortunesHistoryTab() {
    // Bu fonksiyon _pendingHistoryFilter'i kullanarak sadece 1 kez dream filtresi ile açılmayı tetikler
    if (_pendingHistoryFilter != null) {
      final String filter = _pendingHistoryFilter!;
      // filter parametresini tek seferlik tüket
      _pendingHistoryFilter = null;
      return FortunesHistoryScreen(selectedFilter: filter);
    }
    return const FortunesHistoryScreen();
  }

}

// -------- HomeScreen'deki Fal Grid'in ana sayfa versiyonu --------
class _FalGridHome extends StatelessWidget {
  final Future<void> Function(Widget) onNavigate;

  const _FalGridHome({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        final items = [
          _FalItemHome(
            title: AppStrings.coffeeFortune,
            iconAsset: 'assets/icons/coffee.png',
            onTap: (ctx) => onNavigate(const CoffeeFortuneScreen()),
          ),
          _FalItemHome(
            title: AppStrings.tarotFortune,
            iconAsset: 'assets/icons/tarot.png',
            onTap: (ctx) => onNavigate(const TarotFortuneScreen()),
          ),
          _FalItemHome(
            title: AppStrings.palmFortune,
            iconAsset: 'assets/icons/palm.png',
            onTap: (ctx) => onNavigate(const PalmFortuneScreen()),
          ),
          _FalItemHome(
            title: AppStrings.katinaFortune,
            iconAsset: 'assets/icons/katina.png',
            onTap: (ctx) => onNavigate(const KatinaFortuneScreen()),
          ),
          _FalItemHome(
            title: AppStrings.faceFortune,
            iconAsset: 'assets/icons/face.png',
            onTap: (ctx) => onNavigate(const FaceFortuneScreen()),
          ),
          _FalItemHome(
            title: AppStrings.astrology,
            iconAsset: 'assets/icons/astrology.png',
            onTap: (ctx) => onNavigate(const AstrologyScreen()),
          ),
        ];

        return LayoutBuilder(
          builder: (ctx, c) {
            final cross = c.maxWidth >= 420 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.82, 
              ),
              itemBuilder: (ctx, i) {
                final it = items[i];
                return RepaintBoundary(
                  child: _GlassFalCard(
                    title: it.title,
                    iconAsset: it.iconAsset,
                    onTap: () => it.onTap(ctx),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Premium Glass Card with Blur+Zoom Animation and Chromatic Aberration
class _GlassFalCard extends StatefulWidget {
  final String title;
  final String iconAsset;
  final VoidCallback onTap;

  const _GlassFalCard({
    required this.title,
    required this.iconAsset,
    required this.onTap,
  });

  @override
  State<_GlassFalCard> createState() => _GlassFalCardState();
}

class _GlassFalCardState extends State<_GlassFalCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    // Phase 1: Suck In Animation (Forward)
    // "İçine kapılıp..." -> We go to 1.0 (Deep 3D suck)
    if (!_isPressed) {
      setState(() => _isPressed = true);
      await _animationController.forward().orCancel;
    }

    // Phase 2: Launch Next Page immediately while sucked in
    // "sonra diğer sayfanın zoomlu gelip..."
    
    if (mounted) {
      widget.onTap();
      
      // Reset the card state AFTER we potentially come back, or after a delay
      // The user won't see this reset if the new page covers it properly.
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        // Silently reset or animate back gently
        setState(() => _isPressed = false);
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.animateTo(1.0, curve: Curves.easeOutQuad);
      },
      onTapUp: (_) => _handleTap(),
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final themeProvider = Provider.of<ThemeProvider>(context);
          // "Suck & Squeeze" Effect Logic
          // Value 0.0 = Normal State
          // Value 1.0 = Sucked In (Pressed) State
          
          final double t = _animationController.value;
          
          // SUCK: Scale down significantly (to 0.85)
          // SQUEEZE/POP: The reverse animation uses ElasticOut, so it will overshoot 1.0 (to ~1.15)
          // Since we map 0.0 -> 1.0 linearly here, the controller's Elastic curve handles the visuals.
          // BUT: Elastic overshooting 0.0 means 't' goes negative.
          // We need to handle negative 't' for the expanding squeeze effect.
          
          double scale = 1.0 - (0.15 * t); // At t=1.0, scale=0.85. At t<0 (elastic), scale > 1.0.
          
          // RotateX: Bends the top backwards.
          // At t=1.0, tilt = 0.35 rad (~20 deg).
          double tilt = 0.35 * t; 
          
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // Stronger Perspective (was 0.001)
              ..scale(scale)
              ..rotateX(tilt), // Bends card "into" the screen
            child: child,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.1) : AppColors.premiumLightSurface.withValues(alpha: 0.8),
                    themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.premiumLightSurface.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.2) : AppColors.premiumLightSurface.withValues(alpha: 1.0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Chromatic Aberration Effect (Simulated with offset borders/glows)
                  // Red shift
                  Positioned(
                    top: 1, left: 1, bottom: -1, right: -1,
                    child: Opacity(
                      opacity: 0.5, // Increased opacity for effect visibility
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  // Blue shift
                  Positioned(
                    top: -1, left: -1, bottom: 1, right: 1,
                    child: Opacity(
                      opacity: 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  
                  // Content with Blur Animation 
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      // Blur increases as we get sucked in (t -> 1.0)
                      // Blur removes as we squeeze out (t -> 0.0)
                      double blurVal = (_animationController.value * 8).clamp(0.0, 10.0);
                      return ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: blurVal,
                          sigmaY: blurVal,
                        ),
                        child: child,
                      );
                    },
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Container(
                            height: 85,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.15) : AppColors.premiumLightAccent.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              widget.iconAsset,
                              fit: BoxFit.contain,
                              cacheWidth: 170,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.getTextPrimary(themeProvider.isDarkMode),
                                shadows: themeProvider.isDarkMode ? [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 5,
                                  ),
                                ] : null,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
}

class _FalItemHome {
  final String title;
  final String iconAsset;
  final void Function(BuildContext) onTap;
  _FalItemHome({required this.title, required this.iconAsset, required this.onTap});
}

/// Glassmorphism CTA Button with iOS scale animation
/// Glassmorphism CTA Button with iOS scale animation
class _GlassCTAButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;

  const _GlassCTAButton({
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  State<_GlassCTAButton> createState() => _GlassCTAButtonState();
}

class _GlassCTAButtonState extends State<_GlassCTAButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutQuart,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(27),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppColors.champagneGoldGradient,
                borderRadius: BorderRadius.circular(27),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.champagneGold.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Row(
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
    );
  }
}

/// Reusable Glass Feature Card with iOS scale animation
class _GlassFeatureCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _GlassFeatureCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_GlassFeatureCard> createState() => _GlassFeatureCardState();
}

class _GlassFeatureCardState extends State<_GlassFeatureCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutQuart,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Reverted blur
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.12) : AppColors.premiumLightSurface.withValues(alpha: 0.9),
                    themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.06) : AppColors.premiumLightSurface.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: themeProvider.isDarkMode ? Colors.white.withValues(alpha: 0.15) : AppColors.premiumLightSurface,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.iconColor.withValues(alpha: 0.25),
                          widget.iconColor.withValues(alpha: 0.12),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.iconColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontFamily: 'SF Pro Text',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextPrimary(themeProvider.isDarkMode).withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom PageRoute for "Zoom + Blur" transition with Background Blur
/// Optimized for 120Hz displays with ultra-smooth animations
class ZoomBlurPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ZoomBlurPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          opaque: false, // Allows seeing the background (Home)
          barrierColor: Colors.black.withValues(alpha: 0.0), // Transparent barrier
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Use more refined curves for 120Hz smoothness
            final curve = CurvedAnimation(
              parent: animation, 
              curve: Curves.easeOutExpo, // Smoother curve for 120Hz
            );
            
            // 1. Foreground Zoom: 1.25 -> 1.0 (Reduced for smoother feel)
            final scaleAnimation = Tween<double>(begin: 1.25, end: 1.0).animate(curve);

            // 2. Foreground Blur: 12px -> 0px (Reduced for performance)
            final blurVal = Tween<double>(begin: 12.0, end: 0.0).animate(curve);

            // 3. Foreground Fade with separate curve for premium feel
            final fadeCurve = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
            );
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(fadeCurve);

            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: fadeAnimation,
                  child: Transform.scale(
                    scale: scaleAnimation.value,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: blurVal.value,
                        sigmaY: blurVal.value,
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: child,
            );
          },
          // Optimized timings for 120Hz (96 frames for entry, 72 frames for exit)
          transitionDuration: const Duration(milliseconds: 500), // 60 frames at 120Hz
          reverseTransitionDuration: const Duration(milliseconds: 400), // 48 frames at 120Hz
        );
}
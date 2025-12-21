import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/fortune_model.dart';
import '../../core/services/firebase_service.dart';
import '../../core/providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/widgets/liquid_glass_widgets.dart';
import '../../core/services/ads_service.dart';
import '../fortune/fortune_result_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FortunesHistoryScreen extends StatefulWidget {
  final String? selectedFilter;
  const FortunesHistoryScreen({Key? key, this.selectedFilter}) : super(key: key);

  @override
  State<FortunesHistoryScreen> createState() => _FortunesHistoryScreenState();
}

class _FortunesHistoryScreenState extends State<FortunesHistoryScreen>
    with TickerProviderStateMixin {
  final AdsService _adsService = AdsService();
  
  String _selectedFilter = 'all';
  String _selectedSort = 'newest';
  List<Map<String, dynamic>> _dreamDraws = [];
  List<FortuneModel> _userFortunes = [];
  bool _loadingFortunes = false;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter ?? 'all';
    _initializeAnimations();
    _loadFortunes();
  }

  void _initializeAnimations() {
    _loadDreamDraws();
  }

  Future<void> _loadDreamDraws() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (userId != null) {
        final docs = await FirebaseService().getDreamDraws(userId);
        if (mounted) {
          setState(() {
        _dreamDraws = docs.map((d) => {'id': d.id, ...Map<String, dynamic>.from(d.data() as Map)}).toList();
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading dream draws: $e');
      }
    }
  }

  Future<void> _loadFortunes() async {
    setState(() => _loadingFortunes = true);
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (userId != null) {
        final docs = await FirebaseService().getUserFortunesFromReadings(userId);
        final List<FortuneModel> fortunes = [];
        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          try {
            fortunes.add(FortuneModel(
              id: doc.id,
              userId: data['userId'] ?? '',
              type: FortuneType.values.firstWhere(
                (t) => t.name == (data['type'] ?? '').toString().toLowerCase(),
                orElse: () => FortuneType.tarot,
              ),
              status: FortuneStatus.values.firstWhere(
                (s) => s.name == (data['status'] ?? 'completed').toString().toLowerCase(),
                orElse: () => FortuneStatus.completed,
              ),
              title: data['title'] ?? '',
              interpretation: data['interpretation'] ?? '',
              inputData: Map<String, dynamic>.from(data['inputData'] ?? {}),
              selectedCards: List<String>.from(data['selectedCards'] ?? []),
              imageUrls: List<String>.from(data['imageUrls'] ?? []),
              question: data['question'],
              fortuneTellerId: data['fortuneTellerId'],
              createdAt: (data['createdAt'] is Timestamp)
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
              completedAt: (data['completedAt'] is Timestamp)
                  ? (data['completedAt'] as Timestamp).toDate()
                  : DateTime.tryParse(data['completedAt']?.toString() ?? ''),
              isFavorite: data['isFavorite'] ?? false,
              rating: (data['rating'] ?? 0) is int ? data['rating'] : (int.tryParse(data['rating'].toString()) ?? 0),
              notes: data['notes'],
              isForSelf: data['isForSelf'] ?? true,
              targetPersonName: data['targetPersonName'],
              metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
              karmaUsed: data['karmaUsed'] ?? 0,
              isPremium: data['isPremium'] ?? false,
            ));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Error parsing fortune document: $e');
            }
          }
        }
        _userFortunes = fortunes;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading fortunes: $e');
      }
    }
    if (mounted) setState(() => _loadingFortunes = false);
  }

  Widget _getFortuneTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'tarot':
        return Image.asset(
          'assets/icons/tarot.png',
          width: 36,
          height: 36,
          errorBuilder: (_, __, ___) => const Text('🔮', style: TextStyle(fontSize: 32)),
        );
      case 'coffee':
        return Image.asset(
          'assets/icons/coffee.png',
          width: 36,
          height: 36,
          errorBuilder: (_, __, ___) => const Text('☕', style: TextStyle(fontSize: 32)),
        );
      case 'palm':
        return Image.asset(
          'assets/icons/palm.png',
          width: 36,
          height: 36,
          errorBuilder: (_, __, ___) => const Text('✋', style: TextStyle(fontSize: 32)),
        );
      case 'astrology':
        return Image.asset(
          'assets/icons/astrology.png',
          width: 36,
          height: 36,
          errorBuilder: (_, __, ___) => const Text('⭐', style: TextStyle(fontSize: 32)),
        );
      case 'face':
      case 'water':
        return Image.asset(
          'assets/icons/face.png',
          width: 36,
          height: 36,
          errorBuilder: (_, __, ___) => const Text('👤', style: TextStyle(fontSize: 32)),
        );
      case 'katina':
        return Image.asset(
          'assets/icons/katina.png',
          width: 36,
          height: 36,
          errorBuilder: (_, __, ___) => const Text('🔮', style: TextStyle(fontSize: 32)),
        );
      case 'dream':
        return Image.asset(
          'assets/icons/dream.png',
          width: 36,
          height: 36,
          errorBuilder: (_, __, ___) => const Text('🌙', style: TextStyle(fontSize: 32)),
        );
      default:
        return const Text('🔮', style: TextStyle(fontSize: 32));
    }
  }

  Color _getFortuneTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'tarot':
        return LiquidGlassColors.liquidGlassActive;
      case 'coffee':
        return const Color(0xFFC4A477);
      case 'palm':
        return const Color(0xFF9B8ED0);
      case 'astrology':
        return const Color(0xFFE6D3A3);
      case 'dream':
        return const Color(0xFF7C6FA8);
      default:
        return LiquidGlassColors.liquidGlassActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: AppColors.premiumDarkGradient,
            ),
            child: SafeArea(
              child: LiquidGlassScreenWrapper(
                duration: const Duration(milliseconds: 700),
                child: Column(
                  children: [
                    _buildHeader(isDark),
                    _buildFilters(isDark),
                    Expanded(
                      child: _loadingFortunes
                          ? Center(
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
                                      type: MysticalLoadingType.cards,
                                      message: 'Fallar yükleniyor...',
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : _buildCombinedAccordingToFilter(isDark),
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

  Widget _buildHeader(bool isDark) {
    return LiquidGlassHeader(
      title: AppStrings.fortunesHistory,
      trailing: Builder(
        builder: (context) {
          final totalCount = _userFortunes.length + _dreamDraws.length;
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      LiquidGlassColors.liquidGlassActive.withOpacity(0.4),
                      LiquidGlassColors.liquidGlassSecondary.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: LiquidGlassColors.liquidGlassActive.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: LiquidGlassColors.liquidGlassActive.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  '$totalCount ${AppStrings.total}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Container(
      height: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Type Filter
          SizedBox(
            height: 55,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildLiquidGlassFilterChip('all', AppStrings.all, Icons.all_inclusive),
                const SizedBox(width: 8),
                _buildLiquidGlassFilterChip('tarot', AppStrings.tarot, Icons.auto_awesome),
                const SizedBox(width: 8),
                _buildLiquidGlassFilterChip('coffee', AppStrings.coffee, Icons.coffee),
                const SizedBox(width: 8),
                _buildLiquidGlassFilterChip('palm', AppStrings.palm, Icons.back_hand),
                const SizedBox(width: 8),
                _buildLiquidGlassFilterChip('astrology', AppStrings.astrology, Icons.star),
                const SizedBox(width: 8),
                _buildLiquidGlassFilterChip('dream', 'Rüya', Icons.nightlight_round),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Sort Filter
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildLiquidGlassSortChip('newest', AppStrings.newest, Icons.schedule),
                const SizedBox(width: 8),
                _buildLiquidGlassSortChip('oldest', AppStrings.oldest, Icons.history),
                const SizedBox(width: 8),
                _buildLiquidGlassSortChip('favorites', AppStrings.favorites, Icons.favorite),
                const SizedBox(width: 8),
                _buildLiquidGlassSortChip('rating', AppStrings.rating, Icons.star_rate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidGlassFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    
    return LiquidGlassChip(
      label: label,
      icon: icon,
      isSelected: isSelected,
      selectedColor: _getFortuneTypeColor(value),
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
    );
  }

  Widget _buildLiquidGlassSortChip(String value, String label, IconData icon) {
    final isSelected = _selectedSort == value;
    
    return LiquidGlassChip(
      label: label,
      icon: icon,
      isSelected: isSelected,
      selectedColor: const Color(0xFF8B7BC0),
      onTap: () {
        setState(() {
          _selectedSort = value;
        });
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
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
                    LiquidGlassColors.liquidGlassActive.withOpacity(0.3),
                    LiquidGlassColors.liquidGlassSecondary.withOpacity(0.2),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 60,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.noFortunes,
              style: AppTextStyles.headingMedium.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.startFirstFortune,
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

  Widget _buildFortunesList(List<FortuneModel> fortunes, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: fortunes.length,
      itemBuilder: (context, index) {
        final fortune = fortunes[index];
        return _buildFortuneCard(fortune, isDark, index);
      },
    );
  }

  Widget _buildCombinedAccordingToFilter(bool isDark) {
    List<FortuneModel> list = [];
    if (_selectedFilter == 'dream') {
      final dreams = _userFortunes.where((f) => f.type == FortuneType.dream).toList();
      final draws = _dreamDraws.map((d) => _mapDreamDrawToFortune(d)).toList();
      list = [...dreams, ...draws];
    } else if (_selectedFilter == 'all') {
      final draws = _dreamDraws.map((d) => _mapDreamDrawToFortune(d)).toList();
      list = [..._userFortunes, ...draws];
    } else {
      list = _userFortunes
          .where((f) => f.type.name.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }
    if (list.isEmpty) return _buildEmptyState(isDark);
    switch (_selectedSort) {
      case 'newest':
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'favorites':
        list = list.where((f) => f.isFavorite).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return _buildFortunesList(list, isDark);
  }

  FortuneModel _mapDreamDrawToFortune(Map<String, dynamic> d) {
    DateTime createdAt;
    final raw = d['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else {
      createdAt = DateTime.tryParse(raw?.toString() ?? '') ?? DateTime.now();
    }
    final prompt = (d['prompt'] ?? '').toString();
    final style = (d['style'] ?? AppStrings.dreamDrawing).toString();
    final userId = Provider.of<UserProvider>(context, listen: false).user?.id ?? '';
    return FortuneModel(
      id: d['id']?.toString() ?? '',
      userId: userId,
      type: FortuneType.dream,
      status: FortuneStatus.completed,
      title: style,
      interpretation: prompt.isEmpty ? 'Çizim açıklaması yok.' : prompt,
      inputData: const {},
      selectedCards: const [],
      imageUrls: const [],
      question: null,
      fortuneTellerId: null,
      createdAt: createdAt,
      completedAt: createdAt,
      isFavorite: false,
      rating: 0,
      notes: null,
      isForSelf: true,
      targetPersonName: null,
      metadata: const {'source': 'dream_draw'},
      karmaUsed: 0,
      isPremium: false,
    );
  }

  Future<void> _showAdAndNavigate(FortuneModel fortune) async {
    try {
      final loadedCompleter = Completer<bool>();
      await _adsService.createInterstitialAd(
        adUnitId: _adsService.interstitialAdUnitId,
        onAdLoaded: (ad) {
          if (!loadedCompleter.isCompleted) loadedCompleter.complete(true);
        },
        onAdFailedToLoad: (error) {
          if (!loadedCompleter.isCompleted) loadedCompleter.complete(false);
        },
      );

      bool isLoaded = false;
      try {
        isLoaded = await loadedCompleter.future.timeout(const Duration(seconds: 2));
      } catch (_) {
        isLoaded = false;
      }

      if (isLoaded) {
        await _adsService.showInterstitialAd();
      }
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FortuneResultScreen(fortune: fortune),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FortuneResultScreen(fortune: fortune),
          ),
        );
      }
    }
  }

  Widget _buildFortuneCard(FortuneModel fortune, bool isDark, int index) {
    final fortuneColor = _getFortuneTypeColor(fortune.type.name);
    final displayTitle = _getFortuneDisplayTitle(fortune);
    
    return LiquidGlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      animationDelayMs: index * 80,
      glowColor: fortuneColor,
      onTap: () => _showAdAndNavigate(fortune),
      child: Row(
        children: [
          // Icon container with glass effect
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      fortuneColor.withOpacity(0.5),
                      fortuneColor.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: fortuneColor.withOpacity(0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: fortuneColor.withOpacity(0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: _getFortuneTypeIcon(fortune.type.name),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayTitle,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (fortune.isFavorite)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
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
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      color: Colors.white.withOpacity(0.6),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(fortune.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    if (fortune.rating > 0) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.karma.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.karma.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.karma,
                              size: 12,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${fortune.rating}/5',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.karma,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.6),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _getFortuneDisplayTitle(FortuneModel fortune) {
    if (fortune.metadata['source'] == 'dream_draw') {
      return AppStrings.dreamDrawing;
    }
    switch (fortune.type) {
      case FortuneType.tarot:
        return '${AppStrings.tarot} ${AppStrings.interpretation}';
      case FortuneType.coffee:
        return AppStrings.coffeeFortune;
      case FortuneType.palm:
        return AppStrings.palmFortune;
      case FortuneType.astrology:
        return AppStrings.astrology;
      case FortuneType.face:
        return AppStrings.faceFortune;
      case FortuneType.katina:
        return AppStrings.katinaFortune;
      case FortuneType.dream:
        return AppStrings.dreamInterpretation;
      case FortuneType.daily:
        return AppStrings.dailyFortune;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} ${AppStrings.minutesAgo}';
      }
      return '${difference.inHours} ${AppStrings.hoursAgo}';
    } else if (difference.inDays == 1) {
      return AppStrings.yesterday;
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${AppStrings.daysAgo}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _adsService.disposeAllAds();
    super.dispose();
  }
}
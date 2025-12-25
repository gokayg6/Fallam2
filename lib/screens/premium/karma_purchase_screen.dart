import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/pricing_constants.dart';
import '../../core/providers/user_provider.dart';
import '../../core/services/purchase_service.dart';
import '../../core/services/ads_service.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/mystical_button.dart';
import '../../core/widgets/liquid_glass_navbar.dart';
import '../../core/widgets/liquid_glass_widgets.dart';
import 'spin_wheel_screen.dart';

class KarmaPurchaseScreen extends StatefulWidget {
  final int initialTab;
  
  const KarmaPurchaseScreen({
    Key? key,
    this.initialTab = 0,
  }) : super(key: key);

  @override
  State<KarmaPurchaseScreen> createState() => _KarmaPurchaseScreenState();
}

class _KarmaPurchaseScreenState extends State<KarmaPurchaseScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;
  late TabController _tabController;
  
  bool _isLoading = false;
  bool _isInitializing = true;
  final PurchaseService _purchaseService = PurchaseService();
  final AdsService _adsService = AdsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _initializeAnimations();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    try {
      await _purchaseService.initialize();
      _purchaseService.onPurchaseSuccess = _handlePurchaseSuccess;
      _purchaseService.onPurchaseError = _handlePurchaseError;
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  void _handlePurchaseSuccess(PurchaseDetails purchaseDetails) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final productId = purchaseDetails.productID;
    
    if (productId.startsWith('karma_')) {
      final karmaAmount = int.tryParse(productId.split('_')[1]) ?? 0;
      await userProvider.addKarma(karmaAmount, 'Buy Karma');
      _showSuccess('$karmaAmount ${AppStrings.karmaAddedSuccessfully}');
    }
  }

  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    _showError(AppStrings.getPurchaseErrorMessage(purchaseDetails.error?.message));
  }

  void _showSuccess(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.success));
  }

  void _showError(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  void _initializeAnimations() {
    _cardController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutBack));
    _cardController.forward();
  }

  Future<void> _purchaseKarma(int karma) async {
    setState(() => _isLoading = true);
    try {
      final productId = PricingConstants.karmaProductIds[karma];
      if (productId == null) throw Exception('Product not found');
      await _purchaseService.purchaseProduct(productId);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;
        final bgColor = isDark ? AppColors.background : const Color(0xFFFEFDFB);
        final bgGradient = isDark 
            ? themeProvider.backgroundGradient 
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFEFDFB), Color(0xFFFAF8F5)],
              );
        
        return Scaffold(
          backgroundColor: bgColor,
          body: Container(
            decoration: BoxDecoration(gradient: bgGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(isDark),
                  _buildBalanceCard(isDark),
                  _buildAnimatedTabBar(isDark),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBuyTab(isDark),
                        _buildEarnTab(isDark),
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

  Widget _buildAppBar(bool isDark) {
    final btnBg = isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF5F2ED);
    final iconColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final textColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: btnBg,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: iconColor, size: 18),
            ),
          ),
          Expanded(
            child: Text(
              'KARMA STORE',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor, 
                fontSize: 16, 
                fontWeight: FontWeight.w600, 
                letterSpacing: 2,
                fontFamily: 'SF Pro Display',
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(bool isDark) {
    final cardBg = isDark 
        ? Colors.white.withOpacity(0.08) 
        : Colors.white;
    final cardBorder = isDark 
        ? Colors.white.withOpacity(0.15) 
        : const Color(0xFFD4AF37).withOpacity(0.3);
    final labelColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    final valueColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final karma = userProvider.user?.karma ?? 0;
        return ScaleTransition(
          scale: _cardAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cardBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(isDark ? 0.2 : 0.15),
                    blurRadius: 25,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFD4AF37), Color(0xFFC9A227)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      fontFamily: 'SF Pro Text',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$karma ✧',
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Display',
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

  // Animated blob-like tab bar (similar to navbar)
  Widget _buildAnimatedTabBar(bool isDark) {
    final containerBg = isDark 
        ? Colors.white.withOpacity(0.08) 
        : const Color(0xFFF5F2ED);
    final unselectedColor = isDark ? Colors.white60 : const Color(0xFF6B6B6B);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 52,
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(26),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated blob indicator
          AnimatedBuilder(
            animation: _tabController.animation!,
            builder: (context, child) {
              final animValue = _tabController.animation!.value;
              final tabWidth = (MediaQuery.of(context).size.width - 40) / 2;
              
              return Positioned(
                left: 4 + (animValue * (tabWidth - 4)),
                top: 4,
                bottom: 4,
                width: tabWidth - 8,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFC9A227)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.35),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Tab buttons (no Material indicator)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(0),
                  child: AnimatedBuilder(
                    animation: _tabController.animation!,
                    builder: (context, _) {
                      final isSelected = _tabController.animation!.value < 0.5;
                      return Center(
                        child: Text(
                          'BUY',
                          style: TextStyle(
                            color: isSelected ? Colors.white : unselectedColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 1,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(1),
                  child: AnimatedBuilder(
                    animation: _tabController.animation!,
                    builder: (context, _) {
                      final isSelected = _tabController.animation!.value >= 0.5;
                      return Center(
                        child: Text(
                          'EARN',
                          style: TextStyle(
                            color: isSelected ? Colors.white : unselectedColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 1,
                            fontFamily: 'SF Pro Text',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuyTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionTitle('Standard Units', isDark),
        const SizedBox(height: 16),
        ...PricingConstants.karmaPrices.entries.map((entry) => _buildKarmaTile(entry.key, entry.value, isDark)),
      ],
    );
  }

  Widget _buildKarmaTile(int karma, double price, bool isDark) {
    final tileBg = isDark ? Colors.white.withOpacity(0.08) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFD4AF37).withOpacity(0.2);
    final titleColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final subtitleColor = isDark ? Colors.white60 : const Color(0xFF6B6B6B);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFD4AF37).withOpacity(isDark ? 0.25 : 0.15),
                    const Color(0xFFC9A227).withOpacity(isDark ? 0.15 : 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.25)),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$karma Karma',
                    style: TextStyle(
                      color: titleColor, 
                      fontWeight: FontWeight.w600, 
                      fontSize: 17,
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Premium Credits',
                    style: TextStyle(color: subtitleColor, fontSize: 12, fontFamily: 'SF Pro Text'),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _purchaseKarma(karma),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFC9A227)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  '₺${price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'SF Pro Text'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarnTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildEarnTile(Icons.play_circle_fill, 'Watch Video', '+5 Karma', () => _adsService.showRewardedAd(), isDark),
        _buildEarnTile(Icons.share, 'Share App', '+10 Karma', () => Share.share(AppStrings.shareAppMessage), isDark),
        _buildEarnTile(Icons.casino, 'Spin & Win', 'Luck based', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SpinWheelScreen()));
        }, isDark),
      ],
    );
  }

  Widget _buildEarnTile(IconData icon, String title, String earn, VoidCallback onTap, bool isDark) {
    final tileBg = isDark ? Colors.white.withOpacity(0.08) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final arrowColor = isDark ? Colors.white38 : const Color(0xFF6B6B6B).withOpacity(0.5);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFFD4AF37), size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.w600, fontSize: 16, fontFamily: 'SF Pro Display')),
                      const SizedBox(height: 2),
                      const Text('+Karma', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'SF Pro Text')),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: arrowColor, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    final textColor = isDark ? Colors.white38 : const Color(0xFF6B6B6B);
    return Text(
      title,
      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1, fontFamily: 'SF Pro Text'),
    );
  }
}


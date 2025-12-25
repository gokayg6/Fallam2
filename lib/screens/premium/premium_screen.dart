import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/pricing_constants.dart';
import '../../core/providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/mystical_button.dart';
import '../../core/services/purchase_service.dart';
import '../../core/widgets/liquid_glass_navbar.dart';
import '../../core/widgets/liquid_glass_widgets.dart';
import '../main/main_screen.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;
  
  bool _isLoading = false;
  String _selectedPlan = 'monthly';
  final PurchaseService _purchaseService = PurchaseService();

  List<Map<String, dynamic>> _getPremiumFeatures() {
    return [
      {
        'icon': Icons.notifications_off,
        'title': AppStrings.adFreeExperience,
        'description': AppStrings.adFreeExperienceDesc,
      },
      {
        'icon': Icons.auto_awesome,
        'title': AppStrings.daily25Karma,
        'description': AppStrings.daily25KarmaDesc,
      },
      {
        'icon': Icons.priority_high,
        'title': AppStrings.priorityFortuneReading,
        'description': AppStrings.priorityFortuneReadingDesc,
      },
      {
        'icon': Icons.favorite,
        'title': AppStrings.auraMatchAdvantages,
        'description': AppStrings.auraMatchAdvantagesDesc,
      },
    ];
  }

  List<Map<String, dynamic>> _getPricingPlans() {
    return [
      {
        'id': 'weekly',
        'title': AppStrings.weekly,
        'price': '39,99',
        'period': AppStrings.week,
        'discount': null,
        'popular': false,
      },
      {
        'id': 'monthly',
        'title': AppStrings.monthly,
        'price': '89,99',
        'period': AppStrings.month,
        'discount': null,
        'popular': true,
      },
      {
        'id': 'yearly',
        'title': AppStrings.yearly,
        'price': '499,99',
        'period': AppStrings.year,
        'discount': AppStrings.bestValue,
        'popular': false,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePurchaseService();
  }

  Future<void> _initializePurchaseService() async {
    await _purchaseService.initialize();
    _purchaseService.onPurchaseSuccess = _handlePurchaseSuccess;
    _purchaseService.onPurchaseError = _handlePurchaseError;
    if (mounted) setState(() {});
  }

  Future<void> _handlePurchaseSuccess(PurchaseDetails purchaseDetails) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final productID = purchaseDetails.productID;
      
      if (productID.startsWith('premium_')) {
        final success = await userProvider.upgradeToPremium();
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.purchaseSuccessful), backgroundColor: AppColors.success),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          throw Exception(userProvider.error ?? AppStrings.premiumMembershipNotUpdated);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.purchaseProcessingError} $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _handlePurchaseError(PurchaseDetails purchaseDetails) {
    if (mounted) {
      final errorMessage = AppStrings.getPurchaseErrorMessage(
        purchaseDetails.error?.message ?? purchaseDetails.error?.code,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
      );
    }
  }

  void _initializeAnimations() {
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    ));
    _cardController.forward();
  }

  Future<void> _purchasePremium() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      if (kDebugMode) {
        final success = await userProvider.upgradeToPremium();
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debug: Premium Activated!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
        return;
      }
      
      if (!userProvider.isAuthenticated) throw Exception(AppStrings.pleaseLoginFirst);
      final subscriptionId = PricingConstants.premiumProductIds[_selectedPlan];
      if (subscriptionId == null) throw Exception(AppStrings.subscriptionNotFound);
      if (!_purchaseService.isAvailable) throw Exception(AppStrings.purchaseNotAvailableTryLater);

      final success = await _purchaseService.purchaseSubscription(subscriptionId);
      if (!success) throw Exception(AppStrings.purchaseCouldNotStart);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.purchaseStarted), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.error}: $e'), backgroundColor: AppColors.error),
        );
      }
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
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: bgGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(isDark),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildHeader(isDark),
                          const SizedBox(height: 32),
                          _buildFeatures(isDark),
                          const SizedBox(height: 32),
                          _buildPlans(isDark),
                          const SizedBox(height: 32),
                          MysticalButton(
                            text: _isLoading ? AppStrings.processing : AppStrings.startSubscription,
                            onPressed: _isLoading ? null : _purchasePremium,
                            width: double.infinity,
                            showGlow: true,
                            customGradient: const LinearGradient(colors: [Color(0xFFD4AF37), Color(0xFFC9A227)]),
                          ),
                          const SizedBox(height: 24),
                          _buildPolicies(isDark),
                          const SizedBox(height: 40),
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

  Widget _buildAppBar(bool isDark) {
    final btnBg = isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF5F2ED);
    final iconColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: Icon(Icons.close_rounded, color: iconColor, size: 22),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final titleColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF6B6B6B);
    
    return ScaleTransition(
      scale: _cardAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD4AF37), Color(0xFFC9A227)],
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.35), blurRadius: 25, spreadRadius: 3),
              ],
            ),
            child: const Icon(Icons.auto_awesome, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text(
            AppStrings.premiumTitle,
            style: TextStyle(
              color: titleColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'SF Pro Display',
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.premiumSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 15,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(bool isDark) {
    final cardBg = isDark ? Colors.white.withOpacity(0.08) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF2D2D2D);
    final descColor = isDark ? Colors.white60 : const Color(0xFF6B6B6B);
    
    return Column(
      children: _getPremiumFeatures().asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
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
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(e.value['icon'], color: const Color(0xFFD4AF37), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.value['title'], style: TextStyle(color: titleColor, fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'SF Pro Display')),
                      const SizedBox(height: 3),
                      Text(e.value['description'], style: TextStyle(color: descColor, fontSize: 12, fontFamily: 'SF Pro Text')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlans(bool isDark) {
    return Column(
      children: _getPricingPlans().map((plan) {
        return _PremiumPlanCard(
          plan: plan,
          isSelected: _selectedPlan == plan['id'],
          onTap: () => setState(() => _selectedPlan = plan['id']),
          isDark: isDark,
        );
      }).toList(),
    );
  }

  Widget _buildPolicies(bool isDark) {
    final policyColor = isDark ? Colors.white38 : const Color(0xFF6B6B6B).withOpacity(0.6);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.privacyPolicy, style: TextStyle(color: policyColor, fontSize: 11, decoration: TextDecoration.underline, fontFamily: 'SF Pro Text')),
        const SizedBox(width: 20),
        Text(AppStrings.termsOfUse, style: TextStyle(color: policyColor, fontSize: 11, decoration: TextDecoration.underline, fontFamily: 'SF Pro Text')),
      ],
    );
  }
}

class _PremiumPlanCard extends StatefulWidget {
  final Map<String, dynamic> plan;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _PremiumPlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_PremiumPlanCard> createState() => _PremiumPlanCardState();
}

class _PremiumPlanCardState extends State<_PremiumPlanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDark ? Colors.white.withOpacity(0.08) : Colors.white;
    final titleColor = widget.isDark ? Colors.white : const Color(0xFF2D2D2D);
    final borderColor = widget.isDark ? Colors.white.withOpacity(0.15) : const Color(0xFFD4AF37).withOpacity(0.25);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTapDown: (_) => _controller.animateTo(1.0, curve: Curves.easeOutQuad),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double t = _controller.value;
            double scale = 1.0 - (0.03 * t);

            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.isSelected ? null : cardBg,
              gradient: widget.isSelected 
                ? const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFC9A227)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isSelected ? Colors.transparent : borderColor,
                width: 1.5,
              ),
              boxShadow: widget.isDark ? null : [
                BoxShadow(
                  color: widget.isSelected 
                      ? const Color(0xFFD4AF37).withOpacity(0.25) 
                      : Colors.black.withOpacity(0.04),
                  blurRadius: widget.isSelected ? 15 : 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.plan['title'],
                            style: TextStyle(
                              color: widget.isSelected ? Colors.white : titleColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              fontFamily: 'SF Pro Display',
                            ),
                          ),
                          if (widget.plan['popular']) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: widget.isSelected 
                                    ? Colors.white.withOpacity(0.3) 
                                    : const Color(0xFFD4AF37).withOpacity(widget.isDark ? 0.25 : 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: widget.isSelected ? Colors.white : const Color(0xFFD4AF37), 
                                  fontSize: 9, 
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₺${widget.plan['price']} / ${widget.plan['period']}',
                        style: TextStyle(
                          color: widget.isSelected ? Colors.white : titleColor,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isSelected 
                          ? Colors.white 
                          : const Color(0xFFD4AF37).withOpacity(0.4),
                      width: 1.5,
                    ),
                    color: widget.isSelected ? Colors.white : null,
                  ),
                  child: Icon(
                    Icons.check,
                    color: widget.isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
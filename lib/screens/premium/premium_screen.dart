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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.premiumDarkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildFeatures(),
                      const SizedBox(height: 32),
                      _buildPlans(),
                      const SizedBox(height: 32),
                      MysticalButton(
                        text: _isLoading ? AppStrings.processing : AppStrings.startSubscription,
                        onPressed: _isLoading ? null : _purchasePremium,
                        width: double.infinity,
                        showGlow: true,
                        customGradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                      ),
                      const SizedBox(height: 24),
                      _buildPolicies(),
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
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          ),
          const Spacer(),
          if (kDebugMode)
            const Text('DEBUG MODE', style: TextStyle(color: Colors.white24, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ScaleTransition(
      scale: _cardAnimation,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFFA500).withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
              ],
            ),
            child: const Icon(Icons.diamond_rounded, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.premiumTitle,
            style: AppTextStyles.headingLarge.copyWith(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: const Color(0xFFFFA500).withOpacity(0.5), blurRadius: 15)],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.premiumSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: _getPremiumFeatures().asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                      child: Icon(e.value['icon'], color: const Color(0xFFFFA500), size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(e.value['description'], style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlans() {
    return Column(
      children: _getPricingPlans().map((plan) {
        return _PremiumPlanCard(
          plan: plan,
          isSelected: _selectedPlan == plan['id'],
          onTap: () => setState(() => _selectedPlan = plan['id']),
        );
      }).toList(),
    );
  }

  Widget _buildPolicies() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppStrings.privacyPolicy, style: const TextStyle(color: Colors.white38, fontSize: 11, decoration: TextDecoration.underline)),
        const SizedBox(width: 20),
        Text(AppStrings.termsOfUse, style: const TextStyle(color: Colors.white38, fontSize: 11, decoration: TextDecoration.underline)),
      ],
    );
  }
}

class _PremiumPlanCard extends StatefulWidget {
  final Map<String, dynamic> plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PremiumPlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
            double scale = 1.0 - (0.04 * t);
            double tilt = 0.1 * t;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..scale(scale)
                ..rotateX(tilt),
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: widget.isSelected 
                    ? const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.isSelected ? Colors.white70 : Colors.white24,
                    width: 1.5,
                  ),
                  boxShadow: [
                    if (widget.isSelected)
                      BoxShadow(
                        color: const Color(0xFFFFA500).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Chromatic Aberration for unselected
                    if (!widget.isSelected) ...[
                       Positioned(
                        top: 1, left: 1,
                        child: Opacity(
                          opacity: 0.2,
                          child: Container(
                            width: 200, height: 100, // Approximate
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1.5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                    Row(
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
                                      color: widget.isSelected ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (widget.plan['popular']) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'POPULAR',
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₺${widget.plan['price']} / ${widget.plan['period']}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  shadows: widget.isSelected 
                                    ? [const Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
                                    : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70),
                          ),
                          child: Icon(
                            widget.isSelected ? Icons.check_circle : null,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
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
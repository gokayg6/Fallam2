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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.premiumDarkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildBalanceCard(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBuyTab(),
                    _buildEarnTab(),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
          ),
          const Expanded(
            child: Text(
              'KARMA STORE',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final karma = userProvider.user?.karma ?? 0;
        return ScaleTransition(
          scale: _cardAnimation,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFFFA500), size: 40),
                const SizedBox(height: 12),
                const Text('Current Balance', style: TextStyle(color: Colors.white60, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  '$karma ✧',
                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white.withOpacity(0.1),
        ),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelColor: Colors.white38,
        tabs: const [Tab(text: 'BUY'), Tab(text: 'EARN')],
      ),
    );
  }

  Widget _buildBuyTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSectionTitle('Standard Units'),
        const SizedBox(height: 16),
        ...PricingConstants.karmaPrices.entries.map((entry) => _buildKarmaTile(entry.key, entry.value)),
      ],
    );
  }

  Widget _buildKarmaTile(int karma, double price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFFFFA500), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$karma Karma',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'Premium Credits',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '₺${price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarnTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildEarnTile(Icons.play_circle_fill, 'Watch Video', '+5 Karma', () => _adsService.showRewardedAd()),
        _buildEarnTile(Icons.share, 'Share App', '+10 Karma', () => Share.share(AppStrings.shareAppMessage)),
        _buildEarnTile(Icons.casino, 'Spin & Win', 'Luck based', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SpinWheelScreen()));
        }),
      ],
    );
  }

  Widget _buildEarnTile(IconData icon, String title, String earn, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.7), size: 30),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(earn, style: const TextStyle(color: Color(0xFF00FFD1), fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
    );
  }
}

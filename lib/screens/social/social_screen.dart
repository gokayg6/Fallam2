import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/utils/helpers.dart';
import 'soulmate_analysis_screen.dart';
import 'chat_detail_screen.dart';
import '../../core/widgets/mystical_button.dart';
import 'dart:ui';
import '../../core/widgets/liquid_glass_widgets.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey _pendingRequestsKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  bool _loading = true;
  List<_ChatMatch> _matches = [];
  List<_SocialRequest> _pendingRequests = []; // Gelen istekler
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 sekme: İstekler, Sohbet, Gizlilik
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    try {
      final currentUser = Provider.of<UserProvider>(context, listen: false).user;
      if (currentUser == null) {
        setState(() {
          _error = AppStrings.userSessionNotFound;
          _loading = false;
        });
        return;
      }

      // Kullanıcının tüm match'lerini yükle
      final matchesSnapshot = await _firestore
          .collection('matches')
          .where('users', arrayContains: currentUser.id)
          .orderBy('createdAt', descending: true)
          .get();

      final matches = <_ChatMatch>[];

      for (final matchDoc in matchesSnapshot.docs) {
        final data = matchDoc.data();
        final status = data['status']?.toString() ?? 'accepted'; // Eski match'ler için default accepted
        if (status == 'age_blocked') continue; // Yaş kısıtlaması olan match'leri atla
        if (status != 'accepted') continue;
        final users = List<String>.from(data['users'] ?? []);
        final otherUserId = users.firstWhere((id) => id != currentUser.id, orElse: () => '');
        if (otherUserId.isEmpty) continue;

        final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
        if (!otherUserDoc.exists) continue;

        final otherUser = UserModel.fromFirestore(otherUserDoc);
        
        // Yaş kısıtlaması kontrolü - eğer farklı yaş gruplarındaysa match'i pasife al
        if (currentUser.ageGroup != otherUser.ageGroup) {
          // Match'i age_blocked yap
          await _firestore.collection('matches').doc(matchDoc.id).update({
            'status': 'age_blocked',
            'updatedAt': FieldValue.serverTimestamp(),
          });
          continue; // Bu match'i listeye ekleme
        }
        
        final auraColor = otherUser.preferences['auraColor']?.toString();
        final auraFrequency = (otherUser.preferences['auraFrequency'] as num?)?.toDouble();

        matches.add(_ChatMatch(
          matchId: matchDoc.id,
          user: otherUser,
          auraColor: auraColor,
          auraFrequency: auraFrequency,
          score: (data['score'] as num?)?.toDouble() ?? 0.0,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: status,
          isInitiator: false,
        ));
      }

      // Gelen sosyal istekleri yükle
      final requestsSnapshot = await _firestore
          .collection('social_requests')
          .where('toUserId', isEqualTo: currentUser.id)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      final pendingRequests = <_SocialRequest>[];
      for (final requestDoc in requestsSnapshot.docs) {
        final requestData = requestDoc.data();
        final fromUserId = requestData['fromUserId']?.toString();
        if (fromUserId == null) continue;

        final fromUserDoc = await _firestore.collection('users').doc(fromUserId).get();
        if (!fromUserDoc.exists) continue;

        final fromUser = UserModel.fromFirestore(fromUserDoc);
        final auraColor = fromUser.preferences['auraColor']?.toString();
        final auraFrequency = (fromUser.preferences['auraFrequency'] as num?)?.toDouble();

        pendingRequests.add(_SocialRequest(
          requestId: requestDoc.id,
          user: fromUser,
          auraColor: auraColor,
          auraFrequency: auraFrequency,
          score: (requestData['score'] as num?)?.toDouble() ?? 0.0,
          createdAt: (requestData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          hasAuraCompatibility: requestData['hasAuraCompatibility'] as bool? ?? false,
        ));
      }

      if (mounted) {
        setState(() {
          _matches = matches;
          _pendingRequests = pendingRequests;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '${AppStrings.matchesCouldNotLoad} $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _acceptRequest(_SocialRequest request) async {
    try {
      final currentUser = Provider.of<UserProvider>(context, listen: false).user;
      if (currentUser == null) return;

      await _firestore.collection('social_requests').doc(request.requestId).update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _createMatchIfNeeded(
        initiatorId: request.user.id,
        currentUser: currentUser,
        otherUser: request.user,
        score: request.score,
        hasAuraCompatibility: request.hasAuraCompatibility,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.matchAccepted} ${request.user.name}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      _loadMatches(); // Listeyi yenile
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.errorOccurred} $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _rejectRequest(_SocialRequest request) async {
    try {
      await _firestore.collection('social_requests').doc(request.requestId).update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.requestRejected),
          duration: const Duration(seconds: 2),
        ),
      );
      
      _loadMatches(); // Listeyi yenile
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.errorOccurred} $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _blockRequest(_SocialRequest request) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user;
      if (currentUser == null) return;

      // Onay dialog'u göster
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppStrings.blockUser),
          content: Text(AppStrings.blockUserConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: Text(AppStrings.blockUser),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // İsteği blocked yap
      await _firestore.collection('social_requests').doc(request.requestId).update({
        'status': 'blocked',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Kullanıcıyı blockedUsers listesine ekle (UserProvider üzerinden)
      final success = await userProvider.blockUser(request.user.id);
      
      if (!mounted) return;
      
      if (success) {
        // UserProvider notifyListeners() çağırdı, Consumer otomatik rebuild olacak
        // Ama UI'ı manuel olarak da güncellemek için setState çağır
        setState(() {});
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.userBlocked),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Listeyi yenile ve UI'ı güncelle
        _loadMatches(); // İstekler ve match listesini yenile
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? AppStrings.errorOccurred),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.errorOccurred} $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _createMatchIfNeeded({
    required String initiatorId,
    required UserModel currentUser,
    required UserModel otherUser,
    required double score,
    required bool hasAuraCompatibility,
  }) async {
    // Aynı kullanıcılarla önceden match varsa tekrar oluşturma
    final existingMatches = await _firestore
        .collection('matches')
        .where('users', arrayContains: currentUser.id)
        .get();

    for (final doc in existingMatches.docs) {
      final users = List<String>.from(doc['users'] ?? []);
      if (users.contains(otherUser.id)) {
        return;
      }
    }

    await _firestore.collection('matches').add({
      'users': [currentUser.id, otherUser.id],
      'initiator': initiatorId,
      'status': 'accepted',
      'score': score,
      'hasAuraCompatibility': hasAuraCompatibility,
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  Color? _parseColorFromName(String? name) {
    if (name == null) return null;
    final colorMap = {
      'Mor': const Color(0xFF9B59B6),
      'Mavi': const Color(0xFF3498DB),
      'Yeşil': const Color(0xFF2ECC71),
      'Sarı': const Color(0xFFF1C40F),
      'Turuncu': const Color(0xFFE67E22),
      'Kırmızı': const Color(0xFFE74C3C),
      'Pembe': const Color(0xFFE91E63),
      'Indigo': const Color(0xFF6C5CE7),
      'Turkuaz': const Color(0xFF1ABC9C),
    };
    return colorMap[name] ?? const Color(0xFF9B59B6);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: themeProvider.backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(isDark),
                  _buildTabBar(isDark),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Bekleyen İstekler sekmesi
                        _buildRequestsTab(isDark),
                        // Sohbet sekmesi
                        _buildChatTab(isDark),
                        // Gizlilik sekmesi
                        _buildPrivacyTab(isDark),
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

  Widget _buildHeader(bool isDark) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
                colors: [
                isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.premiumLightSurface,
                isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.premiumLightSurface.withValues(alpha: 0.8),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.mysticPurpleAccent.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.mysticPurpleAccent.withValues(alpha: 0.4),
                      AppColors.mysticMagenta.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mysticPurpleAccent.withValues(alpha: 0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.white, AppColors.mysticLavender],
                ).createShader(bounds),
                child: Text(
                  AppStrings.social,
                  style: AppTextStyles.headingLarge.copyWith(
                    color: AppColors.getTextPrimary(isDark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.mysticPurpleAccent.withOpacity(0.2) : AppColors.premiumLightTextSecondary.withOpacity(0.2),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.mysticPurpleAccent, AppColors.mysticMagenta],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mysticPurpleAccent.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: isDark ? Colors.white.withOpacity(0.6) : AppColors.getTextSecondary(false),
            labelStyle: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTextStyles.bodyMedium,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppStrings.requests,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (_pendingRequests.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_pendingRequests.length}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppStrings.chat,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    if (_matches.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_matches.length}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.privacy_tip_outlined, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        AppStrings.privacy,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsTab(bool isDark) {
    if (_loading) {
      return Center(
        child: MysticalLoading(
          type: MysticalLoadingType.spinner,
          size: 32,
          color: AppColors.getIconColor(isDark),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      color: AppColors.primary,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAuraMatchSection(isDark),
            const SizedBox(height: 24),
            if (_pendingRequests.isNotEmpty) ...[
              _buildPendingRequestsSection(isDark),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Sosyal görünürlük ayarı
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final isVisible = userProvider.socialVisible;
              final statusText = isVisible
                  ? AppStrings.socialVisibilityStatusVisible
                  : AppStrings.socialVisibilityStatusHidden;
              return LiquidGlassCard(
                padding: const EdgeInsets.all(20),
                blurAmount: 20,
                glowColor: isVisible ? AppColors.primary : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.visibility,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppStrings.socialVisibilityTitle,
                            style: AppTextStyles.headingSmall.copyWith(
                              color: AppColors.getTextPrimary(isDark),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Switch(
                          value: isVisible,
                          activeColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.2),
                          onChanged: (value) {
                            userProvider.updateSocialVisibility(value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppStrings.socialVisibilityDesc,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: (isVisible ? AppColors.primary : Colors.grey).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (isVisible ? AppColors.primary : Colors.grey).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isVisible ? Icons.check_circle : Icons.info_outline,
                            color: isVisible ? AppColors.primary : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              statusText,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isVisible ? AppColors.primary : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          // Engellenenler bölümü
          _buildBlockedUsersSection(isDark),
          const SizedBox(height: 24),
          // Gizlilik politikası bilgisi
          LiquidGlassCard(
            padding: const EdgeInsets.all(20),
            blurAmount: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.privacy_tip,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.privacyPolicy,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.privacyPolicyDesc,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    AppStrings.privacyPolicyPoints,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuraMatchSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(24),
        blurAmount: 30,
        glowColor: const Color(0xFF9C27B0), // Purple glow
        child: Column(
          children: [
            // Magical Purple Orb
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFE1BEE7), // Light Purple center
                    Color(0xFF9C27B0), // Purple
                    Color(0xFF4A148C), // Deep Purple
                  ],
                  stops: [0.2, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF9C27B0).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.5) : AppColors.mysticPurpleAccent.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Simple, Elegant Purple Text
            Text(
              AppStrings.auraMatch,
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark ? const Color(0xFFE1BEE7) : const Color(0xFF4A148C),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                shadows: [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF9C27B0) : const Color(0xFFAB47BC)).withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.discoverCompatibleSouls,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                  height: 1.5,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            MysticalButton(
              text: AppStrings.match,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SoulmateAnalysisScreen(),
                  ),
                );
              },
              type: MysticalButtonType.premium,
              icon: Icons.favorite,
              width: double.infinity,
              showGlow: true,
              showPulse: true,
              // Custom Purple Gradient for Button
              customGradient: const LinearGradient(
                colors: [
                  Color(0xFFAB47BC), // Purple 400
                  Color(0xFF7B1FA2), // Purple 700
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              customTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        key: _pendingRequestsKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Text(
                  AppStrings.pendingRequests,
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.getTextPrimary(isDark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_pendingRequests.length}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._pendingRequests.map((request) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPendingRequestCard(request, isDark),
              )),
        ],
      ),
    );
  }

  Widget _buildPendingRequestCard(_SocialRequest request, bool isDark) {
    final auraColor = _parseColorFromName(request.auraColor);
    final surfaceColor = AppColors.getSurface(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(20),
        blurAmount: 20,
        glowColor: auraColor ?? AppColors.primary,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (auraColor != null)
                        BoxShadow(
                          color: auraColor.withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: (auraColor ?? AppColors.primary).withValues(alpha: 0.3),
                      ),
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                surfaceColor.withValues(alpha: isDark ? 0.9 : 1.0),
                                surfaceColor.withValues(alpha: isDark ? 0.7 : 0.95),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              request.user.name.isNotEmpty ? request.user.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: AppColors.getTextPrimary(isDark),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.user.name,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.getTextPrimary(isDark),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.karmaGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '%${request.score.toStringAsFixed(0)}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (request.auraColor != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: auraColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              request.auraColor!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.getTextSecondary(isDark),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade600,
                          Colors.green.shade800,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _acceptRequest(request),
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check, color: Colors.white, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.accept,
                                style: AppTextStyles.buttonMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.getContainerBackground(isDark),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.getContainerBorder(isDark),
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _rejectRequest(request),
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, color: AppColors.getSecondaryIconColor(isDark), size: 20),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.reject,
                                style: AppTextStyles.buttonMedium.copyWith(
                                  color: AppColors.getTextSecondary(isDark),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _blockRequest(request),
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Icon(
                          Icons.block,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTab(bool isDark) {
    if (_loading) {
      return Center(
        child: MysticalLoading(
          type: MysticalLoadingType.spinner,
          size: 32,
          color: AppColors.getIconColor(isDark),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error!,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMatches,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildMatchesList(isDark),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesList(bool isDark) {
    if (_matches.isEmpty) {
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;
      final isTablet = screenWidth > 600;
      
      final horizontalPadding = isSmallScreen ? 16.0 : (isTablet ? 48.0 : 24.0);
      final verticalPadding = isSmallScreen ? 20.0 : (isTablet ? 32.0 : 24.0);
      final emojiSize = isSmallScreen ? 36.0 : (isTablet ? 64.0 : 48.0);
      final spacing = isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0);
      final smallSpacing = isSmallScreen ? 6.0 : 8.0;
      
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isSmallScreen ? 16.0 : 24.0,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: LiquidGlassCard(
              padding: EdgeInsets.all(verticalPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '✨',
                    style: TextStyle(fontSize: emojiSize),
                  ),
                  SizedBox(height: spacing),
                  Text(
                    AppStrings.noAuraMatchesYet,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 16 : (isTablet ? 20 : null),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: smallSpacing),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8.0 : 0),
                    child: Text(
                    AppStrings.pressMatchToMeetNewPeople,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: isSmallScreen ? 13 : (isTablet ? 16 : null),
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
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              AppStrings.messages,
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._matches.map((match) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildChatMatchCard(match, isDark),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildChatMatchCard(_ChatMatch match, bool isDark) {
    final auraColor = _parseColorFromName(match.auraColor);
    final surfaceColor = AppColors.getSurface(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LiquidGlassCard(
        padding: EdgeInsets.zero,
        blurAmount: 15,
        glowColor: auraColor,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  otherUser: match.user,
                  matchId: match.matchId,
                  auraColor: match.auraColor,
                  auraFrequency: match.auraFrequency,
                  score: match.score,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Enhanced avatar with aura glow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (auraColor != null)
                        BoxShadow(
                          color: auraColor.withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: (auraColor ?? AppColors.primary).withValues(alpha: 0.3),
                      ),
                      Positioned.fill(
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                surfaceColor.withValues(alpha: isDark ? 0.9 : 1.0),
                                surfaceColor.withValues(alpha: isDark ? 0.7 : 0.95),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              match.user.name.isNotEmpty ? match.user.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: AppColors.getTextPrimary(isDark),
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                shadows: isDark ? [
                                  const Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              match.user.name,
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.getTextPrimary(isDark),
                                fontWeight: FontWeight.bold,
                                shadows: isDark ? [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ] : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: match.score >= 80
                                  ? const LinearGradient(
                                      colors: [Color(0xFF00E676), Color(0xFF00C853)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : AppColors.karmaGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: (match.score >= 80
                                          ? const Color(0xFF00E676)
                                          : AppColors.karma)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  match.score.toStringAsFixed(0),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '%',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Aura info row
                      Row(
                        children: [
                          if (match.auraColor != null) ...[
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: auraColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: auraColor!.withValues(alpha: 0.7),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              match.auraColor!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.getTextPrimary(isDark),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (match.auraFrequency != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.waves,
                              size: 14,
                              color: AppColors.getSecondaryIconColor(isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              match.auraFrequency!.toStringAsFixed(0),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.getTextSecondary(isDark),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (match.user.zodiacSign != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              Helpers.getZodiacEmoji(match.user.zodiacSign!),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              match.user.zodiacSign!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.getTextTertiary(isDark),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.getContainerBackground(isDark),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.getContainerBorder(isDark),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.getSecondaryIconColor(isDark),
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

  Widget _buildBlockedUsersSection(bool isDark) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentUser = userProvider.user;
        if (currentUser == null) return const SizedBox.shrink();
        
        final blockedUserIds = currentUser.blockedUsers;
        if (blockedUserIds.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: AppColors.getModernCardDecoration(isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.block,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.blockedUsers,
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.getTextPrimary(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.blockedUsersDesc,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.getTextSecondary(isDark),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    AppStrings.blockedUsersEmpty,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: AppColors.getModernCardDecoration(isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.block,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.blockedUsers,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.getTextPrimary(isDark),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.blockedUsersDesc,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.getTextSecondary(isDark),
                ),
              ),
              const SizedBox(height: 16),
              ...blockedUserIds.map((blockedUserId) => FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(blockedUserId).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const SizedBox.shrink();
                  }
                  
                  final blockedUser = UserModel.fromFirestore(snapshot.data!);
                  
                  return _buildBlockedUserCard(blockedUser, isDark);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlockedUserCard(UserModel blockedUser, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.getInputBorderColor(isDark),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                blockedUser.name.isNotEmpty ? blockedUser.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Kullanıcı bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blockedUser.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.getTextPrimary(isDark),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (blockedUser.zodiacSign != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    blockedUser.zodiacSign!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Engeli kaldır butonu
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _unblockUser(blockedUser),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.block,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.unblockUser,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unblockUser(UserModel blockedUser) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Onay dialog'u göster
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppStrings.unblockUser),
          content: Text(AppStrings.unblockUserConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
              child: Text(AppStrings.unblockUser),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      final currentUser = userProvider.user;
      if (currentUser == null) return;

      // Kullanıcının engelini kaldır
      final success = await userProvider.unblockUser(blockedUser.id);
      
      if (!success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? AppStrings.errorOccurred),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // social_requests koleksiyonundaki blocked status'ü güncelle
      // İki durum var: blockedUser'dan currentUser'a veya currentUser'dan blockedUser'a
      try {
        // currentUser ile ilgili tüm istekleri bul (fromUserId veya toUserId = currentUser.id)
        // Security rules'a uygun olması için status filtresini client-side'da yapacağız
        final requestsAsFrom = await _firestore
            .collection('social_requests')
            .where('fromUserId', isEqualTo: currentUser.id)
            .get();

        final requestsAsTo = await _firestore
            .collection('social_requests')
            .where('toUserId', isEqualTo: currentUser.id)
            .get();

        // Client-side'da filtrele: blockedUser ile ilgili ve status: "blocked" olanları bul
        final batch = _firestore.batch();
        bool hasUpdates = false;
        
        // fromUserId = currentUser.id olan istekler
        for (final doc in requestsAsFrom.docs) {
          final data = doc.data();
          final toUserId = data['toUserId']?.toString();
          final status = data['status']?.toString();
          
          // blockedUser'a gönderilen ve status: "blocked" olan istekleri bul
          if (toUserId == blockedUser.id && status == 'blocked') {
            batch.update(doc.reference, {
              'status': 'rejected',
              'updatedAt': FieldValue.serverTimestamp(),
            });
            hasUpdates = true;
          }
        }
        
        // toUserId = currentUser.id olan istekler
        for (final doc in requestsAsTo.docs) {
          final data = doc.data();
          final fromUserId = data['fromUserId']?.toString();
          final status = data['status']?.toString();
          
          // blockedUser'dan gelen ve status: "blocked" olan istekleri bul
          if (fromUserId == blockedUser.id && status == 'blocked') {
            batch.update(doc.reference, {
              'status': 'rejected',
              'updatedAt': FieldValue.serverTimestamp(),
            });
            hasUpdates = true;
          }
        }
        
        if (hasUpdates) {
          await batch.commit();
        }
      } catch (e) {
        // social_requests güncelleme hatası - sessizce devam et
        print('Error updating social_requests: $e');
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.userUnblocked),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Listeyi yenile
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.errorOccurred} $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

class _ChatMatch {
  final String matchId;
  final UserModel user;
  final String? auraColor;
  final double? auraFrequency;
  final double score;
  final DateTime createdAt;
  final String status; // 'pending', 'accepted', 'rejected'
  final bool isInitiator; // Bu kullanıcı isteği gönderen mi?

  _ChatMatch({
    required this.matchId,
    required this.user,
    this.auraColor,
    this.auraFrequency,
    required this.score,
    required this.createdAt,
    this.status = 'accepted',
    this.isInitiator = false,
  });
}

class _SocialRequest {
  final String requestId;
  final UserModel user;
  final String? auraColor;
  final double? auraFrequency;
  final double score;
  final DateTime createdAt;
  final bool hasAuraCompatibility;

  _SocialRequest({
    required this.requestId,
    required this.user,
    this.auraColor,
    this.auraFrequency,
    required this.score,
    required this.createdAt,
    required this.hasAuraCompatibility,
  });
}


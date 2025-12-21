import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/pricing_constants.dart';
import '../../core/providers/user_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/widgets/mystical_dialog.dart';
import '../../core/widgets/mystical_button.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/fortune/karma_cost_badge.dart';
import '../../core/services/ads_service.dart';
import '../../core/services/firebase_service.dart';
import '../../core/utils/helpers.dart';

class SoulmateAnalysisScreen extends StatefulWidget {
  const SoulmateAnalysisScreen({super.key});

  @override
  State<SoulmateAnalysisScreen> createState() => _SoulmateAnalysisScreenState();
}

class _SoulmateAnalysisScreenState extends State<SoulmateAnalysisScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdsService _ads = AdsService();
  bool _loading = true;
  String? _error;
  List<_Candidate> _candidates = [];
  List<_Candidate> _allCandidates = []; // Tüm adaylar
  bool _showOnlyCompatible = false; // Sadece uyumlu kişileri göster
  String? _genderFilter; // null = all, 'male', 'female', 'other'
  bool _genderFilterUsed = false; // Cinsiyet filtresi kullanıldı mı?
  int _index = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.95);
    _loadCandidates();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _createMatchDocument({
    required String initiatorId,
    required UserModel currentUser,
    required UserModel targetUser,
    required double score,
    required bool hasAuraCompatibility,
  }) async {
    final existing = await _firestore
        .collection('matches')
        .where('users', arrayContains: currentUser.id)
        .get();

    for (final doc in existing.docs) {
      final users = List<String>.from(doc['users'] ?? []);
      if (users.contains(targetUser.id)) {
        return;
      }
    }

    await _firestore.collection('matches').add({
      'users': [currentUser.id, targetUser.id],
      'initiator': initiatorId,
      'status': 'accepted',
      'score': score,
      'hasAuraCompatibility': hasAuraCompatibility,
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _loadCandidates() async {
    try {
      final current = Provider.of<UserProvider>(context, listen: false).user;
      if (current == null) throw Exception(AppStrings.sessionNotFound);

      // Birth date is mandatory for social / aura matching
      if (current.birthDate == null) {
        setState(() {
          _error = AppStrings.birthDateRequiredForSocial;
          _loading = false;
        });
        return;
      }

      final snap = await _firestore.collection('users').limit(50).get();
      final others = snap.docs
          .where((d) => d.id != current.id)
          .map((d) => UserModel.fromFirestore(d))
          .where((u) =>
              u.birthDate != null &&
              u.ageGroup == current.ageGroup &&
              u.socialVisible &&
              !current.blockedUsers.contains(u.id) &&
              !u.blockedUsers.contains(current.id))
          .toList();

      final scored = others
          .map((u) => _Candidate(
                user: u, 
                score: _scoreUsers(current, u),
                auraCompatibility: _calculateAuraCompatibility(current, u),
              ))
          .toList()
        ..sort((a, b) => b.score.compareTo(a.score));

      if (mounted) {
        setState(() {
          _allCandidates = scored.take(20).toList();
          _candidates = _filterCandidates();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '${AppStrings.couldNotLoad} $e';
          _loading = false;
        });
      }
    }
  }

  Color? _getAuraColor(UserModel user) {
    final colorName = user.preferences['auraColor']?.toString();
    if (colorName == null) return null;
    return _parseColorFromName(colorName);
  }

  Color? _parseColorFromName(String name) {
    // Color names can be in Turkish or English, map both
    final colorMap = {
      // Turkish
      'Mor': const Color(0xFF9B59B6),
      'Mavi': const Color(0xFF3498DB),
      'Yeşil': const Color(0xFF2ECC71),
      'Sarı': const Color(0xFFF1C40F),
      'Turuncu': const Color(0xFFE67E22),
      'Kırmızı': const Color(0xFFE74C3C),
      'Pembe': const Color(0xFFE91E63),
      'Indigo': const Color(0xFF6C5CE7),
      'Turkuaz': const Color(0xFF1ABC9C),
      // English
      'Purple': const Color(0xFF9B59B6),
      'Blue': const Color(0xFF3498DB),
      'Green': const Color(0xFF2ECC71),
      'Yellow': const Color(0xFFF1C40F),
      'Orange': const Color(0xFFE67E22),
      'Red': const Color(0xFFE74C3C),
      'Pink': const Color(0xFFE91E63),
      'Turquoise': const Color(0xFF1ABC9C),
    };
    return colorMap[name] ?? const Color(0xFF9B59B6);
  }

  List<_Candidate> _filterCandidates() {
    var filtered = _allCandidates;
    
    // Cinsiyet filtresi
    if (_genderFilter != null) {
      filtered = filtered.where((c) => c.user.gender == _genderFilter).toList();
    }
    
    // Aura uyumu filtresi
    if (_showOnlyCompatible) {
      filtered = filtered.where((c) => c.auraCompatibility > 0).toList();
    }
    
    return filtered;
  }

  void _toggleCompatibleFilter() {
    if (!mounted) return;
    setState(() {
      _showOnlyCompatible = !_showOnlyCompatible;
      _candidates = _filterCandidates();
      _index = 0; // İlk karta dön
      if (_candidates.isNotEmpty && _pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });
  }

  Future<void> _showGenderFilterDialog() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    if (user == null) return;

    const requiredKarma = 10;
    if (user.karma < requiredKarma) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.notEnoughKarma}. ${AppStrings.requiredKarma}: $requiredKarma ${AppStrings.karma}'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    final selectedGender = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          AppStrings.filterByGender,
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${AppStrings.genderFilterDesc} (${AppStrings.requiredKarma}: $requiredKarma ${AppStrings.karma})',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                AppStrings.allGenders,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              leading: Radio<String?>(
                value: null,
                groupValue: _genderFilter,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ),
            ListTile(
              title: Text(
                AppStrings.isEnglish ? 'Male' : 'Erkek',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              leading: Radio<String?>(
                value: 'male',
                groupValue: _genderFilter,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ),
            ListTile(
              title: Text(
                AppStrings.isEnglish ? 'Female' : 'Kadın',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              leading: Radio<String?>(
                value: 'female',
                groupValue: _genderFilter,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ),
            ListTile(
              title: Text(
                AppStrings.isEnglish ? 'Other' : 'Diğer',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              leading: Radio<String?>(
                value: 'other',
                groupValue: _genderFilter,
                onChanged: (value) => Navigator.pop(context, value),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );

    if (selectedGender == null) return; // İptal edildi

    // Karma kes
    final success = await userProvider.spendKarma(
      requiredKarma,
      AppStrings.genderFilterUsed,
    );

    if (!success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.notEnoughKarma}. ${AppStrings.requiredKarma}: $requiredKarma ${AppStrings.karma}'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _genderFilter = selectedGender;
      _genderFilterUsed = true;
      _candidates = _filterCandidates();
      _index = 0;
      if (_candidates.isNotEmpty && _pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.genderFilterUsed),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  double _calculateAuraCompatibility(UserModel a, UserModel b) {
    final aColor = a.preferences['auraColor']?.toString();
    final bColor = b.preferences['auraColor']?.toString();
    final aFreq = (a.preferences['auraFrequency'] as num?)?.toDouble() ?? 50.0;
    final bFreq = (b.preferences['auraFrequency'] as num?)?.toDouble() ?? 50.0;
    final aMood = a.preferences['auraMood']?.toString();
    final bMood = b.preferences['auraMood']?.toString();

    // Eğer aura rengi yoksa, sadece frekans uyumuna bak
    if (aColor == null || bColor == null) {
      final freqDiff = (aFreq - bFreq).abs();
      if (freqDiff < 15) return 20.0; // Frekans uyumu varsa uyumlu kabul et
      if (freqDiff < 25) return 15.0;
      return 0.0;
    }

    double score = 0;

    // Aura rengi uyumu (aynı renk = +35, uyumlu renkler = +20-25)
    if (aColor == bColor) {
      score += 35;
    } else {
      // Genişletilmiş uyumlu renk çiftleri
      // Note: Color names are stored in Turkish in database, but we check both
      final compatiblePairs = [
        ['Mor', 'Indigo', 'Pembe', 'Purple', 'Pink'], // Mor tonları
        ['Mavi', 'Turkuaz', 'Indigo', 'Blue', 'Turquoise'], // Mavi tonları
        ['Yeşil', 'Turkuaz', 'Mavi', 'Green', 'Blue'], // Yeşil-mavi tonları
        ['Sarı', 'Turuncu', 'Kırmızı', 'Yellow', 'Orange', 'Red'], // Sıcak tonlar
        ['Pembe', 'Kırmızı', 'Mor', 'Pink', 'Red', 'Purple'], // Pembe tonları
        ['Turuncu', 'Kırmızı', 'Sarı', 'Orange', 'Red', 'Yellow'], // Turuncu tonları
      ];
      
      bool isCompatible = false;
      int compatibilityLevel = 0;
      
      for (final pair in compatiblePairs) {
        final aIndex = pair.indexOf(aColor);
        final bIndex = pair.indexOf(bColor);
        
        if (aIndex != -1 && bIndex != -1) {
          isCompatible = true;
          // Aynı grupta ama farklı renkler
          final distance = (aIndex - bIndex).abs();
          if (distance == 0) {
            compatibilityLevel = 3; // Aynı renk (zaten yukarıda kontrol edildi)
          } else if (distance == 1) {
            compatibilityLevel = 2; // Çok yakın renkler
          } else {
            compatibilityLevel = 1; // Aynı grupta ama uzak
          }
          break;
        }
      }
      
      if (isCompatible) {
        if (compatibilityLevel == 2) {
          score += 25; // Çok uyumlu renkler
        } else if (compatibilityLevel == 1) {
          score += 20; // Uyumlu renkler
        }
      } else {
        // Uyumlu değilse ama yine de bazı kombinasyonlar kabul edilebilir
        // Örneğin: Mor-Mavi, Yeşil-Sarı gibi
        final neutralPairs = [
          ['Mor', 'Mavi', 'Purple', 'Blue'],
          ['Yeşil', 'Sarı', 'Green', 'Yellow'],
          ['Mavi', 'Yeşil', 'Blue', 'Green'],
        ];
        for (final pair in neutralPairs) {
          if (pair.contains(aColor) && pair.contains(bColor)) {
            score += 15; // Nötr uyum
            break;
          }
        }
      }
    }

    // Frekans uyumu (yakın frekanslar = +25, orta yakın = +15, uzak = +5)
    final freqDiff = (aFreq - bFreq).abs();
    if (freqDiff < 10) {
      score += 25; // Çok yakın frekanslar
    } else if (freqDiff < 20) {
      score += 15; // Yakın frekanslar
    } else if (freqDiff < 30) {
      score += 10; // Orta yakın frekanslar
    } else if (freqDiff < 40) {
      score += 5; // Biraz uzak ama kabul edilebilir
    }

    // Ruh hali uyumu (+15)
    if (aMood != null && bMood != null) {
      final positiveMoods = AppStrings.positiveMoods;
      final negativeMoods = AppStrings.negativeMoods;
      final neutralMoods = AppStrings.isEnglish 
          ? ['Normal', 'Balanced', 'Calm']
          : ['Normal', 'Dengeli', 'Sakin'];
      
      if ((positiveMoods.contains(aMood) && positiveMoods.contains(bMood)) ||
          (negativeMoods.contains(aMood) && negativeMoods.contains(bMood)) ||
          (neutralMoods.contains(aMood) && neutralMoods.contains(bMood))) {
        score += 15;
      } else if ((positiveMoods.contains(aMood) && neutralMoods.contains(bMood)) ||
                 (neutralMoods.contains(aMood) && positiveMoods.contains(bMood))) {
        score += 10; // Pozitif-nötr uyumu
      }
    }

    return score;
  }

  double _scoreUsers(UserModel a, UserModel b) {
    double score = 0;

    // Burç uyumu (30%)
    if (a.zodiacSign != null && b.zodiacSign != null) {
      if (a.zodiacSign == b.zodiacSign) {
        score += 30;
      } else {
        // Uyumlu burç çiftleri (basit mantık)
        score += 10;
      }
    }

    // Yaş uyumu (20%)
    if (a.birthDate != null && b.birthDate != null) {
      final ageDiff = (a.age - b.age).abs();
      if (ageDiff <= 2) {
        score += 20;
      } else if (ageDiff <= 5) {
        score += 15;
      } else if (ageDiff <= 10) {
        score += 10;
      }
    }

    // Aura uyumu (40%) - En önemli faktör
    score += _calculateAuraCompatibility(a, b);

    // Rastgele varyasyon (10%)
    score += math.Random().nextDouble() * 10;

    return score.clamp(0, 100);
  }

  void _next() {
    if (_index < _candidates.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _connectWith(_Candidate c) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final current = userProvider.user;
      if (current == null) throw Exception(AppStrings.sessionNotFound);
      final target = c.user;

      // Karma veya ücretsiz eşleşme kontrolü
      final auraMatchCost = PricingConstants.auraMatchCost;
      final freeMatches = current.freeAuraMatches;
      final isPremium = current.isPremium;
      
      // Premium kullanıcılar için sadece ücretsiz eşleşme hakkı kullanılabilir
      // Normal kullanıcılar için karma kontrolü yapılır
      final hasFreeMatch = isPremium && freeMatches > 0;
      final hasEnoughKarma = !isPremium && current.karma >= auraMatchCost;
      
      // Debug modunda premium kullanıcılar için ücretsiz eşleşme, normal kullanıcılar için karma kontrolü
      // UserProvider'da isPremium debug modunda true döndürüyor, bu yüzden gerçek premium kontrolü için
      // Firestore'dan gelen isPremium değerini kullanıyoruz (current.isPremium)
      final canConnect = hasFreeMatch || hasEnoughKarma;
      
      if (!canConnect) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Gerekli',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$auraMatchCost',
                              style: AppTextStyles.headingSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Karma',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.all(16),
            elevation: 8,
          ),
        );
        return;
      }

      // Aura uyumu kontrolü - _calculateAuraCompatibility fonksiyonunu kullan
      // Eğer aura uyum skoru 20'den fazlaysa uyumlu kabul et
      final auraCompatibilityScore = _calculateAuraCompatibility(current, target);
      final hasAuraCompatibility = auraCompatibilityScore >= 20.0;

      // Age-group safety: do not allow cross-age requests
      if (current.ageGroup != target.ageGroup) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.ageGroupMismatchError),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Zaten accepted match var mı?
      final existingMatchQuery = await _firestore
          .collection('matches')
          .where('users', arrayContains: target.id)
          .get();

      bool alreadyMatched = false;
      for (final doc in existingMatchQuery.docs) {
        final users = List<String>.from(doc.data()['users'] ?? []);
        if (users.contains(current.id) && users.contains(target.id)) {
          alreadyMatched = true;
          break;
        }
      }

      if (alreadyMatched) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.matchAlreadyExists),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      // Karşı taraftan gelen bekleyen istek var mı?
      final incomingRequest = await _firestore
          .collection('social_requests')
          .where('fromUserId', isEqualTo: target.id)
          .where('toUserId', isEqualTo: current.id)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (incomingRequest.docs.isNotEmpty) {
        final requestId = incomingRequest.docs.first.id;
        await _firestore.collection('social_requests').doc(requestId).update({
          'status': 'accepted',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await _createMatchDocument(
          initiatorId: target.id,
          currentUser: current,
          targetUser: target,
          score: c.score,
          hasAuraCompatibility: hasAuraCompatibility,
        );

        if (!mounted) return;
        
        // Reklam göster
        _showInterstitialAd();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.matchAccepted} ${target.name}! ${AppStrings.matchEstablished}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
        return;
      }

      // Daha önce bu kullanıcıya gönderilmiş bekleyen istek var mı?
      final outgoingRequest = await _firestore
          .collection('social_requests')
          .where('fromUserId', isEqualTo: current.id)
          .where('toUserId', isEqualTo: target.id)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (outgoingRequest.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.requestAlreadySent),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      {
        // Yeni istek gönder - önce confirmation dialog göster
        final confirmed = await MysticalDialog.showConfirm(
          context: context,
          title: AppStrings.sendRequest,
          message: AppStrings.sendConnectionRequestTo.replaceAll('{0}', target.name),
          confirmText: AppStrings.confirm,
          cancelText: AppStrings.cancel,
          onConfirm: () async {
            try {
              // Dialog onayından sonra tekrar kontrol et (kullanıcı durumu değişmiş olabilir)
              final updatedUser = userProvider.user;
              if (updatedUser == null) {
                if (!mounted) return;
                await MysticalDialog.showError(
                  context: context,
                  title: AppStrings.errorOccurred,
                  message: AppStrings.sessionNotFound,
                );
                return;
              }
              
              final updatedFreeMatches = updatedUser.freeAuraMatches;
              final updatedIsPremium = updatedUser.isPremium;
              final updatedHasFreeMatch = updatedIsPremium && updatedFreeMatches > 0;
              final updatedHasEnoughKarma = !updatedIsPremium && updatedUser.karma >= auraMatchCost;
              
              if (!updatedHasFreeMatch && !updatedHasEnoughKarma) {
                if (!mounted) return;
                if (updatedIsPremium) {
                  await MysticalDialog.showError(
                    context: context,
                    title: AppStrings.errorOccurred,
                    message: AppStrings.noFreeMatchesLeft,
                  );
                } else {
                  // Modern karma requirement widget
                  await MysticalDialog.show(
                    context: context,
                    title: AppStrings.errorOccurred,
                    content: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.9),
                                  AppColors.secondary.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Gerekli',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '$auraMatchCost',
                                          style: AppTextStyles.headingMedium.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                            height: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Karma',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: Colors.white.withValues(alpha: 0.95),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            height: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    type: MysticalDialogType.error,
                  );
                }
                return;
              }
              
              // Karma kes veya ücretsiz eşleşme kullan
              if (!kDebugMode) {
                if (updatedHasFreeMatch) {
                  // Ücretsiz eşleşme kullan
                  final success = await userProvider.useFreeAuraMatch();
                  if (!success) {
                    if (!mounted) return;
                    await MysticalDialog.showError(
                      context: context,
                      title: AppStrings.errorOccurred,
                      message: AppStrings.freeMatchNotAvailable,
                    );
                    return;
                  }
                } else {
                  // Karma kes
                  final success = await userProvider.spendKarma(
                    auraMatchCost,
                    'Aura eşleşmesi',
                  );
                  if (!success) {
                    if (!mounted) return;
                    await MysticalDialog.showError(
                      context: context,
                      title: AppStrings.errorOccurred,
                      message: AppStrings.notEnoughKarma,
                    );
                    return;
                  }
                }
              }
              
              await _firestore.collection('social_requests').add({
                'fromUserId': updatedUser.id,
                'toUserId': target.id,
                'status': 'pending',
                'score': c.score,
                'hasAuraCompatibility': hasAuraCompatibility,
                'createdAt': FieldValue.serverTimestamp(),
                'updatedAt': FieldValue.serverTimestamp(),
              });
              
              // Record quest completion for aura match
              try {
                final firebaseService = FirebaseService();
                final completedQuests = await firebaseService.getCompletedQuests(updatedUser.id);
                if (!completedQuests.contains('aura_match')) {
                  await firebaseService.recordQuestCompletion(updatedUser.id, 'aura_match');
                  // Add karma reward
                  final questReward = PricingConstants.getQuestById('aura_match')?['karma'] as int? ?? 2;
                  await userProvider.addKarma(
                    questReward,
                    'Görev tamamlandı: Aura eşleşmesi',
                  );
                }
              } catch (e) {
                // Quest completion error - silent fail
              }
              
              if (!mounted) return;
              
              // Reklam göster
              _showInterstitialAd();
              
              await MysticalDialog.showSuccess(
                context: context,
                title: AppStrings.requestSent,
                message: '${AppStrings.requestSent} ${target.name}!',
              );
            } catch (e) {
              if (!mounted) return;
              await MysticalDialog.showError(
                context: context,
                title: AppStrings.errorOccurred,
                message: '${AppStrings.connectionCouldNotBeEstablished} $e',
              );
            }
          },
        );
        
        // Eğer kullanıcı iptal ettiyse hiçbir şey yapma
        if (confirmed != true) return;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.connectionCouldNotBeEstablished} $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(body: Center(child: MysticalLoading(type: MysticalLoadingType.crystal, message: AppStrings.searchingMatches)));
    if (_error != null) return Scaffold(body: Center(child: Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: Colors.redAccent))));
    if (_candidates.isEmpty) return _buildEmptyState();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.premiumDarkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemCount: _candidates.length,
                  itemBuilder: (context, index) {
                    return Center(
                      child: _CandidateCardWrapper(
                        candidate: _candidates[index],
                        onConnect: () => _connectWith(_candidates[index]),
                        onNext: _next,
                        getAuraColor: _getAuraColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              _showOnlyCompatible
                  ? AppStrings.noCompatiblePersonFound
                  : AppStrings.noSuitableMatchFound,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            if (_showOnlyCompatible) ...[
              const SizedBox(height: 24),
              MysticalButton(
                text: AppStrings.showAll,
                onPressed: _toggleCompatibleFilter,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Text(
              AppStrings.auraMatch,
              style: AppTextStyles.headingMedium.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
               return GestureDetector(
                 onTap: _showGenderFilterDialog,
                 child: Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: _genderFilterUsed ? AppColors.mysticPurpleAccent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                     shape: BoxShape.circle,
                     border: Border.all(
                       color: _genderFilterUsed ? AppColors.mysticPurpleAccent : Colors.white.withOpacity(0.2),
                     ),
                   ),
                   child: Icon(
                     Icons.tune, 
                     color: _genderFilterUsed ? AppColors.mysticPurpleAccent : Colors.white, 
                     size: 20
                   ),
                 ),
               );
            }
          ),
        ],
      ),
    );
  }

  Future<void> _showInterstitialAd() async {
    await _ads.createInterstitialAd(
      adUnitId: _ads.interstitialAdUnitId,
      onAdLoaded: (ad) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _ads.createInterstitialAd(
              adUnitId: _ads.interstitialAdUnitId,
            );
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
          },
        );
        ad.show();
      },
      onAdFailedToLoad: (error) {
        if (kDebugMode) {
          print('❌ Interstitial ad failed to load: $error');
        }
      },
    );
  }
}

class _Candidate {
  final UserModel user;
  final double score;
  final double auraCompatibility;
  _Candidate({
    required this.user, 
    required this.score,
    required this.auraCompatibility,
  });
}


class _CandidateCardWrapper extends StatefulWidget {
  final _Candidate candidate;
  final VoidCallback onConnect;
  final VoidCallback onNext;
  final Color? Function(UserModel) getAuraColor;

  const _CandidateCardWrapper({
    required this.candidate,
    required this.onConnect,
    required this.onNext,
    required this.getAuraColor,
  });

  @override
  State<_CandidateCardWrapper> createState() => _CandidateCardWrapperState();
}

class _CandidateCardWrapperState extends State<_CandidateCardWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

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

  void _handleTap() async {
    if (!_isPressed) {
      setState(() => _isPressed = true);
      await _controller.forward();
      widget.onConnect();
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() => _isPressed = false);
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.candidate.user;
    final auraColor = widget.getAuraColor(u) ?? AppColors.mysticPurpleAccent;
    final auraName = u.preferences['auraColor']?.toString() ?? 'Mystic';

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.animateTo(1.0, curve: Curves.easeOutQuad);
      },
      onTapUp: (_) => _handleTap(),
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double t = _controller.value;
          double scale = 1.0 - (0.05 * t);
          double tilt = 0.15 * t;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..scale(scale)
              ..rotateX(tilt),
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.06),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Stack(
              children: [
                // Chromatic Aberration
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: auraColor.withOpacity(0.1), width: 2),
                    ),
                  ),
                ),
                
                // Ambient Aura Background
                Positioned(
                  top: -50,
                  left: 0,
                  right: 0,
                  height: 350,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topCenter,
                        radius: 1.2,
                        colors: [
                          auraColor.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Content
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Avatar & Aura Orb
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOut,
                              builder: (context, value, _) {
                                return Container(
                                  width: 180 + (10 * math.sin(value * math.pi * 2)),
                                  height: 180 + (10 * math.sin(value * math.pi * 2)),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: auraColor.withOpacity(0.3), width: 1),
                                    boxShadow: [
                                      BoxShadow(color: auraColor.withOpacity(0.2 * value), blurRadius: 40, spreadRadius: 10),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: auraColor.withOpacity(0.5), width: 3),
                                image: DecorationImage(
                                  image: NetworkImage(u.photoUrl ?? 'https://via.placeholder.com/150'),
                                  fit: BoxFit.cover,
                                ),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15),
                                ],
                              ),
                              child: u.photoUrl == null 
                                ? Center(child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 50, color: Colors.white)))
                                : null,
                            ),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [Colors.black87, auraColor.withOpacity(0.8)]),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      '%${widget.candidate.score.toInt()} ${AppStrings.isEnglish ? 'Match' : 'Uyum'}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Name & Details
                        Text(
                          '${u.name}, ${u.age}',
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$auraName Aura • ${Helpers.calculateZodiacSign(u.birthDate ?? DateTime(1990))}',
                          style: TextStyle(color: auraColor, fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        // Bio/Mood
                        if ((u.preferences['bio'] ?? u.job) != null && (u.preferences['bio'] ?? u.job)!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (u.preferences['bio'] ?? u.job)!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, fontSize: 15, fontStyle: FontStyle.italic),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        const SizedBox(height: 30),
                        // Action Buttons - Simplified for the beautiful card look
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: MysticalButton(
                                  text: AppStrings.isEnglish ? 'Connect' : 'Bağlan',
                                  onPressed: widget.onConnect,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: widget.onNext,
                                icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 30),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
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

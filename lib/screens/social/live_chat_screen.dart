import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/providers/user_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/widgets/mystical_card.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/utils/helpers.dart';
import '../../providers/theme_provider.dart';
import 'chat_detail_screen.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _loading = true;
  List<_ChatMatch> _matches = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMatches();
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

      // Kullanıcının eşleşmelerini yükle (aura uyumlu olanlar)
      final matchesSnapshot = await _firestore
          .collection('matches')
          .where('users', arrayContains: currentUser.id)
          .where('hasAuraCompatibility', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final matches = <_ChatMatch>[];

      for (final matchDoc in matchesSnapshot.docs) {
        final data = matchDoc.data();
        final users = List<String>.from(data['users'] ?? []);
        final otherUserId = users.firstWhere((id) => id != currentUser.id, orElse: () => '');

        if (otherUserId.isEmpty) continue;

        // Diğer kullanıcının bilgilerini yükle
        final otherUserDoc = await _firestore.collection('users').doc(otherUserId).get();
        if (!otherUserDoc.exists) continue;

        final otherUser = UserModel.fromFirestore(otherUserDoc);
        final auraColor = otherUser.preferences['auraColor']?.toString();
        final auraFrequency = (otherUser.preferences['auraFrequency'] as num?)?.toDouble();

        matches.add(_ChatMatch(
          matchId: matchDoc.id,
          user: otherUser,
          auraColor: auraColor,
          auraFrequency: auraFrequency,
          score: (data['score'] as num?)?.toDouble() ?? 0.0,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ));
      }

      if (mounted) {
        setState(() {
          _matches = matches;
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.premiumDarkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _loading
                    ? Center(
                        child: MysticalLoading(
                          type: MysticalLoadingType.spinner,
                          size: 32,
                          color: Colors.white,
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _matches.isEmpty
                            ? Center(
                                child: MysticalCard(
                                  enforceAspectRatio: false,
                                  toggleFlipOnTap: false,
                                  padding: EdgeInsets.zero,
                                  child: Container(
                                    width: 340,
                                    padding: const EdgeInsets.all(24),
                                    constraints: const BoxConstraints(minHeight: 140),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.secondary.withValues(alpha: 0.2),
                                          AppColors.cardBackground.withValues(alpha: 0.8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('✨', style: TextStyle(fontSize: 48)),
                                        const SizedBox(height: 16),
                                        Text(
                                          AppStrings.noAuraMatchesYet,
                                          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          AppStrings.connectFromSoulmateAnalysis,
                                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _matches.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildChatMatchCard(_matches[index]),
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

  Widget _buildHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = AppColors.getTextPrimary(isDark);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: textColor),
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.liveChat,
            style: AppTextStyles.headingLarge.copyWith(color: textColor),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.karmaGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_matches.length} ${AppStrings.matches}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMatchCard(_ChatMatch match) {
    final auraColor = _parseColorFromName(match.auraColor);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (auraColor != null)
            BoxShadow(
              color: auraColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cardBackground.withValues(alpha: 0.95),
                  AppColors.cardBackground.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: auraColor != null
                  ? Border.all(
                      color: auraColor.withValues(alpha: 0.5),
                      width: 1.5,
                    )
                  : null,
            ),
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
                                AppColors.surface.withValues(alpha: 0.9),
                                AppColors.surface.withValues(alpha: 0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              match.user.name.isNotEmpty ? match.user.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (match.auraFrequency != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.waves,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              match.auraFrequency!.toStringAsFixed(0),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white70,
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
                                color: Colors.white60,
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
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
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

class _ChatMatch {
  final String matchId;
  final UserModel user;
  final String? auraColor;
  final double? auraFrequency;
  final double score;
  final DateTime createdAt;

  _ChatMatch({
    required this.matchId,
    required this.user,
    this.auraColor,
    this.auraFrequency,
    required this.score,
    required this.createdAt,
  });
}

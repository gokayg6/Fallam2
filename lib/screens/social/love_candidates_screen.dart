import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../core/models/love_candidate_model.dart';
import '../../core/services/firebase_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../providers/theme_provider.dart';
import '../../core/providers/user_provider.dart';
import 'love_candidate_form_screen.dart';
import 'love_compatibility_result_screen.dart';
import '../../screens/astrology/daily_astrology_screen.dart';
import '../../screens/astrology/astrology_calendar_screen.dart';

class LoveCandidatesScreen extends StatefulWidget {
  const LoveCandidatesScreen({super.key});

  @override
  State<LoveCandidatesScreen> createState() => _LoveCandidatesScreenState();
}

class _LoveCandidatesScreenState extends State<LoveCandidatesScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  List<LoveCandidateModel> _candidates = [];
  bool _loading = true;
  
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Optimized for 120Hz
    );
    _loadCandidates();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    setState(() => _loading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;
      if (userId == null) {
        setState(() {
          _candidates = [];
          _loading = false;
        });
        return;
      }

      final candidates = await _firebaseService.getLoveCandidates(userId);
      if (mounted) {
        setState(() {
          _candidates = candidates;
          _loading = false;
        });
        _animController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _candidates = [];
          _loading = false;
        });
      }
    }
  }

  Future<void> _deleteCandidate(LoveCandidateModel candidate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Adayı Sil',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '${candidate.name} adayını silmek istediğinize emin misiniz?',
          style: TextStyle(
            fontFamily: 'SF Pro Text',
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF6B9D),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userId = userProvider.user?.id;
        if (userId != null) {
          await _firebaseService.deleteLoveCandidate(userId, candidate.id);
          _loadCandidates();
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
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white.withValues(alpha: 0.9),
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Aşk Adaylarım',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.warmIvory,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.backgroundGradient,
        ),
        child: SafeArea(
          child: _loading
              ? Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFFFF6B9D),
                  ),
                )
              : Column(
                  children: [
                    // Header Card - Liquid Glass
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.12),
                                  const Color(0xFFFF6B9D).withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                                            const Color(0xFFFF8FB1).withValues(alpha: 0.15),
                                          ],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text('💕', style: TextStyle(fontSize: 22)),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Aşk Uyumu Analizi',
                                            style: TextStyle(
                                              fontFamily: 'SF Pro Display',
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.warmIvory,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Burç ve doğum bilgilerine göre uyum analizi',
                                            style: TextStyle(
                                              fontFamily: 'SF Pro Text',
                                              fontSize: 13,
                                              color: Colors.white.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Add Button
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoveCandidateFormScreen(),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadCandidates();
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFFFF6B9D).withValues(alpha: 0.4),
                                              const Color(0xFFFF8FB1).withValues(alpha: 0.25),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: const Color(0xFFFF6B9D).withValues(alpha: 0.5),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_rounded,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Yeni Aday Ekle',
                                              style: TextStyle(
                                                fontFamily: 'SF Pro Display',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
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
                          ),
                        ),
                      ),
                    ),
                    
                    // Candidates List
                    Expanded(
                      child: _candidates.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _candidates.length,
                              itemBuilder: (context, index) {
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 280 + (index * 60)), // Optimized for 120Hz
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOutQuart,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, (1 - value) * 30),
                                      child: Opacity(
                                        opacity: value.clamp(0.0, 1.0),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _buildCandidateCard(_candidates[index]),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.15),
                  ),
                  child: const Center(
                    child: Text('💔', style: TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Henüz aday yok',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warmIvory,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hoşlandığın kişileri ekle ve\naşk uyumunu keşfet!',
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
      ),
    );
  }

  Widget _buildCandidateCard(LoveCandidateModel candidate) {
    final zodiacEmoji = Helpers.getZodiacEmoji(candidate.zodiacSign);
    final score = candidate.lastCompatibilityScore;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoveCompatibilityResultScreen(
                candidate: candidate,
              ),
            ),
          );
          if (result == true) {
            _loadCandidates();
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.10),
                    const Color(0xFFFF6B9D).withValues(alpha: 0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF6B9D).withValues(alpha: 0.35),
                          const Color(0xFFFF8FB1).withValues(alpha: 0.2),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 2,
                      ),
                      image: candidate.avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(candidate.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withValues(alpha: 0.25),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: candidate.avatarUrl == null
                        ? Center(
                            child: Text(
                              candidate.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.name,
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warmIvory,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(zodiacEmoji, style: const TextStyle(fontSize: 12)),
                                  const SizedBox(width: 4),
                                  Text(
                                    candidate.zodiacSign,
                                    style: TextStyle(
                                      fontFamily: 'SF Pro Text',
                                      fontSize: 11,
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (score != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFFF6B9D),
                                      const Color(0xFFFF8FB1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '%${score.toInt()}',
                                  style: const TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 12,
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
                  // Action Buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildActionButton(
                        Icons.auto_graph_rounded,
                        'Grafik',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DailyAstrologyScreen(candidate: candidate),
                          ),
                        ),
                      ),
                      _buildActionButton(
                        Icons.calendar_today_rounded,
                        'Takvim',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AstrologyCalendarScreen(candidate: candidate),
                          ),
                        ),
                      ),
                      _buildActionButton(
                        Icons.delete_outline_rounded,
                        'Sil',
                        () => _deleteCandidate(candidate),
                        isDelete: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onTap, {bool isDelete = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: isDelete
              ? Colors.red.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDelete
              ? Colors.red.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/widgets/mystical_dialog.dart';
import '../../core/widgets/liquid_glass_widgets.dart';
import '../../core/services/firebase_service.dart';
import 'edit_profile_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  
  bool _isLoading = false;
  int _totalFortunesCount = 0;
  int _favoriteFortunesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTotalFortunes();
    _loadFavoriteFortunes();
  }

  Future<void> _loadTotalFortunes() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (userId != null) {
        final docs = await FirebaseService().getUserFortunesFromReadings(userId);
        if (mounted) {
          setState(() {
            _totalFortunesCount = docs.length;
          });
        }
      }
    } catch (e) {
      print('Error loading total fortunes: $e');
    }
  }

  Future<void> _loadFavoriteFortunes() async {
    try {
      final userId = Provider.of<UserProvider>(context, listen: false).user?.id;
      if (userId != null) {
        final docs = await FirebaseService().getUserFortunesFromReadings(userId);
        final favoriteCount = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['isFavorite'] == true;
        }).length;
        if (mounted) {
          setState(() {
            _favoriteFortunesCount = favoriteCount;
          });
        }
      }
    } catch (e) {
      print('Error loading favorite fortunes: $e');
    }
  }

  void _signOut() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.isGuest) {
      final confirmed = await MysticalDialog.show(
        context: context,
        title: AppStrings.signingOut,
        type: MysticalDialogType.warning,
        customIcon: Icons.warning_amber_rounded,
        customIconColor: AppColors.warning,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.guestSignOutWarning,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildWarningItem(AppStrings.allFortunesWillBeDeleted),
            const SizedBox(height: 8),
            _buildWarningItem(AppStrings.karmaPointsWillBeLost),
            const SizedBox(height: 8),
            _buildWarningItem(AppStrings.profileInfoWillBeDeleted),
            const SizedBox(height: 8),
            _buildWarningItem(AppStrings.cannotAccessAccountAgain),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                AppStrings.areYouSureSignOut,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        confirmText: AppStrings.signOut,
        cancelText: AppStrings.cancel,
        onConfirm: () {
          Navigator.of(context).pop(true);
        },
        onCancel: () {
          Navigator.of(context).pop(false);
        },
      );

      if (confirmed != true) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await userProvider.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(showSignOutSuccess: true),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.error}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    }
  }

  Widget _buildWarningItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.error.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.close_rounded,
            color: AppColors.error,
            size: 12,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.warning, color: AppColors.error, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppStrings.deleteAccount,
                    style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.thisActionCannotBeUndone,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppStrings.areYouSureDeleteAccount}'
                    '${AppStrings.allPersonalDataWillBeDeleted}'
                    '${AppStrings.fortuneHistoryWillBeLost}'
                    '${AppStrings.karmaPointsWillBeReset}'
                    '${AppStrings.premiumMembershipWillBeCancelled}'
                    '${AppStrings.thisActionIsPermanent}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppStrings.cancel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              LiquidGlassButton(
                text: AppStrings.deleteAccount,
                color: AppColors.error,
                height: 44,
                onPressed: _isLoading ? null : () async {
                  Navigator.pop(context);
                  await _deleteAccount(userProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAccount(UserProvider userProvider) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await userProvider.deleteAccount();
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.accountDeletedSuccessfully),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                userProvider.error ?? AppStrings.errorDeletingAccount,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.errorDeletingAccountWithError} $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: themeProvider.backgroundGradient,
          ),
      child: SafeArea(
        child: LiquidGlassScreenWrapper(
          duration: const Duration(milliseconds: 700),
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (userProvider.isLoading) {
                return Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withOpacity(0.1) : AppColors.premiumLightSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white.withOpacity(0.15) : AppColors.premiumLightTextSecondary.withOpacity(0.2),
                          ),
                        ),
                        child: MysticalLoading(
                          type: MysticalLoadingType.crystal,
                          message: AppStrings.profileLoading,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildProfileCard(userProvider),
                    const SizedBox(height: 20),
                    _buildStatsCard(userProvider),
                    const SizedBox(height: 20),
                    _buildSettingsSection(),
                    const SizedBox(height: 20),
                    _buildThemeSettingsSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(userProvider),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  },
);
  }

  Widget _buildHeader() {
    return LiquidGlassHeader(
      title: AppStrings.profile,
    );
  }

  Widget _buildProfileCard(UserProvider userProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(28),
      blurAmount: 30,
      glowColor: LiquidGlassColors.liquidGlassActive(isDark),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
          // Avatar with glass effect
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.5),
                      LiquidGlassColors.liquidGlassSecondary(isDark).withOpacity(0.4),
                      LiquidGlassColors.liquidGlassTertiary(isDark).withOpacity(0.3),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    userProvider.user?.name != null && userProvider.user!.name.isNotEmpty
                        ? userProvider.user!.name[0].toUpperCase()
                        : 'M',
                    style: AppTextStyles.headingLarge.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.white,
                LiquidGlassColors.shimmerColor(isDark),
              ],
            ).createShader(bounds),
            child: Text(
              userProvider.user?.name ?? AppStrings.guest,
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.getTextPrimary(isDark),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (userProvider.user?.email != null) ...[
            const SizedBox(height: 8),
            Text(
              userProvider.user?.email ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Karma badge with glass effect
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.karma.withOpacity(0.35),
                      AppColors.karma.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.karma.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.karma.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.karma,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${userProvider.user?.karma ?? 0} Karma',
                      style: AppTextStyles.karmaDisplay.copyWith(
                        color: AppColors.karma,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(UserProvider userProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    return LiquidGlassSection(
      title: AppStrings.statistics,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LiquidGlassStatItem(
                  title: AppStrings.totalFortunes,
                  value: '$_totalFortunesCount',
                  icon: Icons.auto_awesome,
                  iconColor: LiquidGlassColors.liquidGlassActive(isDark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LiquidGlassStatItem(
                  title: AppStrings.favorites,
                  value: '$_favoriteFortunesCount',
                  icon: Icons.favorite,
                  iconColor: Colors.pink[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LiquidGlassStatItem(
                  title: AppStrings.memberSince,
                  value: _formatDate(userProvider.user?.createdAt ?? DateTime.now()),
                  icon: Icons.calendar_today,
                  iconColor: const Color(0xFF82B4D9),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LiquidGlassStatItem(
                  title: AppStrings.lastLogin,
                  value: _formatDate(userProvider.user?.lastLoginAt ?? DateTime.now()),
                  icon: Icons.login,
                  iconColor: const Color(0xFF7CC4A4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return LiquidGlassSection(
      title: AppStrings.settings,
      child: Column(
        children: [
          _buildLanguageSettingItem(),
          const SizedBox(height: 10),
          LiquidGlassSettingItem(
            title: AppStrings.privacy,
            icon: Icons.privacy_tip,
            onTap: () => _showPrivacyDialog(context),
          ),
          const SizedBox(height: 10),
          LiquidGlassSettingItem(
            title: AppStrings.help,
            icon: Icons.help,
            onTap: () => _showHelpDialog(context),
          ),
          const SizedBox(height: 10),
          LiquidGlassSettingItem(
            title: AppStrings.about,
            icon: Icons.info,
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettingItem() {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return LiquidGlassSettingItem(
          title: _isEnglish ? 'Language' : 'Dil',
          subtitle: languageProvider.isTurkish 
              ? (_isEnglish ? 'Turkish' : 'Türkçe')
              : (_isEnglish ? 'English' : 'İngilizce'),
          icon: Icons.language,
          onTap: () => _showLanguageDialog(context, languageProvider),
        );
      },
    );
  }

  bool get _isEnglish {
    try {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      return languageProvider.isEnglish;
    } catch (e) {
      return false;
    }
  }

  Widget _buildThemeSettingsSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        return LiquidGlassSection(
          title: AppStrings.themeSettings,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.3),
                          LiquidGlassColors.liquidGlassSecondary(isDark).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.getIconColor(isDark),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    themeProvider.isDarkThemeSelected ? AppStrings.darkTheme : AppStrings.lightTheme,
                    style: TextStyle(
                      color: AppColors.getTextSecondary(isDark),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: themeProvider.isDarkThemeSelected,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeColor: LiquidGlassColors.liquidGlassActive(isDark),
                activeTrackColor: LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(UserProvider userProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    return Column(
      children: [
        if (userProvider.user != null) ...[
          _buildLiquidGlassActionButton(
            text: AppStrings.editProfile,
            icon: Icons.edit_outlined,
            color: LiquidGlassColors.liquidGlassActive(isDark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildLiquidGlassActionButton(
            text: AppStrings.deleteAccount,
            icon: Icons.delete_outline,
            color: AppColors.error,
            onPressed: _isLoading ? null : () => _showDeleteAccountDialog(userProvider),
          ),
          const SizedBox(height: 12),
        ],
        _buildLiquidGlassActionButton(
          text: userProvider.user != null ? AppStrings.signOut : AppStrings.signIn,
          icon: userProvider.user != null ? Icons.logout : Icons.login,
          color: userProvider.user != null ? AppColors.error : LiquidGlassColors.liquidGlassActive(isDark),
          isLoading: _isLoading,
          onPressed: _isLoading ? null : () {
            if (userProvider.user != null) {
              _signOut();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildLiquidGlassActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.25),
                  color.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    text,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: color.withOpacity(0.7),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    var diff = now.difference(local);
    if (diff.isNegative) diff = Duration.zero;

    if (diff.inMinutes < 1) return AppStrings.now;
    if (diff.inMinutes < 60) return '${diff.inMinutes} ${AppStrings.minAgo}';
    if (diff.inHours < 24) return '${diff.inHours} ${AppStrings.hoursAgo}';
    if (diff.inDays < 7) return '${diff.inDays} ${AppStrings.daysAgoShort}';
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}';
  }

  Future<void> _showLanguageDialog(BuildContext context, LanguageProvider languageProvider) async {
    final selectedLanguage = await showDialog<String>(
      context: context,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AlertDialog(
            backgroundColor: AppColors.mysticPurpleMid.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: AppColors.mysticPurpleAccent.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.mysticPurpleAccent.withOpacity(0.4),
                        AppColors.mysticMagenta.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mysticPurpleAccent.withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.language, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.selectLanguage,
                  style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: AppLanguage.values.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final lang = AppLanguage.values[index];
                  final isSelected = languageProvider.currentLanguage == lang;
                  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                  final isDark = themeProvider.isDarkMode;
                  return _buildLanguageOptionNew(
                    lang.name,
                    lang.code,
                    isSelected,
                    lang.isRTL,
                    () => Navigator.pop(context, lang.code),
                    isDark,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    if (selectedLanguage != null && mounted) {
      await languageProvider.setLanguageByCode(selectedLanguage);
      
      if (mounted) {
        MysticLoading.show(context, message: AppStrings.loading);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          await MysticLoading.hide(context);
          setState(() {});
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.languageChangedSuccessfully),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  Widget _buildLanguageOptionNew(
    String name,
    String code,
    bool isSelected,
    bool isRTL,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.mysticPurpleAccent.withOpacity(0.5),
                    AppColors.mysticMagenta.withOpacity(0.4),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.04),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? AppColors.mysticPurpleAccent.withOpacity(0.6)
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.mysticPurpleAccent.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Row(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    String trText,
    String enText,
    String languageCode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final isEnglish = _isEnglish;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        LiquidGlassColors.liquidGlassActive(isDarkMode).withOpacity(0.4),
                        LiquidGlassColors.liquidGlassSecondary(isDarkMode).withOpacity(0.3),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? LiquidGlassColors.liquidGlassActive(isDarkMode).withOpacity(0.5)
                    : Colors.white.withOpacity(0.15),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: LiquidGlassColors.liquidGlassActive(isDarkMode).withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? LiquidGlassColors.liquidGlassActive(isDarkMode)
                      : Colors.white.withOpacity(0.6),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isEnglish ? enText : trText,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Text(
                  languageCode == 'tr' ? '🇹🇷' : '🇬🇧',
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.3),
                        LiquidGlassColors.liquidGlassSecondary(isDark).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.privacy_tip, color: LiquidGlassColors.liquidGlassActive(isDark)),
                ),
                const SizedBox(width: 10),
                Text(AppStrings.privacy, style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.privacyPolicy,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppStrings.privacyPolicyDesc}${AppStrings.privacyPolicyPoints}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),
                  _buildPolicyLinksInDialog(isDark),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.close, style: AppTextStyles.bodyMedium.copyWith(color: LiquidGlassColors.liquidGlassActive(isDark))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyLinksInDialog(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.byPurchasingYouAccept,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildPolicyLink(
              AppStrings.privacyPolicyLink,
              'https://www.loegs.com/falla/PrivacyPolicy.html',
              isDark,
            ),
            Text(', ', style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.6))),
            _buildPolicyLink(
              AppStrings.userAgreementLink,
              'https://www.loegs.com/falla/UserAgreement.html',
              isDark,
            ),
            Text(', ', style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.6))),
            _buildPolicyLink(
              AppStrings.termsOfServiceLink,
              'https://www.loegs.com/falla/TermsOfService.html',
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPolicyLink(String text, String url, bool isDark) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: LiquidGlassColors.liquidGlassActive(isDark),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.3),
                        LiquidGlassColors.liquidGlassSecondary(isDark).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.help, color: LiquidGlassColors.liquidGlassActive(isDark)),
                ),
                const SizedBox(width: 10),
                Text(AppStrings.help, style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.helpAndSupport,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppStrings.helpDesc}${AppStrings.helpPoints}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.questionsContact,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'falla@loegs.com',
                    style: AppTextStyles.bodySmall.copyWith(color: LiquidGlassColors.liquidGlassActive(isDark)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.close, style: AppTextStyles.bodyMedium.copyWith(color: LiquidGlassColors.liquidGlassActive(isDark))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    showDialog(
      context: context,
      builder: (context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.3),
                        LiquidGlassColors.liquidGlassSecondary(isDark).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.info, color: LiquidGlassColors.liquidGlassActive(isDark)),
                ),
                const SizedBox(width: 10),
                Text(AppStrings.about, style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.3),
                                LiquidGlassColors.liquidGlassSecondary(isDark).withOpacity(0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: LiquidGlassColors.liquidGlassActive(isDark).withOpacity(0.4),
                            ),
                          ),
                          child: Image.asset(
                            'assets/icons/fallalogo.png',
                            width: 60,
                            height: 60,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('🔮', style: TextStyle(fontSize: 32));
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.white, LiquidGlassColors.shimmerColor(isDark)],
                      ).createShader(bounds),
                      child: Text(
                        'Falla v1.0.0',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppStrings.mysticalFortuneApp}${AppStrings.fallaWith}${AppStrings.fallaFeatures}${AppStrings.copyright}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.7)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.close, style: AppTextStyles.bodyMedium.copyWith(color: LiquidGlassColors.liquidGlassActive(isDark))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
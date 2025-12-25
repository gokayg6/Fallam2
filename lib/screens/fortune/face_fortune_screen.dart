import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'fortune_result_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/pricing_constants.dart';
import '../../core/models/fortune_model.dart' as fm;
import '../../core/models/fortune_type.dart';
import '../../core/services/fortune_service.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/widgets/glassmorphism_components.dart';
import '../../core/services/ads_service.dart';
import '../../widgets/fortune/karma_cost_badge.dart';
import '../../core/providers/user_provider.dart';
import 'dart:async';

class FaceFortuneScreen extends StatefulWidget {
  const FaceFortuneScreen({Key? key}) : super(key: key);

  @override
  State<FaceFortuneScreen> createState() => _FaceFortuneScreenState();
}

class _FaceFortuneScreenState extends State<FaceFortuneScreen> {
  final FortuneService _fortuneService = FortuneService();
  final ImagePicker _imagePicker = ImagePicker();
  final AdsService _ads = AdsService();
  String? _question;
  List<File> _selectedImages = [];

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      _showError('${AppStrings.photoSelectionError} $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      _showError('${AppStrings.photoCaptureError} $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<void> _generate() async {
    if (_selectedImages.isEmpty) {
      _showError(AppStrings.pleaseSelectAtLeastOneFacePhoto);
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final requiredKarma = PricingConstants.getFortuneCost('face');
    
    if (!kDebugMode) {
      if (!(userProvider.user?.canUseDailyFortune ?? false)) {
        if ((userProvider.user?.karma ?? 0) < requiredKarma) {
          _showError(AppStrings.karmaRequired.replaceAll('{0}', requiredKarma.toString()));
          return;
        }
        
        final karmaSpent = await userProvider.spendKarma(requiredKarma, AppStrings.faceFortune);
        if (!karmaSpent) {
          _showError(AppStrings.karmaRequired.replaceAll('{0}', requiredKarma.toString()));
          return;
        }
      }
    }
    
    try {
      MysticLoading.show(context);
      final imageUrls = await _fortuneService.uploadImages(_selectedImages);
      
      final result = await _fortuneService.generateFortune(
        type: FortuneType.face,
        inputData: {'imageUrls': imageUrls},
        question: _question,
      );

      final fm.FortuneModel adapted = fm.FortuneModel(
        id: result.id,
        userId: result.userId,
        type: fm.FortuneType.face,
        status: fm.FortuneStatus.completed,
        title: result.title,
        interpretation: result.interpretation,
        inputData: const {},
        selectedCards: result.selectedCards,
        imageUrls: result.imageUrls,
        question: result.question,
        createdAt: result.createdAt,
        completedAt: result.createdAt,
        isFavorite: result.isFavorite,
        rating: result.rating.toInt(),
        notes: null,
        isForSelf: true,
        targetPersonName: null,
        metadata: result.metadata,
        karmaUsed: kDebugMode ? 0 : requiredKarma,
        isPremium: false,
      );

      if (!mounted) return;
      await MysticLoading.hide(context);

      try {
        final loaded = Completer<bool>();
        await _ads.createInterstitialAd(
          adUnitId: _ads.interstitialAdUnitId,
          onAdLoaded: (_) => loaded.complete(true),
          onAdFailedToLoad: (_) => loaded.complete(false),
        );
        bool ok = false;
        try { ok = await loaded.future.timeout(const Duration(seconds: 2)); } catch (_) {}
        if (ok) { await _ads.showInterstitialAd(); }
      } catch (_) {}

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FortuneResultScreen(fortune: adapted)),
      );
    } catch (e) {
      await MysticLoading.hide(context);
      _showError('${AppStrings.faceFortuneCreationError}: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return PremiumScaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildIntroCard(),
                    const SizedBox(height: 16),
                    _buildImageUploadSection(isDark),
                    const SizedBox(height: 16),
                    _buildQuestionInput(isDark),
                  ],
                ),
              ),
            ),
            _buildGenerateBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return RepaintBoundary(
      child: ClipRRect(
        child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isDark 
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.white.withOpacity(0.05),
                    ],
                  )
                : AppColors.champagneGoldGradient.scale(0.8),
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.champagneGold.withOpacity(0.2) : AppColors.champagneGold.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.05),
                        isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.1) : AppColors.premiumLightTextSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.getIconColor(isDark),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.champagneGold.withOpacity(0.3),
                            AppColors.champagneGold.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        'assets/icons/face.png',
                        width: 28, height: 28,
                        errorBuilder: (_,__,___) => Icon(Icons.face, color: AppColors.champagneGold, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.faceFortune,
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.getTextPrimary(isDark),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Yüzünün Anlattıkları',
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 12,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const KarmaCostBadge(fortuneType: 'face'),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return GlassCard(
      isHero: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/face.png',
            width: 64,
            height: 64,
            errorBuilder: (_, __, ___) => const Text('👤', style: TextStyle(fontSize: 48)),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.faceFortuneDesc,
            style: PremiumTextStyles.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(bool isDark) {
    return GlassCard(
      child: Column(
        children: [
          Text(AppStrings.facePhotos, style: PremiumTextStyles.section),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildUploadButton(Icons.photo_library, AppStrings.selectFromGallery, _pickImages)),
              const SizedBox(width: 12),
              Expanded(child: _buildUploadButton(Icons.camera_alt, AppStrings.takePhoto, _takePhoto)),
            ],
          ),
          const SizedBox(height: 8),
          Text(AppStrings.facePhotosClearDesc, style: PremiumTextStyles.caption, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          _buildSelectedImagesArea(isDark),
        ],
      ),
    );
  }

  Widget _buildUploadButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.champagneGold.withOpacity(0.2),
                  AppColors.champagneGold.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.champagneGold.withOpacity(0.3), width: 1),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.champagneGold, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.champagneGold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedImagesArea(bool isDark) {
    if (_selectedImages.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.face_outlined, color: AppColors.getIconColor(isDark).withOpacity(0.4), size: 36),
                const SizedBox(height: 10),
                Text(AppStrings.noPhotoSelected, style: PremiumTextStyles.body),
              ],
            ),
          ),
        ),
      );
    }

    return GlassContainer(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionInput(bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.problemOptional, style: PremiumTextStyles.section),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: TextField(
                onChanged: (v) => setState(() => _question = v.trim().isEmpty ? null : v.trim()),
                style: TextStyle(color: AppColors.getTextPrimary(isDark), fontFamily: 'SF Pro Text'),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  hintText: AppStrings.exampleFuture,
                  hintStyle: TextStyle(color: AppColors.getTextSecondary(isDark).withOpacity(0.7)),
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : AppColors.premiumLightTextSecondary.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : AppColors.premiumLightTextSecondary.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.champagneGold, width: 1.5),
                  ),
                ),
                maxLines: 2,
              ),
              ),
            ),

        ],
      ),
    );
  }

  Widget _buildGenerateBar(bool isDark) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final hasImages = _selectedImages.isNotEmpty;
        final requiredKarma = PricingConstants.getFortuneCost('face');
        final canUseFortune = kDebugMode || 
                             (userProvider.user?.canUseDailyFortune ?? false) || 
                             (userProvider.user?.karma ?? 0) >= requiredKarma;
        final canGenerate = hasImages && canUseFortune;
        
        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.8),
                    isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.9),
                  ],
                ),
                border: Border(
                  top: BorderSide(color: isDark ? Colors.white.withOpacity(0.15) : AppColors.champagneGold.withOpacity(0.3), width: 0.5),
                ),
              ),
              child: GlassButton(
                text: hasImages ? AppStrings.createFortune : AppStrings.uploadPhoto,
                icon: Icons.auto_awesome,
                onPressed: canGenerate ? _generate : null,
                width: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }
}

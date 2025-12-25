import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/widgets/liquid_glass_navbar.dart';
import '../../core/widgets/liquid_glass_widgets.dart';
import '../../core/widgets/mystical_loading.dart';
import '../../core/widgets/image_viewer.dart';
import '../../core/models/fortune_model.dart' as fm;
import 'fortune_result_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/mystical_button.dart';

class DreamDrawScreen extends StatefulWidget {
  final String? initialPrompt;
  const DreamDrawScreen({super.key, this.initialPrompt});

  @override
  State<DreamDrawScreen> createState() => _DreamDrawScreenState();
}

class _DreamDrawScreenState extends State<DreamDrawScreen> {
  final TextEditingController _promptController = TextEditingController();
  final AIService _ai = AIService();
  final ScrollController _scrollController = ScrollController();

  String _style = AppStrings.dreamDrawStyles.first;
  bool _isLoading = false;
  Uint8List? _imageBytes;
  String? _error;
  final FirebaseService _firebase = FirebaseService();

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null && widget.initialPrompt!.trim().isNotEmpty) {
      _promptController.text = widget.initialPrompt!.trim();
    }
  }

  Future<void> _generate() async {
    final base = _promptController.text.trim();
    if (base.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.youMustWriteDream)),
      );
      return;
    }

    // Quick connectivity check to avoid DNS errors on emulator/devices
    try {
      final res = await InternetAddress.lookup('api.openai.com');
      if (res.isEmpty || res.first.rawAddress.isEmpty) {
        throw const SocketException('No DNS result');
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.noInternetConnection),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final prompt = AppStrings.dreamVisualizePrompt
        .replaceAll('{0}', base)
        .replaceAll('{1}', _style);

    setState(() {
      _isLoading = true;
      _error = null;
      _imageBytes = null;
    });

    try {
      MysticLoading.show(context);
      final bytes = await _ai.generateMysticImage(
        prompt: prompt,
        width: 1024,
        height: 1024,
      );
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error scrolling to bottom: $e');
          }
        }
      });

      // Upload image to Storage and save to readings collection
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (!mounted) return;
        await MysticLoading.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.userLoginRequired), backgroundColor: Colors.red),
        );
        return;
      }

      // Upload image to Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = 'dream_draws/${userId}/${timestamp}.jpg';
      final imageUrl = await _firebase.uploadImage(imagePath, bytes);
      
      if (imageUrl == null) {
        if (!mounted) return;
        await MysticLoading.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.imageCouldNotBeUploaded), backgroundColor: Colors.red),
        );
        return;
      }

      // Save to readings collection as a fortune result
      final docRef = FirebaseFirestore.instance.collection('readings').doc();
      final fortuneData = {
        'userId': userId,
        'type': 'dream',
        'title': AppStrings.dreamDrawing,
        'interpretation': '${AppStrings.dreamVisualized}: $base',
        'imageUrls': [imageUrl],
        'createdAt': FieldValue.serverTimestamp(),
        'rating': 0.0,
        'isFavorite': false,
        'metadata': {
          'source': 'dream_draw',
          'prompt': base,
          'style': _style,
          'availableAt': DateTime.now().add(Duration(minutes: 15 + (DateTime.now().millisecond % 11))).toIso8601String(),
          'waitMinutes': 15 + (DateTime.now().millisecond % 11),
        },
      };
      await docRef.set(fortuneData);

      // Create FortuneModel and navigate to result screen
      final adapted = fm.FortuneModel(
        id: docRef.id,
        userId: userId,
        type: fm.FortuneType.dream,
        status: fm.FortuneStatus.completed,
        title: AppStrings.dreamDrawing,
        interpretation: '${AppStrings.isEnglish ? "Your dream has been visualized" : "Rüyanız görselleştirildi"}: $base',
        imageUrls: [imageUrl],
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        isFavorite: false,
        rating: 0,
        metadata: {
          'source': 'dream_draw',
          'prompt': base,
          'style': _style,
        },
      );

      if (!mounted) return;
      await MysticLoading.hide(context);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FortuneResultScreen(fortune: adapted),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '${AppStrings.imageCouldNotBeGenerated} $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error!), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        await MysticLoading.hide(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: themeProvider.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPromptCard(),
                      const SizedBox(height: 16),
                      _buildStyleCard(),
                      const SizedBox(height: 20),
                      if (_isLoading)
                        LiquidGlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: MysticalLoading(
                              type: MysticalLoadingType.spinner,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      if (_error != null)
                        LiquidGlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: Colors.redAccent)),
                        ),
                      if (_imageBytes != null) ...[
                        const SizedBox(height: 20),
                        _buildImageResultCard(),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: _buildGenerateButton(),
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
    final textColor = Colors.white; 
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LiquidGlassCard(
        borderRadius: 20,
        blurAmount: 15,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                AppStrings.drawMyDreamTitle, 
                style: AppTextStyles.headingLarge.copyWith(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Text('🎨', style: TextStyle(fontSize: 20)),
             const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptCard() => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return LiquidGlassCard(
        padding: const EdgeInsets.all(20),
        blurAmount: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.describeYourDream,
              style: AppTextStyles.headingSmall.copyWith(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              decoration: InputDecoration(
                hintText: AppStrings.dreamDrawExampleHint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD700)),
                ),
                contentPadding: const EdgeInsets.all(16),
                filled: true,
                fillColor: Colors.black.withOpacity(0.2),
              ),
              maxLines: 5,
              minLines: 3,
            ),
          ],
        ),
      );
    },
  );

  Widget _buildStyleCard() => Consumer<ThemeProvider>(
    builder: (context, themeProvider, child) {
      return LiquidGlassCard(
        padding: const EdgeInsets.all(20),
        blurAmount: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectStyle,
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildStyleChips(),
          ],
        ),
      );
    },
  );

  Widget _buildImageResultCard() => LiquidGlassCard(
    padding: EdgeInsets.zero,
    child: InkWell(
      onTap: () => ImageViewer.show(
        context: context,
        imageBytes: _imageBytes,
        title: AppStrings.dreamDrawing,
      ),
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
        ),
      ),
    ),
  );

  Widget _buildStyleChips() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        
    final styles = AppStrings.dreamDrawStyles;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: styles.map((s) {
        final selected = s == _style;
        return ChoiceChip(
          label: Text(
            s,
            style: AppTextStyles.bodySmall.copyWith(
                  color: selected 
                      ? Colors.black
                      : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          selected: selected,
          onSelected: (v) {
            if (v) setState(() => _style = s);
          },
          selectedColor: const Color(0xFFFFD700),
          backgroundColor: Colors.white.withOpacity(0.1),
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? Colors.transparent : Colors.white24,
            ),
          ),
        );
      }).toList(),
        );
      },
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: MysticalButton(
        onPressed: _isLoading ? null : _generate,
        text: _isLoading ? AppStrings.drawing : AppStrings.drawMyDreamButton,
        showGlow: true,
        customGradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF673AB7)]),
        isLoading: _isLoading,
        icon: Icons.auto_awesome,
      ),
    );
  }
}


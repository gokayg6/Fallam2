import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'dart:io';
import '../../core/services/firebase_service.dart';
import '../../core/utils/helpers.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../core/providers/user_provider.dart';

class LoveCandidateFormScreen extends StatefulWidget {
  const LoveCandidateFormScreen({super.key});

  @override
  State<LoveCandidateFormScreen> createState() => _LoveCandidateFormScreenState();
}

class _LoveCandidateFormScreenState extends State<LoveCandidateFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _firebaseService = FirebaseService();
  final _picker = ImagePicker();
  
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  DateTime? _birthDate;
  String? _zodiacSign;
  String? _relationshipType;
  File? _avatarFile;
  String? _avatarUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Optimized for 120Hz
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutExpo),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutExpo));
    
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _avatarFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resim seçilemedi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onBirthDateChanged(DateTime? date) {
    if (date != null) {
      setState(() {
        _birthDate = date;
        _zodiacSign = Helpers.calculateZodiacSign(date);
      });
    }
  }

  Future<void> _saveCandidate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen doğum tarihi seçin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;
      if (userId == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // Upload avatar if selected
      String? finalAvatarUrl = _avatarUrl;
      if (_avatarFile != null) {
        try {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imagePath = 'love_candidates/$userId/$timestamp.jpg';
          final imageBytes = await _avatarFile!.readAsBytes();
          finalAvatarUrl = await _firebaseService.uploadImage(imagePath, imageBytes);
          if (finalAvatarUrl == null) {
            throw Exception('Resim yüklenemedi');
          }
        } catch (e) {
          if (mounted) {
            setState(() => _saving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Resim yükleme hatası: $e'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }
      }

      // Create candidate
      final candidateData = {
        'userId': userId,
        'name': _nameController.text.trim(),
        'avatarUrl': finalAvatarUrl,
        'birthDate': Timestamp.fromDate(_birthDate!),
        'zodiacSign': _zodiacSign!,
        'relationshipType': _relationshipType,
      };

      await _firebaseService.createLoveCandidate(userId, candidateData);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Aşk Adayı Ekle',
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
        decoration: const BoxDecoration(
          gradient: AppColors.premiumDarkGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 20),
                    
                    // Avatar Selection - Liquid Glass
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                                    const Color(0xFFFF8FB1).withValues(alpha: 0.15),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                                image: _avatarFile != null
                                    ? DecorationImage(
                                        image: FileImage(_avatarFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : (_avatarUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(_avatarUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null),
                              ),
                              child: _avatarFile == null && _avatarUrl == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_rounded,
                                          color: Colors.white.withValues(alpha: 0.8),
                                          size: 32,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Fotoğraf',
                                          style: TextStyle(
                                            fontFamily: 'SF Pro Text',
                                            fontSize: 12,
                                            color: Colors.white.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Name Field - Liquid Glass
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: TextFormField(
                            controller: _nameController,
                            style: TextStyle(
                              fontFamily: 'SF Pro Text',
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            decoration: InputDecoration(
                              labelText: 'İsim / Takma Ad',
                              labelStyle: TextStyle(
                                fontFamily: 'SF Pro Text',
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              hintText: 'Adayın adını girin',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              prefixIcon: Icon(
                                Icons.person_rounded,
                                color: const Color(0xFFFF6B9D).withValues(alpha: 0.8),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(20),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'İsim gereklidir';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Birth Date Picker - Liquid Glass
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFFF6B9D),
                                  surface: Color(0xFF1A1B2E),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        _onBirthDateChanged(date);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _birthDate != null
                                    ? const Color(0xFFFF6B9D).withValues(alpha: 0.4)
                                    : Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    color: const Color(0xFFFF6B9D),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Doğum Tarihi',
                                        style: TextStyle(
                                          fontFamily: 'SF Pro Text',
                                          fontSize: 13,
                                          color: Colors.white.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _birthDate != null
                                            ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                                            : 'Tarih seçin',
                                        style: TextStyle(
                                          fontFamily: 'SF Pro Display',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: _birthDate != null
                                              ? Colors.white.withValues(alpha: 0.9)
                                              : Colors.white.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_zodiacSign != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                                          const Color(0xFFFF8FB1).withValues(alpha: 0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFFF6B9D).withValues(alpha: 0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          Helpers.getZodiacEmoji(_zodiacSign!),
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _zodiacSign!,
                                          style: TextStyle(
                                            fontFamily: 'SF Pro Display',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Relationship Type Section
                    Text(
                      'İlişki Türü (Opsiyonel)',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        _buildRelationshipChip('crush', '💘 Hoşlandığım'),
                        const SizedBox(width: 8),
                        _buildRelationshipChip('partner', '💕 Sevgilim'),
                        const SizedBox(width: 8),
                        _buildRelationshipChip('ex', '💔 Eski'),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Save Button - Liquid Glass
                    GestureDetector(
                      onTap: _saving ? null : _saveCandidate,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF6B9D).withValues(alpha: 0.5),
                                  const Color(0xFFFF8FB1).withValues(alpha: 0.35),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFFF6B9D).withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _saving
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.favorite_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Kaydet ve Uyum Hesapla',
                                          style: TextStyle(
                                            fontFamily: 'SF Pro Display',
                                            fontSize: 17,
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
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelationshipChip(String value, String label) {
    final isSelected = _relationshipType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _relationshipType = isSelected ? null : value;
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [
                          const Color(0xFFFF6B9D).withValues(alpha: 0.4),
                          const Color(0xFFFF8FB1).withValues(alpha: 0.25),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B9D).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/animations/mystical_particles.dart';
import '../../widgets/animations/glow_effect.dart';
import '../../core/widgets/terms_of_service_dialog.dart';
import '../../core/widgets/mystical_dialog.dart';
import '../main/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscurePassword2 = true;
  DateTime? _selectedBirthDate;
  String? _selectedZodiacSign;
  String? _selectedGender;

  List<String> get _zodiacSigns {
    return [
      AppStrings.aries, AppStrings.taurus, AppStrings.gemini, 
      AppStrings.cancer, AppStrings.leo, AppStrings.virgo,
      AppStrings.libra, AppStrings.scorpio, AppStrings.sagittarius, 
      AppStrings.capricorn, AppStrings.aquarius, AppStrings.pisces
    ];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectBirthDate)),
      );
      return;
    }
    if (_selectedZodiacSign == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectZodiac)),
      );
      return;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseSelectGender)),
      );
      return;
    }

    // Show terms of service dialog first
    final accepted = await TermsOfServiceDialog.show(context);
    
    if (accepted != true) {
      // User rejected terms
      await MysticalDialog.showInfo(
        context: context,
        title: AppStrings.termsNotAccepted,
        message: AppStrings.termsMustBeAccepted,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.registerWithEmailAndPassword(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      _nameCtrl.text.trim(),
      _selectedBirthDate!,
      AppStrings.zodiacSignToTurkish(_selectedZodiacSign) ?? _selectedZodiacSign!,
      _selectedGender!,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (mounted) {
      _showErrorDialog(authProvider.errorMessage ?? AppStrings.registrationFailed);
    }
  }

  void _showErrorDialog(String message) {
    MysticalDialog.showError(
      context: context,
      title: AppStrings.registrationError,
      message: message,
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _selectedZodiacSign = _calculateZodiacSign(picked);
      });
    }
  }

  String _calculateZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return AppStrings.aries;
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return AppStrings.taurus;
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return AppStrings.gemini;
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return AppStrings.cancer;
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return AppStrings.leo;
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return AppStrings.virgo;
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return AppStrings.libra;
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return AppStrings.scorpio;
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return AppStrings.sagittarius;
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return AppStrings.capricorn;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return AppStrings.aquarius;
    return AppStrings.pisces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.premiumDarkGradient,
        ),
        child: Stack(
          children: [
            // Background particles
            const MysticalParticles(
              type: ParticleType.swirling,
              particleCount: 15,
              isActive: true,
            ),
            
            // Main content with glassmorphism
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo and title
                        _buildHeader(),
                        const SizedBox(height: 32),
                        
                        // Glassmorphism form container
                        ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.mysticPurpleAccent.withOpacity(0.15),
                                    blurRadius: 40,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Name field
                                    _buildNameField(),
                                    const SizedBox(height: 16),
                                    
                                    // Email field
                                    _buildEmailField(),
                                    const SizedBox(height: 16),
                                    
                                    // Password field
                                    _buildPasswordField(),
                                    const SizedBox(height: 16),
                                    
                                    // Confirm password field
                                    _buildConfirmPasswordField(),
                                    const SizedBox(height: 16),
                                    
                                    // Birth date field
                                    _buildBirthDateField(),
                                    const SizedBox(height: 16),
                                    
                                    // Zodiac sign field
                                    _buildZodiacField(),
                                    const SizedBox(height: 16),
                                    
                                    // Gender field
                                    _buildGenderField(),
                                    const SizedBox(height: 28),
                                    
                                    // Register button
                                    _buildRegisterButton(),
                                    const SizedBox(height: 16),
                                    
                                    // Login link
                                    _buildLoginLink(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo with mystic purple glow halo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.mysticMagenta,
                AppColors.mysticPurpleAccent,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.mysticMagenta.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: AppColors.mysticPurpleAccent.withOpacity(0.3),
                blurRadius: 50,
                spreadRadius: 20,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Image.asset(
            'assets/icons/fallalogo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.person_add,
              size: 50,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Shimmer title
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Colors.white,
              AppColors.mysticLavender,
              Colors.white,
            ],
          ).createShader(bounds),
          child: Text(
            AppStrings.register,
            style: AppTextStyles.headingLarge.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Subtitle with glassmorphic badge
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.mysticMagenta.withOpacity(0.3),
                ),
              ),
              child: Text(
                AppStrings.joinMysticalWorld,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: AppStrings.fullName,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(Icons.person_outline, color: Colors.white.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
      validator: Validators.name,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailCtrl,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: AppStrings.email,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withValues(alpha: 0.7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
      validator: Validators.email,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passCtrl,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: AppStrings.password,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.7)),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.white.withValues(alpha: 0.6)),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
      validator: Validators.password,
    );
  }

  Widget _buildConfirmPasswordField() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final inputBg = AppColors.getInputBackground(isDark);
    final inputTextColor = AppColors.getInputTextColor(isDark);
    final inputHintColor = AppColors.getInputHintColor(isDark);
    
    return TextFormField(
      controller: _pass2Ctrl,
      obscureText: _obscurePassword2,
      style: TextStyle(color: inputTextColor),
      decoration: InputDecoration(
        labelText: AppStrings.confirmPassword,
        labelStyle: TextStyle(color: inputHintColor),
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(_obscurePassword2 ? Icons.visibility : Icons.visibility_off, color: inputHintColor),
          onPressed: () => setState(() => _obscurePassword2 = !_obscurePassword2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: inputBg,
      ),
      validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
    );
  }

  Widget _buildBirthDateField() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final inputBg = AppColors.getInputBackground(isDark);
    final textColor = AppColors.getTextPrimary(isDark);
    final hintColor = AppColors.getTextSecondary(isDark);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.2);
    
    return GestureDetector(
      onTap: _selectBirthDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: inputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary.withOpacity(0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedBirthDate != null
                    ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                    : AppStrings.selectBirthDate,
                style: TextStyle(
                  color: _selectedBirthDate != null 
                      ? textColor 
                      : hintColor,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.primary.withOpacity(0.7)),
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacField() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final inputBg = AppColors.getInputBackground(isDark);
    final inputTextColor = AppColors.getInputTextColor(isDark);
    final inputHintColor = AppColors.getInputHintColor(isDark);
    final dropdownBg = AppColors.getCardBackground(isDark);
    
    return DropdownButtonFormField<String>(
      value: _selectedZodiacSign,
      style: TextStyle(color: inputTextColor),
      dropdownColor: dropdownBg,
      decoration: InputDecoration(
        labelText: AppStrings.zodiac,
        labelStyle: TextStyle(color: inputHintColor),
        prefixIcon: Icon(Icons.star, color: AppColors.primary.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: inputBg,
      ),
      items: _zodiacSigns.map((String zodiac) {
        return DropdownMenuItem<String>(
          value: zodiac,
          child: Text(zodiac),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedZodiacSign = newValue;
        });
      },
      validator: Validators.zodiacSign,
    );
  }

  Widget _buildGenderField() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final inputBg = AppColors.getInputBackground(isDark);
    final inputTextColor = AppColors.getTextPrimary(isDark);
    final inputHintColor = AppColors.getTextSecondary(isDark);
    final dropdownBg = AppColors.getCardBackground(isDark);
    
    final genderOptions = [
      AppStrings.isEnglish ? 'Male' : 'Erkek',
      AppStrings.isEnglish ? 'Female' : 'Kadın',
      AppStrings.isEnglish ? 'Other' : 'Diğer',
    ];
    
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      style: TextStyle(color: inputTextColor),
      dropdownColor: dropdownBg,
      decoration: InputDecoration(
        labelText: AppStrings.gender,
        labelStyle: TextStyle(color: inputHintColor),
        prefixIcon: Icon(Icons.people_outline, color: AppColors.primary.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: inputBg,
      ),
      items: genderOptions.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppStrings.pleaseSelectGender;
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return PremiumButton(
          text: AppStrings.register,
          onPressed: authProvider.isLoading ? null : _register,
          isLoading: authProvider.isLoading,
          icon: Icons.person_add,
        );
      },
    );
  }

  Widget _buildLoginLink() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textSecondaryColor = AppColors.getTextSecondary(isDark);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.alreadyHaveAccount,
          style: TextStyle(color: textSecondaryColor),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppStrings.login,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
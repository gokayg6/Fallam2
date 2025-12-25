import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/terms_of_service_dialog.dart';
import '../../core/widgets/mystical_dialog.dart';
import '../main/main_screen.dart';
import '../../providers/theme_provider.dart';
import 'login_screen.dart';
import 'package:flutter/cupertino.dart';
import '../../core/widgets/liquid_gender_switch.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePassword = true;
  DateTime? _selectedBirthDate;
  String? _selectedZodiacSign;
  String? _selectedGender;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<String> get _zodiacSigns {
    return [
      AppStrings.aries,
      AppStrings.taurus,
      AppStrings.gemini,
      AppStrings.cancer,
      AppStrings.leo,
      AppStrings.virgo,
      AppStrings.libra,
      AppStrings.scorpio,
      AppStrings.sagittarius,
      AppStrings.capricorn,
      AppStrings.aquarius,
      AppStrings.pisces
    ];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Show terms of service dialog first
    final accepted = await TermsOfServiceDialog.show(context);

    if (accepted != true) {
      await MysticalDialog.showInfo(
        context: context,
        title: AppStrings.termsNotAccepted,
        message: AppStrings.termsMustBeAccepted,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Use default values if not selected
    final birthDate =
        _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25));
    final zodiacSign = _selectedZodiacSign ?? _calculateZodiacSign(birthDate);
    final gender = _selectedGender ?? 'Other';

    final success = await authProvider.registerWithEmailAndPassword(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      _nameCtrl.text.trim(),
      birthDate,
      AppStrings.zodiacSignToTurkish(zodiacSign) ?? zodiacSign,
      gender,
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
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
      return AppStrings.sagittarius;
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19))
      return AppStrings.capricorn;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return AppStrings.aquarius;
    return AppStrings.pisces;
  }

  Future<void> _signUpWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // TODO: Implement Google Sign Up
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign Up coming soon!')),
    );
  }

  void _openTermsOfService() async {
    final url = Uri.parse('https://falla.app/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _openPrivacyPolicy() async {
    final url = Uri.parse('https://falla.app/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeProvider.backgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Top bar with logo and profile icon
                _buildTopBar(),
                const SizedBox(height: 24),
                // Title
                _buildTitle(),
                const SizedBox(height: 24),
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildForm(),
                        const SizedBox(height: 24),
                        // Terms text
                        _buildTermsText(),
                        const SizedBox(height: 32),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/fallalogo.png',
                width: 28,
                height: 28,
                color: const Color(0xFF5BC4BE),
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.auto_awesome,
                  size: 28,
                  color: Color(0xFF5BC4BE),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Falla',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // Profile icon placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Create Your\nAccount',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        height: 1.2,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Full Name field
                _buildTextField(
                  controller: _nameCtrl,
                  hintText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  validator: Validators.name,
                ),
                const SizedBox(height: 16),
                // Email field
                _buildTextField(
                  controller: _emailCtrl,
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                // Password field
                _buildTextField(
                  controller: _passCtrl,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                // Birthdate Picker
                _buildTextFieldWithAction(
                  hintText: 'Select Birth Date',
                  prefixIcon: Icons.calendar_today_rounded,
                  onTap: _showDatePicker,
                  value: _selectedBirthDate != null 
                      ? DateFormat('dd MMMM yyyy').format(_selectedBirthDate!)
                      : null,
                ),
                
                if (_selectedZodiacSign != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Zodiac: $_selectedZodiacSign',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],

                const SizedBox(height: 20),
                // Gender Switch
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Gender',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                LiquidGenderSwitch(
                  selectedGender: _selectedGender ?? 'Male',
                  onChanged: (val) {
                    setState(() => _selectedGender = val);
                  },
                ),
                
                const SizedBox(height: 24),
                // Sign Up button
                _buildSignUpButton(),
                const SizedBox(height: 20),
                // Divider
                _buildDivider(),
                const SizedBox(height: 20),
                // Google Sign Up button
                _buildGoogleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1814), // Dark background for contrast
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedBirthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
                    maximumDate: DateTime.now(),
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    onDateTimeChanged: (val) {
                      setState(() {
                        _selectedBirthDate = val;
                        _selectedZodiacSign = _calculateZodiacSign(val);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextFieldWithAction({
    required String hintText,
    required IconData prefixIcon,
    required VoidCallback onTap,
    String? value,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(prefixIcon, color: Colors.white.withOpacity(0.7), size: 22),
            const SizedBox(width: 12),
            Text(
              value ?? hintText,
              style: TextStyle(
                color: value != null ? Colors.white : AppColors.getInputHintColor(isDark),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: keyboardType,
      style: TextStyle(
        color: AppColors.getInputTextColor(isDark),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.getInputHintColor(isDark),
          fontSize: 16,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white.withOpacity(0.7),
          size: 22,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white.withOpacity(0.5),
                  size: 22,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildSignUpButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return GestureDetector(
          onTap: authProvider.isLoading ? null : _register,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF7B8CDE),
                  Color(0xFF8B7FD3),
                  Color(0xFFA78BDA),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B7FD3).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: authProvider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or sign up with',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return GestureDetector(
      onTap: _signUpWithGoogle,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google icon (using a simple G for now)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign Up with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          color: Colors.white.withOpacity(0.7),
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'By signing up, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
              color: Color(0xFF8BB8F8),
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = _openTermsOfService,
          ),
          const TextSpan(text: '\nand '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              color: Color(0xFF8BB8F8),
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = _openPrivacyPolicy,
          ),
        ],
      ),
    );
  }
}
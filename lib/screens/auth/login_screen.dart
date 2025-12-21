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
import '../../core/widgets/mystical_dialog.dart';
import 'register_screen.dart';
import '../main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool showSignOutSuccess;
  
  const LoginScreen({
    super.key,
    this.showSignOutSuccess = false,
  });
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;
  @override
  void initState() {
    super.initState();
    // Login ekranına yönlendirildikten sonra çıkış yapıldı mesajını göster
    if (widget.showSignOutSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          MysticalDialog.showSuccess(
            context: context,
            title: AppStrings.signedOut,
            message: AppStrings.isEnglish 
                ? 'You have been signed out successfully.'
                : 'Başarıyla çıkış yaptınız.',
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithEmailAndPassword(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (success && mounted) {
      // Başarılı giriş sonrası ana sayfaya yönlendir
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (mounted) {
      _showErrorDialog(authProvider.errorMessage ?? AppStrings.loginFailed);
    }
  }

  Future<void> _guest() async {
    // Misafir girişten önce doğum tarihi seçtir
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

    if (picked == null) {
      // Kullanıcı doğum tarihi seçmeden vazgeçti
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInAnonymously(birthDate: picked);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else if (mounted) {
      _showErrorDialog(authProvider.errorMessage ?? AppStrings.guestLoginFailed);
    }
  }

  void _showErrorDialog(String message) {
    MysticalDialog.showError(
      context: context,
      title: AppStrings.loginError,
      message: message,
    );
  }

  Future<void> _resetPassword() async {
    if (_emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseEnterEmail)),
      );
      return;
    }

    print('🔄 Şifre sıfırlama isteği: ${_emailCtrl.text.trim()}');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resetPassword(_emailCtrl.text.trim());

    if (success && mounted) {
      print('✅ Şifre sıfırlama başarılı');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.passwordResetEmailSent),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } else if (mounted) {
      print('❌ Şifre sıfırlama başarısız: ${authProvider.errorMessage}');
      _showErrorDialog(authProvider.errorMessage ?? AppStrings.passwordResetFailed);
    }
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
              type: ParticleType.floating,
              particleCount: 20,
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
                        const SizedBox(height: 40),
                        
                        // Glassmorphism form container
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Email field
                                _buildEmailField(),
                                const SizedBox(height: 20),
                                
                                // Password field
                                _buildPasswordField(),
                                const SizedBox(height: 12),
                                
                                // Forgot password
                                _buildForgotPassword(),
                                const SizedBox(height: 28),
                                
                                // Login button
                                _buildLoginButton(),
                                const SizedBox(height: 20),
                                
                                // Register link
                                _buildRegisterLink(),
                                const SizedBox(height: 24),
                                
                                // Divider
                                _buildDivider(),
                                const SizedBox(height: 24),
                                
                                // Guest button
                                _buildGuestButton(),
                              ],
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
        Image.asset(
          'assets/icons/fallalogo.png',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.auto_awesome,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Falla',
          style: AppTextStyles.headingLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.welcomeToMysticalWorld,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
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
          borderSide: BorderSide(color: AppColors.mysticPurpleAccent.withValues(alpha: 0.5), width: 1.5),
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
          borderSide: BorderSide(color: AppColors.mysticPurpleAccent.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
      validator: Validators.password,
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _resetPassword,
        child: Text(
          AppStrings.forgotPassword,
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return MysticalButton(
          text: AppStrings.login,
          onPressed: authProvider.isLoading ? null : _login,
          isLoading: authProvider.isLoading,
          icon: Icons.login,
        );
      },
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: const TextStyle(color: Colors.white70),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: Text(
            AppStrings.register,
            style: TextStyle(
              color: AppColors.mysticPurpleAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.or,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }

  Widget _buildGuestButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: authProvider.isLoading ? null : _guest,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (authProvider.isLoading)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    else ...[
                      const Icon(Icons.person_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.continueAsGuest,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

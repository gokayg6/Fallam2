import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

/// Supported languages enum
enum AppLanguage {
  turkish('tr', 'Türkçe', false),
  english('en', 'English', false),
  italian('it', 'Italiano', false),
  french('fr', 'Français', false),
  russian('ru', 'Русский', false),
  german('de', 'Deutsch', false),
  arabic('ar', 'العربية', true),
  persian('fa', 'فارسی', true);

  final String code;
  final String name;
  final bool isRTL;

  const AppLanguage(this.code, this.name, this.isRTL);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }
}

/// Dil yönetimi provider'ı
/// 8 dil desteği: TR, EN, IT, FR, RU, DE, AR, FA
class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  AppLanguage _currentLanguage = AppLanguage.english;
  bool _isInitialized = false;
  
  // Legacy getters for backward compatibility
  Locale get locale => Locale(_currentLanguage.code);
  String get languageCode => _currentLanguage.code;
  bool get isTurkish => _currentLanguage == AppLanguage.turkish;
  bool get isEnglish => _currentLanguage == AppLanguage.english;
  
  // New getters
  AppLanguage get currentLanguage => _currentLanguage;
  bool get isRTL => _currentLanguage.isRTL;
  String get languageName => _currentLanguage.name;
  
  // Language check helpers
  bool get isItalian => _currentLanguage == AppLanguage.italian;
  bool get isFrench => _currentLanguage == AppLanguage.french;
  bool get isRussian => _currentLanguage == AppLanguage.russian;
  bool get isGerman => _currentLanguage == AppLanguage.german;
  bool get isArabic => _currentLanguage == AppLanguage.arabic;
  bool get isPersian => _currentLanguage == AppLanguage.persian;

  LanguageProvider() {
    _initializeLanguage();
  }

  /// Get all available languages
  static List<AppLanguage> get availableLanguages => AppLanguage.values;

  /// Dil ayarlarını yükle ve başlat
  Future<void> _initializeLanguage() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage != null) {
        _currentLanguage = AppLanguage.fromCode(savedLanguage);
      } else {
        // Sistem dilini algıla
        final systemLocale = ui.PlatformDispatcher.instance.locale;
        _currentLanguage = AppLanguage.fromCode(systemLocale.languageCode);
        await prefs.setString(_languageKey, _currentLanguage.code);
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      final systemLocale = ui.PlatformDispatcher.instance.locale;
      _currentLanguage = AppLanguage.fromCode(systemLocale.languageCode);
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Dil değiştir ve kaydet
  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;
    _currentLanguage = language;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language.code);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
    
    notifyListeners();
  }

  /// Set language by code
  Future<void> setLanguageByCode(String code) async {
    await setLanguage(AppLanguage.fromCode(code));
  }

  // Legacy methods for backward compatibility
  Future<void> setTurkish() async => await setLanguage(AppLanguage.turkish);
  Future<void> setEnglish() async => await setLanguage(AppLanguage.english);
  Future<void> toggleLanguage() async {
    if (isTurkish) {
      await setEnglish();
    } else {
      await setTurkish();
    }
  }
}

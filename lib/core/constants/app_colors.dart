import 'package:flutter/material.dart';

class AppColors {
  // Ana renkler
  // Ana renkler
  static const Color primary = Color(0xFFFF4DA6); // Falla Magenta
  static const Color primaryDark = Color(0xFFD81B60);
  static const Color primarySoft = Color(0xFFFF80AB);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color glassLight = Color(0x1AFFFFFF);

  static const Color secondary = Color(0xFF3EE3D5); // Aura Aqua
  static const Color accent    = Color(0xFF8A7BFF); // Mistik Mor
  static const Color background= Color(0xFF0B1021); // Gece Laciverti
  static const Color surface   = Color(0xFF121735); // Derin Yüzey
  
  // Gradient renkler
  static const LinearGradient mysticalGradient = LinearGradient(
    colors: [Color(0xFF1D163C), Color(0xFF30206A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF80AB),
      Color(0xFFFF4DA6),
      Color(0xFFD81B60),
    ],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF9B51E0), Color(0xFF6A4C93)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE0C88F), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2B224F), Color(0xFF594099)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Background gradient (dark theme)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, Color(0xFF1A1A2E)],
  );
  
  // Background gradient (light theme) - Cream tones
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFDFBF7), Color(0xFFE6DCC3)],
  );
  
  // Karma gradient
  static const LinearGradient karmaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [karma, Color(0xFFF4E4BC)],
  );
  
  // Kart renkleri
  static const Color cardGlow = Color(0xFF6A4C93);
  static const Color cardShadow = Colors.black54;
  static const Color shadowColor = Colors.black;
  
  // Karma rengi
  static const Color karma = Color(0xFFE0C88F);
  
  // ==================== iOS 26 PREMIUM GLASSMORPHISM COLORS ====================
  
  // Mystic Purple Background Palette (Fal uygulaması için mistik mor tonlar)
  static const Color mysticPurpleDark = Color(0xFF0D0714);      // Çok koyu mor-siyah
  static const Color mysticPurpleMid = Color(0xFF1A0F2E);       // Orta koyu mor
  static const Color mysticViolet = Color(0xFF2D1B4E);          // Derin violet
  static const Color mysticPurpleAccent = Color(0xFF8B5CF6);    // Parlak mor aksan
  static const Color mysticMagenta = Color(0xFFB06AB3);         // Magenta aksan
  static const Color mysticLavender = Color(0xFF9B8ED0);        // Lavanta
  
  // Premium Dark Background (Mistik mor tonları)
  static const Color premiumDarkBg = Color(0xFF0D0714);         // Çok koyu mor-siyah
  static const Color premiumDarkBgEnd = Color(0xFF150B24);      // Derin mor
  static const Color premiumAmbientLight = Color(0xFF1F1035);   // Ambient mor
  
  // Champagne Gold Palette
  static const Color champagneGold = Color(0xFFE6D3A3);
  static const Color warmIvory = Color(0xFFF3ECDC);
  static const Color subtleBronze = Color(0xFFB8A46A);
  static const Color deepGold = Color(0xFFC4A962);
  
  // Premium Glassmorphism
  static Color get premiumGlassBackground => Colors.white.withValues(alpha: 0.10);
  static Color get premiumGlassBorder => Colors.white.withValues(alpha: 0.15);
  static Color get premiumGlassHighlight => Colors.white.withValues(alpha: 0.08);
  static Color get premiumGoldGlow => champagneGold.withValues(alpha: 0.30);
  
  // Premium Purple Glow
  static Color get premiumPurpleGlow => mysticPurpleAccent.withValues(alpha: 0.35);
  static Color get premiumMagentaGlow => mysticMagenta.withValues(alpha: 0.30);
  
  // Premium Gradients - MYSTIC PURPLE THEME
  static const LinearGradient premiumDarkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      mysticPurpleDark,    // Çok koyu mor-siyah üst
      mysticPurpleMid,     // Orta koyu mor
      premiumDarkBgEnd,    // Derin mor alt
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  // Yeni: Mistik mor gradient (daha zengin)
  static const LinearGradient mysticPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A0F2E),  // Koyu mor
      Color(0xFF2D1B4E),  // Derin violet
      Color(0xFF1F1035),  // Ambient mor
    ],
  );
  
  // Navbar ve card'lar için mor glow gradient
  static const LinearGradient purpleGlowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x408B5CF6),  // Yarı saydam parlak mor
      Color(0x20B06AB3),  // Yarı saydam magenta
      Color(0x00000000),  // Transparent
    ],
  );
  
  static const LinearGradient champagneGoldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warmIvory, champagneGold, deepGold],
  );
  
  static LinearGradient get premiumGlassGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.12),
      Colors.white.withValues(alpha: 0.05),
    ],
  );
  
  // Premium Card Decoration
  static BoxDecoration get premiumGlassCardDecoration => BoxDecoration(
    gradient: premiumGlassGradient,
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: premiumGlassBorder,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.35),
        blurRadius: 30,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  // Premium Hero Card Decoration
  static BoxDecoration get premiumHeroCardDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        champagneGold.withValues(alpha: 0.25),
        subtleBronze.withValues(alpha: 0.15),
      ],
    ),
    borderRadius: BorderRadius.circular(28),
    border: Border.all(
      color: champagneGold.withValues(alpha: 0.40),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: subtleBronze.withValues(alpha: 0.25),
        blurRadius: 40,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.30),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // Selected Card Decoration with Gold Glow
  static BoxDecoration get premiumSelectedCardDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        champagneGold.withValues(alpha: 0.20),
        deepGold.withValues(alpha: 0.12),
      ],
    ),
    borderRadius: BorderRadius.circular(22),
    border: Border.all(
      color: champagneGold.withValues(alpha: 0.60),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: champagneGold.withValues(alpha: 0.30),
        blurRadius: 20,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.40),
        blurRadius: 30,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  // Test type colors
  static const Color love = Color(0xFFFF69B4);
  static const Color cardBackground = Color(0xFF2B224F);
  
  // Durum renkleri
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Metin renkleri
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white54;
  static const Color textDisabled = Colors.white38;
  
  // Şeffaflık renkleri
  static Color whiteOpacity(double opacity) => Colors.white.withValues(alpha: opacity);
  static Color blackOpacity(double opacity) => Colors.black.withValues(alpha: opacity);
  
  // Başarı gradyanı
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [success, Color(0xFF4CAF50)],
  );
  
  // Aşk gradyanı
  static const LinearGradient loveGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE91E63), Color(0xFFFF6B9D)],
  );
  
  // Kişilik gradyanı
  static const LinearGradient personalityGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
  );
  
  // Burç gradyanı
  static const LinearGradient zodiacGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
  );
  
  // Numeroloji gradyanı
  static const LinearGradient numerologyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
  );
  
  // Yüzey rengi
  static const Color surfaceColor = Color(0xFF1A1A2E);
  
  // Rüya rengi
  static const Color dream = Color(0xFF6A5ACD);
  
  // Rüya gradyanı
  static const LinearGradient dreamGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6A5ACD), Color(0xFF9370DB)],
  );
  
  // Premium rengi
  static const Color premium = Color(0xFFFFD700);
  
  // Border rengi
  static const Color border = Color(0xFF2A2A2A);
  
  // Modern tasarım için glassmorphism efektleri
  static Color get glassBackground => Colors.white.withValues(alpha: 0.05);
  static Color get glassBorder => Colors.white.withValues(alpha: 0.1);
  
  // Modern card tasarımı için
  static BoxDecoration get modernCardDecoration => BoxDecoration(
    color: surface.withValues(alpha: 0.6),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.08),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: primary.withValues(alpha: 0.05),
        blurRadius: 30,
        spreadRadius: -5,
      ),
    ],
  );
  
  // Glassmorphism card decoration
  static BoxDecoration get glassCardDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.08),
        Colors.white.withValues(alpha: 0.03),
      ],
    ),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  // Minimal card decoration (panel tasarımı yerine)
  static BoxDecoration get minimalCardDecoration => BoxDecoration(
    color: surface.withValues(alpha: 0.4),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.15),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ==================== NEW PREMIUM LIGHT THEME (iOS 26) ====================
  
  // Base Colors - Warm & Premium
  static const Color premiumLightBackground = Color(0xFFFAF7F2); // Warm Ivory - NOT White
  static const Color premiumLightSurface = Color(0xFFEBE5DA);    // Darker than BG (Sand/Beige tone)
  // Alternative darker surface for nested cards if needed
  static const Color premiumLightSurfaceDarker = Color(0xFFE0D8C8);

  // Typography - High Contrast (WCAG AA Compliant)
  static const Color premiumLightTextPrimary = Color(0xFF1A1814);   // Warm Black (Almost pure black)
  static const Color premiumLightTextSecondary = Color(0xFF484644); // Warm Dark Gray (High readability)
  static const Color premiumLightTextTertiary = Color(0xFF6E6B65);  // Medium Gray (Still readable)
  
  // Accents for Light Theme
  static const Color premiumLightAccent = Color(0xFF996515);        // Goldenrod/Bronze - readable on light
  static const Color premiumLightPrimary = Color(0xFFD81B60);       // Keep Brand Pink but verify contrast
  
  // Gradients for Light Theme
  static const LinearGradient premiumLightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [premiumLightBackground, Color(0xFFF5F0E6)], // Subtle warm fade
  );

  // Card Decoration - The "Darker than BG" Logic
  static BoxDecoration get ios26LightCardDecoration => BoxDecoration(
    color: premiumLightSurface, // Darker than BG
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Color(0xFFD6CDB8), // Subtle warm border
      width: 1.0, 
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x14000000), // Soft shadow for depth (approx 8% opacity black)
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Color(0x0A000000), // Second layer for ambient depth
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  // Selected Card for Light Theme
  static BoxDecoration get ios26LightSelectedCardDecoration => BoxDecoration(
    color: premiumLightSurface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: premiumLightAccent, // Gold border
      width: 2.0,
    ),
    boxShadow: [
      BoxShadow(
        color: premiumLightAccent.withValues(alpha: 0.20),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // Input Fields for Light Theme
  static BoxDecoration get ios26LightInputDecoration => BoxDecoration(
    color: Colors.white, // Inputs can be white to stand out from beige cards/bg
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Color(0xFFCDC5B4),
      width: 1.0,
    ),
  );

  // Legacy mappings for compatibility (redirecting to new system)
  static const Color lightBackground = premiumLightBackground;
  static const Color lightSurface = premiumLightSurface; 
  static const Color lightCardBackground = premiumLightSurface;
  
  static Color get lightTextPrimary => premiumLightTextPrimary;
  static Color get lightTextSecondary => premiumLightTextSecondary;
  static Color get lightTextTertiary => premiumLightTextTertiary;
  static Color get lightTextDisabled => Color(0xFFADAAA5);

  static LinearGradient get lightCardGradient => LinearGradient(
      colors: [premiumLightSurface, premiumLightSurface], // Flat/Subtle for readability
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
  );

  static LinearGradient get lightMysticalGradient => premiumLightBackgroundGradient;

  static BoxDecoration get modernCardDecorationLight => ios26LightCardDecoration;

  // ==================== THEME-AWARE HELPERS ====================
  
  /// Get text primary color based on theme
  static Color getTextPrimary(bool isDark) => isDark ? textPrimary : lightTextPrimary;
  
  /// Get text secondary color based on theme
  static Color getTextSecondary(bool isDark) => isDark ? textSecondary : lightTextSecondary;
  
  /// Get text tertiary color based on theme
  static Color getTextTertiary(bool isDark) => isDark ? textTertiary : lightTextTertiary;
  
  /// Get text disabled color based on theme
  static Color getTextDisabled(bool isDark) => isDark ? textDisabled : lightTextDisabled;
  
  /// Get card background color based on theme
  static Color getCardBackground(bool isDark) => isDark ? cardBackground : lightCardBackground;
  
  /// Get surface color based on theme
  static Color getSurface(bool isDark) => isDark ? surface : lightSurface;
  
  /// Get background color based on theme
  static Color getBackground(bool isDark) => isDark ? background : lightBackground;
  
  /// Get card gradient based on theme
  static LinearGradient getCardGradient(bool isDark) => isDark ? cardGradient : lightCardGradient;
  
  /// Get mystical gradient based on theme
  static LinearGradient getMysticalGradient(bool isDark) => isDark ? mysticalGradient : lightMysticalGradient;
  
  /// Get modern card decoration based on theme
  static BoxDecoration getModernCardDecoration(bool isDark) => 
      isDark ? modernCardDecoration : modernCardDecorationLight;
  
  /// Get border color based on theme
  static Color getBorderColor(bool isDark) => 
      isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.25);
  
  /// Get icon color based on theme
  static Color getIconColor(bool isDark) => isDark ? Colors.white : Colors.grey[800]!;
  
  /// Get secondary icon color based on theme
  static Color getSecondaryIconColor(bool isDark) => isDark ? Colors.white70 : Colors.grey[600]!;
  
  /// Get divider color based on theme
  static Color getDividerColor(bool isDark) => 
      isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2);
  
  /// Get container background for cards/sections based on theme
  static Color getContainerBackground(bool isDark) => 
      isDark ? Colors.white.withValues(alpha: 0.1) : Color(0xFFFFEED5);
  
  /// Get container border color based on theme
  static Color getContainerBorder(bool isDark) => 
      isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[500]!;
  
  /// Get input text color based on theme
  static Color getInputTextColor(bool isDark) => 
      isDark ? Colors.white : Colors.grey[900]!;
  
  /// Get input hint color based on theme
  static Color getInputHintColor(bool isDark) => 
      isDark ? Colors.white38 : Colors.grey[500]!;
  
  /// Get input background color based on theme
  static Color getInputBackground(bool isDark) => 
      isDark ? Colors.white.withValues(alpha: 0.08) : Color(0xFFFFE8D0);
  
  /// Get input border color based on theme
  static Color getInputBorderColor(bool isDark) => 
      isDark ? Colors.white.withValues(alpha: 0.15) : Colors.grey[400]!;

  // ==================== GLASS STYLING HELPERS ====================

  /// Get glass gradient based on theme
  static LinearGradient getGlassGradient(bool isDark) {
    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.02),
        ],
      );
    } else {
      // Light mode: Frosted Milk / Smoked Glass - Daha opak ve görünür
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
         Colors.white.withValues(alpha: 0.85), // Daha opak
         Colors.white.withValues(alpha: 0.65), // Daha opak
        ],
      );
    }
  }

  /// Get glass border color based on theme
  static Color getGlassBorderColor(bool isDark) {
    if (isDark) {
      return Colors.white.withValues(alpha: 0.15);
    } else {
       return Color(0xFF2D2D2D).withValues(alpha: 0.20); // Daha görünür koyu border
    }
  }

  /// Get glass shadow color based on theme
  static Color getGlassShadowColor(bool isDark) {
    if (isDark) {
      return Colors.black.withValues(alpha: 0.2);
    } else {
      return Colors.black.withValues(alpha: 0.15); // Daha görünür shadow
    }
  }
  
  /// Get glass text color
  static Color getGlassTextColor(bool isDark) => isDark ? Colors.white : lightTextPrimary;
}
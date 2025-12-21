/// Form validasyonları
/// Tüm form alanları için validasyon kuralları
class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    
    if (value.length > 50) {
      return 'Şifre en fazla 50 karakter olabilir';
    }
    
    return null;
  }

  // Strong password validation
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalı';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Şifre en az bir büyük harf içermeli';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Şifre en az bir küçük harf içermeli';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Şifre en az bir rakam içermeli';
    }
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Şifre en az bir özel karakter içermeli';
    }
    
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ad soyad gerekli';
    }
    
    if (value.length < 2) {
      return 'Ad soyad en az 2 karakter olmalı';
    }
    
    if (value.length > 50) {
      return 'Ad soyad en fazla 50 karakter olabilir';
    }
    
    final nameRegex = RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Ad soyad sadece harf içerebilir';
    }
    
    return null;
  }

  // Phone number validation
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası gerekli';
    }
    
    final phoneRegex = RegExp(r'^(\+90|0)?[5][0-9]{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Geçerli bir telefon numarası girin';
    }
    
    return null;
  }

  // Age validation
  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yaş gerekli';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Geçerli bir yaş girin';
    }
    
    if (age < 13) {
      return 'Yaş en az 13 olmalı';
    }
    
    if (age > 120) {
      return 'Geçerli bir yaş girin';
    }
    
    return null;
  }

  // Birth date validation
  static String? birthDate(DateTime? value) {
    if (value == null) {
      return 'Doğum tarihi gerekli';
    }
    
    final now = DateTime.now();
    final age = now.year - value.year;
    
    if (age < 13) {
      return 'Yaş en az 13 olmalı';
    }
    
    if (age > 120) {
      return 'Geçerli bir doğum tarihi girin';
    }
    
    if (value.isAfter(now)) {
      return 'Doğum tarihi gelecekte olamaz';
    }
    
    return null;
  }

  // Zodiac sign validation
  static String? zodiacSign(String? value) {
    if (value == null || value.isEmpty) {
      return 'Burç seçimi gerekli';
    }
    
    // Support both Turkish and English zodiac sign names
    final zodiacSigns = [
      // Turkish
      'Koç', 'Boğa', 'İkizler', 'Yengeç', 'Aslan', 'Başak',
      'Terazi', 'Akrep', 'Yay', 'Oğlak', 'Kova', 'Balık',
      // English
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    
    if (!zodiacSigns.contains(value)) {
      return 'Geçerli bir burç seçin';
    }
    
    return null;
  }

  // Username validation
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı gerekli';
    }
    
    if (value.length < 3) {
      return 'Kullanıcı adı en az 3 karakter olmalı';
    }
    
    if (value.length > 20) {
      return 'Kullanıcı adı en fazla 20 karakter olabilir';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Kullanıcı adı sadece harf, rakam ve _ içerebilir';
    }
    
    return null;
  }

  // Bio validation
  static String? bio(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Bio is optional
    }
    
    if (value.length > 500) {
      return 'Biyografi en fazla 500 karakter olabilir';
    }
    
    return null;
  }

  // Message validation
  static String? message(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mesaj gerekli';
    }
    
    if (value.length > 1000) {
      return 'Mesaj en fazla 1000 karakter olabilir';
    }
    
    return null;
  }

  // Comment validation
  static String? comment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yorum gerekli';
    }
    
    if (value.length > 500) {
      return 'Yorum en fazla 500 karakter olabilir';
    }
    
    return null;
  }

  // Search query validation
  static String? searchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'Arama terimi gerekli';
    }
    
    if (value.length < 2) {
      return 'Arama terimi en az 2 karakter olmalı';
    }
    
    if (value.length > 100) {
      return 'Arama terimi en fazla 100 karakter olabilir';
    }
    
    return null;
  }

  // URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Geçerli bir URL girin';
    }
    
    return null;
  }

  // Credit card validation
  static String? creditCard(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kart numarası gerekli';
    }
    
    final cardRegex = RegExp(r'^[0-9]{16}$');
    if (!cardRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Geçerli bir kart numarası girin';
    }
    
    return null;
  }

  // CVV validation
  static String? cvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV gerekli';
    }
    
    final cvvRegex = RegExp(r'^[0-9]{3,4}$');
    if (!cvvRegex.hasMatch(value)) {
      return 'Geçerli bir CVV girin';
    }
    
    return null;
  }

  // Expiry date validation
  static String? expiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Son kullanma tarihi gerekli';
    }
    
    final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!expiryRegex.hasMatch(value)) {
      return 'Geçerli bir son kullanma tarihi girin (MM/YY)';
    }
    
    return null;
  }

  // Amount validation
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Miktar gerekli';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Geçerli bir miktar girin';
    }
    
    if (amount <= 0) {
      return 'Miktar 0\'dan büyük olmalı';
    }
    
    if (amount > 10000) {
      return 'Miktar en fazla 10.000 olabilir';
    }
    
    return null;
  }

  // Karma validation
  static String? karma(String? value) {
    if (value == null || value.isEmpty) {
      return 'Karma miktarı gerekli';
    }
    
    final karma = int.tryParse(value);
    if (karma == null) {
      return 'Geçerli bir karma miktarı girin';
    }
    
    if (karma < 0) {
      return 'Karma miktarı negatif olamaz';
    }
    
    if (karma > 1000000) {
      return 'Karma miktarı en fazla 1.000.000 olabilir';
    }
    
    return null;
  }

  // Rating validation
  static String? rating(String? value) {
    if (value == null || value.isEmpty) {
      return 'Değerlendirme gerekli';
    }
    
    final rating = int.tryParse(value);
    if (rating == null) {
      return 'Geçerli bir değerlendirme girin';
    }
    
    if (rating < 1 || rating > 5) {
      return 'Değerlendirme 1-5 arasında olmalı';
    }
    
    return null;
  }

  // NPS validation
  static String? nps(String? value) {
    if (value == null || value.isEmpty) {
      return 'NPS skoru gerekli';
    }
    
    final nps = int.tryParse(value);
    if (nps == null) {
      return 'Geçerli bir NPS skoru girin';
    }
    
    if (nps < 0 || nps > 10) {
      return 'NPS skoru 0-10 arasında olmalı';
    }
    
    return null;
  }

  // Required field validation
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gerekli';
    }
    
    return null;
  }

  // Min length validation
  static String? minLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gerekli';
    }
    
    if (value.length < minLength) {
      return '$fieldName en az $minLength karakter olmalı';
    }
    
    return null;
  }

  // Max length validation
  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    if (value.length > maxLength) {
      return '$fieldName en fazla $maxLength karakter olabilir';
    }
    
    return null;
  }

  // Range validation
  static String? range(String? value, int min, int max, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName gerekli';
    }
    
    final number = int.tryParse(value);
    if (number == null) {
      return 'Geçerli bir $fieldName girin';
    }
    
    if (number < min || number > max) {
      return '$fieldName $min-$max arasında olmalı';
    }
    
    return null;
  }

  // Custom validation
  static String? custom(String? value, bool Function(String) validator, String errorMessage) {
    if (value == null || value.isEmpty) {
      return 'Bu alan gerekli';
    }
    
    if (!validator(value)) {
      return errorMessage;
    }
    
    return null;
  }

  // Multiple validations
  static String? validateMultiple(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    
    return null;
  }
}

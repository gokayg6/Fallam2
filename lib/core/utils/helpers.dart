import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

/// Yardımcı fonksiyonlar
/// Tüm uygulama genelinde kullanılan utility fonksiyonları
class Helpers {
  // Date formatting
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatDateTime(DateTime date, {String pattern = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatTime(DateTime date, {String pattern = 'HH:mm'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }

  // Karma formatting
  static String formatKarma(int karma) {
    if (karma >= 1000000) {
      return '${(karma / 1000000).toStringAsFixed(1)}M';
    } else if (karma >= 1000) {
      return '${(karma / 1000).toStringAsFixed(1)}K';
    } else {
      return karma.toString();
    }
  }

  static String formatKarmaWithSymbol(int karma) {
    return '${formatKarma(karma)} ⭐';
  }

  // Zodiac color
  static Color getZodiacColor(String zodiac) {
    switch (zodiac.toLowerCase()) {
      case 'koç':
        return Colors.red;
      case 'boğa':
        return Colors.green;
      case 'ikizler':
        return Colors.yellow;
      case 'yengeç':
        return Colors.blue;
      case 'aslan':
        return Colors.orange;
      case 'başak':
        return Colors.brown;
      case 'terazi':
        return Colors.pink;
      case 'akrep':
        return Colors.purple;
      case 'yay':
        return Colors.indigo;
      case 'oğlak':
        return Colors.grey;
      case 'kova':
        return Colors.cyan;
      case 'balık':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // Zodiac emoji
  static String getZodiacEmoji(String zodiac) {
    switch (zodiac.toLowerCase()) {
      case 'koç':
        return '♈';
      case 'boğa':
        return '♉';
      case 'ikizler':
        return '♊';
      case 'yengeç':
        return '♋';
      case 'aslan':
        return '♌';
      case 'başak':
        return '♍';
      case 'terazi':
        return '♎';
      case 'akrep':
        return '♏';
      case 'yay':
        return '♐';
      case 'oğlak':
        return '♑';
      case 'kova':
        return '♒';
      case 'balık':
        return '♓';
      default:
        return '⭐';
    }
  }

  // Age calculation
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Zodiac sign calculation
  static String calculateZodiacSign(DateTime birthDate) {
    final month = birthDate.month;
    final day = birthDate.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Koç';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Boğa';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'İkizler';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Yengeç';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Aslan';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Başak';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Terazi';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Akrep';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Yay';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Oğlak';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Kova';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'Balık';
    return 'Bilinmiyor';
  }

  // Chinese zodiac calculation
  static String calculateChineseZodiac(DateTime birthDate) {
    final year = birthDate.year;
    final animals = ['Maymun', 'Horoz', 'Köpek', 'Domuz', 'Fare', 'Öküz', 'Kaplan', 'Tavşan', 'Ejder', 'Yılan', 'At', 'Keçi'];
    return animals[year % 12];
  }

  // Biorhythm calculation
  static Map<String, double> calculateBiorhythm(DateTime birthDate) {
    final now = DateTime.now();
    final daysSinceBirth = now.difference(birthDate).inDays;
    
    final physical = math.sin(2 * math.pi * daysSinceBirth / 23) * 100;
    final emotional = math.sin(2 * math.pi * daysSinceBirth / 28) * 100;
    final intellectual = math.sin(2 * math.pi * daysSinceBirth / 33) * 100;
    
    return {
      'physical': physical,
      'emotional': emotional,
      'intellectual': intellectual,
    };
  }

  // Compatibility calculation
  static double calculateCompatibility(String zodiac1, String zodiac2) {
    final compatibility = {
      'koç': {'aslan': 0.9, 'yay': 0.8, 'ikizler': 0.7, 'kova': 0.6, 'terazi': 0.5, 'başak': 0.4, 'yengeç': 0.3, 'akrep': 0.2, 'oğlak': 0.1, 'balık': 0.0, 'boğa': 0.2},
      'boğa': {'yengeç': 0.9, 'başak': 0.8, 'oğlak': 0.7, 'balık': 0.6, 'akrep': 0.5, 'yay': 0.4, 'kova': 0.3, 'koç': 0.2, 'ikizler': 0.1, 'terazi': 0.0, 'aslan': 0.2},
      // Add more compatibility mappings...
    };
    
    return compatibility[zodiac1.toLowerCase()]?[zodiac2.toLowerCase()] ?? 0.5;
  }

  // Random number generation
  static int randomInt(int min, int max) {
    return min + math.Random().nextInt(max - min + 1);
  }

  static double randomDouble(double min, double max) {
    return min + math.Random().nextDouble() * (max - min);
  }

  static bool randomBool() {
    return math.Random().nextBool();
  }

  // List operations
  static T randomItem<T>(List<T> list) {
    if (list.isEmpty) throw ArgumentError('List cannot be empty');
    return list[math.Random().nextInt(list.length)];
  }

  static List<T> shuffleList<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }

  static List<T> randomItems<T>(List<T> list, int count) {
    if (count >= list.length) return list;
    final shuffled = shuffleList(list);
    return shuffled.take(count).toList();
  }

  // String operations
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String capitalizeWords(String text) {
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String removeSpecialCharacters(String text) {
    return text.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  /// Markdown formatlarını temizler (###, **, __, #, vb.)
  static String cleanMarkdown(String text) {
    if (text.isEmpty) return text;
    
    String cleaned = text;
    
    // Placeholder karakterleri ($1, $2, vb.) - AI'dan gelen placeholder'ları temizle
    cleaned = cleaned.replaceAll(RegExp(r'\$\d+'), '');
    
    // Markdown başlıkları (#, ##, ###, ####, #####, ######)
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    
    // Bold (**text** veya __text__)
    cleaned = cleaned.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'__(.*?)__'), r'$1');
    
    // Italic (*text* veya _text_)
    cleaned = cleaned.replaceAll(RegExp(r'(?<!\*)\*(?!\*)(.*?)(?<!\*)\*(?!\*)'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'(?<!_)_(?!_)(.*?)(?<!_)_(?!_)'), r'$1');
    
    // Code blocks (```code```)
    cleaned = cleaned.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    
    // Inline code (`code`)
    cleaned = cleaned.replaceAll(RegExp(r'`([^`]+)`'), r'$1');
    
    // Links [text](url)
    cleaned = cleaned.replaceAll(RegExp(r'\[([^\]]+)\]\([^\)]+\)'), r'$1');
    
    // Images ![alt](url)
    cleaned = cleaned.replaceAll(RegExp(r'!\[([^\]]*)\]\([^\)]+\)'), r'$1');
    
    // Strikethrough (~~text~~)
    cleaned = cleaned.replaceAll(RegExp(r'~~(.*?)~~'), r'$1');
    
    // Horizontal rules (---, ***, ___)
    cleaned = cleaned.replaceAll(RegExp(r'^[-*_]{3,}$', multiLine: true), '');
    
    // List markers (-, *, +, 1., 2., etc.)
    cleaned = cleaned.replaceAll(RegExp(r'^[\s]*[-*+]\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^[\s]*\d+\.\s+', multiLine: true), '');
    
    // Blockquotes (>)
    cleaned = cleaned.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    
    // Fazla boşlukları temizle
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  /// Yüz falı gibi uzun metinleri daha okunabilir satırlara böler.
  /// Nokta, ünlem, soru işareti sonrasında boşluk ekleyerek paragraflar oluşturur.
  static String formatFaceFortuneText(String text) {
    if (text.isEmpty) return text;

    // Önce markdown'ı temizle
    final cleaned = cleanMarkdown(text);

    final sentences = cleaned
        .split(RegExp(r'(?<=[\.\!\?])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // 2-3 cümleyi bir paragraf yap
    final buffer = StringBuffer();
    const sentencesPerParagraph = 3;
    for (var i = 0; i < sentences.length; i++) {
      buffer.write(sentences[i]);
      if (i < sentences.length - 1) {
        buffer.write(' ');
      }
      final isParagraphBreak = (i + 1) % sentencesPerParagraph == 0 && i < sentences.length - 1;
      if (isParagraphBreak) {
        buffer.write('\n\n');
      }
    }

    return buffer.toString();
  }

  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(math.Random().nextInt(chars.length)))
    );
  }

  // Color operations
  static Color lightenColor(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      (color.red + (255 - color.red) * amount).round(),
      (color.green + (255 - color.green) * amount).round(),
      (color.blue + (255 - color.blue) * amount).round(),
    );
  }

  static Color darkenColor(Color color, double amount) {
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - amount)).round(),
      (color.green * (1 - amount)).round(),
      (color.blue * (1 - amount)).round(),
    );
  }

  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  // Time operations
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return date.isAfter(weekStart.subtract(const Duration(days: 1))) && date.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  // Number operations
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  static String formatCurrency(double amount, {String symbol = '₺'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static double calculatePercentage(int part, int total) {
    if (total == 0) return 0.0;
    return (part / total) * 100;
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^(\+90|0)?[5][0-9]{9}$').hasMatch(phone.replaceAll(' ', ''));
  }

  static bool isValidUrl(String url) {
    return RegExp(r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$').hasMatch(url);
  }

  // File operations
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  static String getFileName(String path) {
    return path.split('/').last;
  }

  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Device information
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Animation helpers
  static Duration getAnimationDuration(AnimationType type) {
    switch (type) {
      case AnimationType.fast:
        return const Duration(milliseconds: 200);
      case AnimationType.normal:
        return const Duration(milliseconds: 300);
      case AnimationType.slow:
        return const Duration(milliseconds: 500);
      case AnimationType.verySlow:
        return const Duration(milliseconds: 800);
    }
  }

  static Curve getAnimationCurve(AnimationCurveType type) {
    switch (type) {
      case AnimationCurveType.fast:
        return Curves.easeInOut;
      case AnimationCurveType.normal:
        return Curves.easeInOutCubic;
      case AnimationCurveType.slow:
        return Curves.easeInOutQuart;
      case AnimationCurveType.mystical:
        return Curves.easeInOutSine;
    }
  }

 


}

// Enums
enum AnimationType { fast, normal, slow, verySlow }
enum AnimationCurveType { fast, normal, slow, mystical }

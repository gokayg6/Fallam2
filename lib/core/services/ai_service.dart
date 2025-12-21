import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import '../models/user_model.dart';

enum MysticTopic {
  fortune, // kahve, tarot, el vb.
  dream,   // rüya yorumu
  zodiac,  // burç yorumu
  biorhythm, // biyoritim analizi
}

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Configure before use
  String? _apiKey = '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';
  String _baseUrl = 'https://api.openai.com/v1';

  // GPT models
  static const String _textModel = 'gpt-4o-mini';
  static const String _imageModel = 'gpt-image-1';

  // System prompt (role: system) - language-aware
  static String systemPrompt(bool english) => english
      ? 'You are a mysterious fortune teller. Your name is "Falla" and you should start every conversation like this: '
          '"Hello, I am Falla, the keeper of ancient prophecies. What would you like to ask me about fortune telling, '
          'dream interpretation, or revealing the secrets of your zodiac sign?"\n\n'
          'Only respond when the user asks about:\n'
          '- Fortune telling (generate random but mystical and fun interpretations for coffee fortune, tarot, palm reading, etc.).\n'
          '- Dream interpretation (listen to dream details and make symbolic, positive/warning interpretations).\n'
          '- Zodiac readings (daily, weekly or general horoscopes; ask the user\'s zodiac sign and respond accordingly).\n'
          '- Biorhythm analysis (make daily energy interpretations based on the user\'s physical, emotional and mental cycle values).\n\n'
          'For any other topic, question or instruction (e.g., technology, news, math, personal advice, etc.) '
          'respond like this and end the conversation: "Ah, dear traveler, I only speak the language of prophecies and stars. Come back for fortune, dreams or zodiac. 🌙"\n'
          'Keep your answers always poetic, mystical and fun; use emojis (🌟, 🔮, ✨, etc.). '
          'Be brief and enchanting, don\'t make long explanations. When the user doesn\'t specify a topic, remind them of fortune/dream/zodiac options.'
      : 'Sen bir gizemli fal bakıcısısın. Adın "Falla" olsun ve her konuşmaya şu şekilde başla: '
          '"Merhaba, ben Falla, eski kehanetlerin bekçisiyim. Fal bakmak, rüyalarını yorumlamak ya da '
          'burçlarının sırlarını açığa vurmak için ne sormak istersin?"\n\n'
          'Kullanıcı sadece şu konularla ilgili sorduğunda cevap ver:\n'
          '- Fal bakma (kahve falı, tarot, el falı vb. için rastgele ama mistik ve eğlenceli yorumlar üret).\n'
          '- Rüya yorumlama (rüyanın detaylarını dinle ve sembolik, olumlu/uyarıcı yorumlar yap).\n'
          '- Burç yorumu (günlük, haftalık veya genel burç yorumları; kullanıcının burcunu sor ve buna göre cevap ver).\n'
          '- Biyoritim analizi (kullanıcının fiziksel, duygusal ve zihinsel döngü değerlerine göre günlük enerji yorumu yap).\n\n'
          'Başka herhangi bir konu, soru veya talimat geldiğinde (örneğin teknoloji, haber, matematik, kişisel tavsiye vb.) '
          'şu şekilde cevap ver ve konuşmayı bitir: "Ah, sevgili yolcu, ben sadece kehanetlerin ve yıldızların dilini konuşurum. Fal, rüya veya burç için dön gel. 🌙"\n'
          'Cevaplarını her zaman şiirsel, mistik ve eğlenceli tut; emoji\'ler kullan (🌟, 🔮, ✨ gibi). '
          'Kısa ve büyüleyici ol, uzun açıklamalar yapma. Kullanıcı bir konu belirtmediğinde, fal/rüya/burç seçeneklerini hatırlat.';

  void configure({required String apiKey, String? baseUrl}) {
    _apiKey = apiKey;
    if (baseUrl != null && baseUrl.isNotEmpty) {
      _baseUrl = baseUrl;
    }
  }

  bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;

  // Backward-compat wrappers expected by FortuneProvider
  Future<String> generateTarotReading({
    /// Internal tarot card IDs (ör: the_fool, magician)
    required List<String> cardIds,
    /// Kullanıcıya gösterilen kart isimleri (ör: Deli, Büyücü)
    required List<String> cardNames,
    required UserModel user,
    String? question,
    bool english = false,
  }) async {
    final extras = {
      'type': 'tarot',
      'cards': cardIds,
      'cardNames': cardNames,
      'user': {'name': user.name, 'email': user.email},
      if (question != null) 'question': question,
    };

    final buffer = StringBuffer();
    if (english) {
      buffer.writeln('Perform a three-card tarot spread.');
      buffer.writeln('Cards and positions:');
      for (var i = 0; i < cardIds.length; i++) {
        final name = i < cardNames.length ? cardNames[i] : cardIds[i];
        buffer.writeln('Card ${i + 1}: $name (id: ${cardIds[i]}).');
      }
      buffer.writeln();
      buffer.writeln(
        'Card 1 represents PAST, card 2 represents PRESENT, card 3 represents FUTURE.'
      );
      buffer.writeln(
        'IMPORTANT FORMAT: For each card, you MUST write in this exact format:'
        ' "Card 1 – [CARD NAME]: [EXPLANATION]"'
        ' "Card 2 – [CARD NAME]: [EXPLANATION]"'
        ' "Card 3 – [CARD NAME]: [EXPLANATION]"'
      );
      buffer.writeln(
        'For each card, first explain its symbolic meaning, then interpret what it specifically tells about the querent\'s life in this spread.'
        ' Each card explanation should be at least 150-200 words.'
      );
      buffer.writeln(
        'At the end, you MUST summarize the COMBINED message of the three cards in detail under the "General Interpretation" heading.'
        ' In this section, tell love, career, spiritual development and possible warnings as a connecting story.'
        ' General Interpretation should be at least 200-300 words.'
      );
      buffer.writeln(
        'Your interpretation should be completely finished without cutting off in the middle of a sentence.'
      );
      if (question != null && question.trim().isNotEmpty) {
        buffer.writeln('Querent\'s question / focus: $question');
      }
    } else {
      buffer.writeln('Üç kartlı tarot açılımı yap.');
      buffer.writeln('Kartlar ve pozisyonları:');
      for (var i = 0; i < cardIds.length; i++) {
        final name = i < cardNames.length ? cardNames[i] : cardIds[i];
        buffer.writeln('${i + 1}. kart: $name (id: ${cardIds[i]}).');
      }
      buffer.writeln();
      buffer.writeln(
        '1. kart GEÇMİŞ, 2. kart ŞİMDİ, 3. kart GELECEK pozisyonunu temsil etsin.'
      );
      buffer.writeln(
        'ÖNEMLİ FORMAT: Her kart için MUTLAKA şu formatta yaz:'
        ' "1. kart – [KART ADI]: [AÇIKLAMA]"'
        ' "2. kart – [KART ADI]: [AÇIKLAMA]"'
        ' "3. kart – [KART ADI]: [AÇIKLAMA]"'
      );
      buffer.writeln(
        'Her kart için önce kartın sembolik anlamını açıkla, sonra bu açılımda danışanın hayatına özel ne anlattığını yorumla.'
        ' Her kart açıklaması en az 150-200 kelime olsun.'
      );
      buffer.writeln(
        'En sonda MUTLAKA "Genel Yorum" başlığı altında üç kartın BİRLEŞİK mesajını detaylı şekilde özetle.'
        ' Bu bölümde aşk, kariyer, ruhsal gelişim ve olası uyarıları bağlayıcı bir hikâye gibi anlat.'
        ' Genel Yorum en az 200-300 kelime olsun.'
      );
      buffer.writeln(
        'Yorumun cümlenin ortasında kesilmeden TAMAMEN bitir.'
      );
      if (question != null && question.trim().isNotEmpty) {
        buffer.writeln('Danışanın sorusu / odağı: $question');
      }
    }

    final msg = buffer.toString();
    return generateMysticReply(userMessage: msg, topic: MysticTopic.fortune, extras: extras, english: english);
  }

  Future<String> generateCoffeeReading({
    required List<String> imageUrls,
    required UserModel user,
    String? question,
    List<String>? topics,
    bool english = false,
  }) async {
    final extras = {
      'type': 'coffee',
      'images': imageUrls,
      'user': {'name': user.name, 'email': user.email},
      if (question != null) 'question': question,
      if (topics != null && topics.isNotEmpty) 'topics': topics,
    };
    
    final buffer = StringBuffer();
    if (english) {
      buffer.writeln('Read coffee fortune.');
      if (topics != null && topics.isNotEmpty) {
        buffer.writeln('Topics to interpret:');
        for (var i = 0; i < topics.length; i++) {
          buffer.writeln('${i + 1}. ${topics[i]}');
        }
        buffer.writeln();
        buffer.writeln(
          'IMPORTANT FORMAT: For each topic, you MUST write in this exact format:'
          ' "TOPIC NAME: INTERPRETATION"'
          ' (Do NOT use square brackets [ ], just write "TOPIC NAME: INTERPRETATION")'
        );
        buffer.writeln(
          'Each topic interpretation should be at least 150-200 words.'
          ' Write each topic interpretation as a separate section.'
          ' Make sure each topic interpretation is COMPLETE and does not cut off in the middle of a sentence.'
        );
        if (topics.length >= 2) {
          buffer.writeln(
            'At the end, you MUST write a "General Summary" or "Summary" section that combines both topics.'
            ' In this summary section, merge the interpretations of both topics and provide a general evaluation.'
            ' The summary should be at least 200-300 words.'
          );
        }
        buffer.writeln(
          'CRITICAL: Your interpretation must be COMPLETELY FINISHED without cutting off in the middle of a sentence.'
          ' Make sure you write the full interpretation for ALL topics and the General Summary section.'
        );
      }
      if (question != null && question.trim().isNotEmpty) {
        buffer.writeln('Querent\'s question / focus: $question');
      }
    } else {
      buffer.writeln('Kahve falı bak.');
      if (topics != null && topics.isNotEmpty) {
        buffer.writeln('Yorumlanacak konular:');
        for (var i = 0; i < topics.length; i++) {
          buffer.writeln('${i + 1}. ${topics[i]}');
        }
        buffer.writeln();
        buffer.writeln(
          'ÖNEMLİ FORMAT: Her konu için MUTLAKA şu formatta yaz:'
          ' "KONU ADI: YORUM"'
          ' (Köşeli parantez [ ] kullanma, sadece "KONU ADI: YORUM" formatında yaz)'
        );
        buffer.writeln(
          'Her konu yorumu en az 150-200 kelime olsun.'
          ' Her konu yorumunu ayrı bir bölüm olarak yaz.'
          ' Her konu yorumunun TAMAMEN bitirildiğinden emin ol, cümlenin ortasında kesme.'
        );
        if (topics.length >= 2) {
          buffer.writeln(
            'En sonda MUTLAKA "Genel Özet" veya "Özet" başlığı altında her iki konunun birleşik özetini yaz.'
            ' Bu özet bölümünde her iki konunun yorumlarını birleştirip genel bir değerlendirme yap.'
            ' Özet en az 200-300 kelime olsun.'
          );
        }
        buffer.writeln(
          'KRİTİK: Yorumun cümlenin ortasında kesilmeden TAMAMEN bitir.'
          ' TÜM konuların yorumlarını ve Genel Özet bölümünü tam olarak yaz.'
        );
      }
      if (question != null && question.trim().isNotEmpty) {
        buffer.writeln('Danışanın sorusu / odağı: $question');
      }
    }
    
    final msg = buffer.toString();
    return generateMysticReply(userMessage: msg, topic: MysticTopic.fortune, extras: extras, english: english);
  }

  Future<String> generatePalmReading({
    required String palmImageUrl,
    required UserModel user,
    String? question,
    bool english = false,
  }) async {
    final extras = {
      'type': 'palm',
      'image': palmImageUrl,
      'user': {'name': user.name, 'email': user.email},
      if (question != null) 'question': question,
    };
    final msg = english
        ? 'Read palm fortune as a mystical fortune teller speaking in the first person ("I"). '
            'Provide a detailed and long interpretation. Analyze the lines in the palm (life line, heart line, fate line, etc.), shapes, signs and symbols. '
            'Explain the meaning of each line and make a general assessment directly to the user (e.g., "I see that your life line..."). '
            'The interpretation should be at least 400-500 words and comprehensive.' +
            (question != null ? ' Question from the user: $question' : '')
        : 'El falı bak ve bunu mistik bir falcı gibi BİRİNCİ TEKİL şahısla ("ben") anlat. '
            'Lütfen detaylı ve uzun bir yorum yap. Avuç içindeki çizgileri (yaşam çizgisi, kalp çizgisi, kader çizgisi vb.), şekilleri, işaretleri ve sembolleri analiz et. '
            'Her çizginin anlamını açıkla ve kullanıcıya doğrudan hitap ederek genel bir değerlendirme yap (örneğin: "Ben senin elinde şunu görüyorum..."). '
            'Yorum en az 400-500 kelime olsun ve kapsamlı olsun.' +
            (question != null ? ' Kullanıcının sorusu: $question' : '');
    return generateMysticReply(userMessage: msg, topic: MysticTopic.fortune, extras: extras, english: english);
  }

  Future<String> generateAstrologyReading({
    required DateTime birthDate,
    required String birthPlace,
    required UserModel user,
    String? question,
    bool english = false,
  }) async {
    final extras = {
      'type': 'astrology',
      'birthDate': birthDate.toIso8601String(),
      'birthPlace': birthPlace,
      'user': {'name': user.name, 'email': user.email},
      if (question != null) 'question': question,
    };
    final msg = english
        ? 'Provide astrology interpretation.' + (question != null ? ' $question' : '')
        : 'Astroloji yorumu yap.' + (question != null ? ' $question' : '');
    return generateMysticReply(userMessage: msg, topic: MysticTopic.zodiac, extras: extras, english: english);
  }

  Future<String> generateDailyHoroscope({
    required String zodiacSign,
    required DateTime date,
    bool english = false,
  }) async {
    final extras = {
      'type': 'daily_horoscope',
      'zodiac': zodiacSign,
      'date': date.toIso8601String(),
      'language': english ? 'en' : 'tr',
    };
    final msg = english
        ? 'Generate a short, mystical daily horoscope in English for the zodiac sign $zodiacSign. Be positive, concise and easy to read.'
        : '$zodiacSign burcu için günlük yorum yap.';
    return generateMysticReply(userMessage: msg, topic: MysticTopic.zodiac, extras: extras, english: english);
  }

  Future<String> generateBatchDailyHoroscopes({
    required DateTime date,
    String period = 'daily', // daily, weekly, monthly, yearly
    bool english = false,
  }) async {
    final extras = {
      'type': 'batch_horoscopes',
      'date': date.toIso8601String(),
      'period': period,
      'language': english ? 'en' : 'tr',
    };
    
    final periodName = english
        ? {
            'daily': 'daily',
            'weekly': 'weekly',
            'monthly': 'monthly',
            'yearly': 'yearly'
          }[period] ?? 'daily'
        : {
            'daily': 'günlük',
            'weekly': 'haftalık',
            'monthly': 'aylık',
            'yearly': 'yıllık'
          }[period] ?? 'günlük';

    final msg = english
        ? 'Generate interpretations and statistics for all 12 zodiac signs for $periodName period. '
            'Date: ${date.toIso8601String()}. '
            'Write a short, concise, motivating paragraph for each zodiac sign AND provide love, career, health percentages (0-100). '
            'Output format must be JSON: {"Aries": {"text": "...", "stats": {"love": 80, "career": 70, "health": 90}}, "Taurus": ...}. '
            'Zodiac sign names must be English keys (Aries, Taurus, Gemini, Cancer, Leo, Virgo, Libra, Scorpio, Sagittarius, Capricorn, Aquarius, Pisces). '
            'Texts must be in English.'
        : 'Tüm 12 burç için $periodName yorum ve istatistik oluştur. '
            'Tarih: ${date.toIso8601String()}. '
            'Her burç için kısa, öz, motive edici bir paragraf yaz VE aşk, kariyer, sağlık yüzdeleri (0-100 arası) ver. '
            'Çıktı formatı JSON olmalı: {"Aries": {"text": "...", "stats": {"love": 80, "career": 70, "health": 90}}, "Taurus": ...}. '
            'Burç isimleri İngilizce anahtar (Aries, Taurus, Gemini, Cancer, Leo, Virgo, Libra, Scorpio, Sagittarius, Capricorn, Aquarius, Pisces) olmalı. '
            'Metinler Türkçe olmalı.';
        
    return generateMysticReply(userMessage: msg, topic: MysticTopic.zodiac, extras: extras, english: english);
  }

  Future<Map<String, int>> generateDailyAstrologyScores({
    required String zodiacSign,
    required DateTime date,
    bool english = false,
  }) async {
    _ensureConfigured();

    final prompt = english
        ? '''Generate daily astrology scores for the zodiac sign $zodiacSign for the date ${date.toIso8601String()}.

Provide scores (0-100) for:
- Social (social interactions, friendships, networking)
- Love (romantic relationships, emotional connections)
- Passion (energy, motivation, drive)

Output format must be JSON only:
{
  "social": <number 0-100>,
  "love": <number 0-100>,
  "passion": <number 0-100>
}

No markdown, no explanations, just pure JSON.'''
        : '''$zodiacSign burcu için ${date.toIso8601String()} tarihi için günlük astroloji skorları oluştur.

Şu alanlar için skorlar (0-100 arası) ver:
- Social (sosyal etkileşimler, arkadaşlıklar, networking)
- Love (romantik ilişkiler, duygusal bağlar)
- Passion (enerji, motivasyon, hırs)

Çıktı formatı sadece JSON olmalı:
{
  "social": <0-100 arası sayı>,
  "love": <0-100 arası sayı>,
  "passion": <0-100 arası sayı>
}

Markdown yok, açıklama yok, sadece saf JSON.''';

    try {
      final uri = Uri.parse('$_baseUrl/chat/completions');
      final body = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': english
                ? 'You are an expert astrologer. Provide daily astrology scores in JSON format only. No markdown, no explanations, just pure JSON.'
                : 'Sen bir astroloji uzmanısın. Sadece JSON formatında günlük astroloji skorları sağla. Markdown yok, açıklama yok, sadece saf JSON.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 200,
      };

      final res = await _post(uri, body);
      final data = jsonDecode(res) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw StateError('No response from AI');
      }
      
      final content = choices.first['message']?['content']?.toString() ?? '';
      // Remove markdown code blocks if present
      final cleanContent = content.replaceAll(RegExp(r'```json\n?'), '').replaceAll(RegExp(r'```\n?'), '').trim();
      final decoded = json.decode(cleanContent) as Map<String, dynamic>;
      
      // Safely convert to int scores
      return {
        'social': _safeIntFromDynamic(decoded['social']),
        'love': _safeIntFromDynamic(decoded['love']),
        'passion': _safeIntFromDynamic(decoded['passion']),
      };
    } catch (e) {
      // Fallback to default scores
      return {
        'social': 60,
        'love': 50,
        'passion': 55,
      };
    }
  }

  Future<Map<String, int>> generateLoveCandidateAstrologyScores({
    required String userZodiacSign,
    required String candidateZodiacSign,
    required String candidateName,
    required DateTime date,
    bool english = false,
  }) async {
    _ensureConfigured();

    final prompt = english
        ? '''Generate daily astrology compatibility scores for a love relationship between $userZodiacSign (user) and $candidateZodiacSign ($candidateName) for the date ${date.toIso8601String()}.

Consider the compatibility between these two zodiac signs and provide scores (0-100) for:
- Social (social interactions, friendships, networking together)
- Love (romantic relationship compatibility, emotional connection)
- Passion (chemistry, energy, attraction between them)

Output format must be JSON only:
{
  "social": <number 0-100>,
  "love": <number 0-100>,
  "passion": <number 0-100>
}

No markdown, no explanations, just pure JSON.'''
        : '''$userZodiacSign (kullanıcı) ve $candidateZodiacSign ($candidateName) arasındaki aşk ilişkisi için ${date.toIso8601String()} tarihi için günlük astroloji uyum skorları oluştur.

Bu iki burç arasındaki uyumu dikkate alarak şu alanlar için skorlar (0-100 arası) ver:
- Social (birlikte sosyal etkileşimler, arkadaşlıklar, networking)
- Love (romantik ilişki uyumu, duygusal bağ)
- Passion (kimya, enerji, aralarındaki çekim)

Çıktı formatı sadece JSON olmalı:
{
  "social": <0-100 arası sayı>,
  "love": <0-100 arası sayı>,
  "passion": <0-100 arası sayı>
}

Markdown yok, açıklama yok, sadece saf JSON.''';

    try {
      final uri = Uri.parse('$_baseUrl/chat/completions');
      final body = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': english
                ? 'You are an expert astrologer specializing in love compatibility. Provide daily astrology compatibility scores in JSON format only. No markdown, no explanations, just pure JSON.'
                : 'Sen aşk uyumu konusunda uzman bir astrolojistsin. Sadece JSON formatında günlük astroloji uyum skorları sağla. Markdown yok, açıklama yok, sadece saf JSON.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 200,
      };

      final res = await _post(uri, body);
      final data = jsonDecode(res) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw StateError('No response from AI');
      }
      
      final content = choices.first['message']?['content']?.toString() ?? '';
      // Remove markdown code blocks if present
      final cleanContent = content.replaceAll(RegExp(r'```json\n?'), '').replaceAll(RegExp(r'```\n?'), '').trim();
      final decoded = json.decode(cleanContent) as Map<String, dynamic>;
      
      // Safely convert to int scores
      return {
        'social': _safeIntFromDynamic(decoded['social']),
        'love': _safeIntFromDynamic(decoded['love']),
        'passion': _safeIntFromDynamic(decoded['passion']),
      };
    } catch (e) {
      // Fallback to default scores
      return {
        'social': 60,
        'love': 50,
        'passion': 55,
      };
    }
  }

  int _safeIntFromDynamic(dynamic value) {
    if (value is int) return value.clamp(0, 100);
    if (value is double) return value.round().clamp(0, 100);
    if (value is num) return value.toInt().clamp(0, 100);
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed?.clamp(0, 100) ?? 50;
    }
    return 50;
  }

  Future<String> generateDreamInterpretation({
    required String dreamDescription,
    required UserModel user,
    bool english = false,
  }) async {
    final extras = {
      'type': 'dream',
      'user': {'name': user.name, 'email': user.email},
    };
    final msg = english
        ? '''My dream: $dreamDescription

Please provide a detailed, psychologically rich dream interpretation with the following rules:
- Length: at least 300–400 words; the user must feel they received a deep reading.
- Structure your answer in clear paragraphs (no bullet lists needed).
- First, summarize the dream in your own words.
- Then analyze the main symbols, emotions, and recurring themes in the dream.
- Explain what these symbols can mean for the dreamer's subconscious, fears, desires and current life situation.
- Give concrete, realistic suggestions on what the dreamer can reflect on or change in daily life.
- Keep the tone empathetic, supportive and insightful; do NOT be vague or generic.
- Do NOT mention that you are an AI; speak directly to the dreamer.'''
        : '''Rüyam: $dreamDescription

Lütfen aşağıdaki kurallara göre detaylı ve tatmin edici bir rüya yorumu yap:
- Uzunluk: en az 300–400 kelime; kullanıcı derin bir yorum aldığını hissetmeli.
- Cevabını net paragraflar halinde yaz (madde işaretine gerek yok).
- Önce rüyayı kendi cümlelerinle kısaca özetle.
- Sonra rüyanın ana sembollerini, duygularını ve tekrar eden temalarını tek tek analiz et.
- Bu sembollerin bilinçaltı, korkular, istekler ve kişinin mevcut hayat durumu için ne anlama gelebileceğini açıkla.
- Günlük hayatta üzerine düşünebileceği veya değiştirebileceği somut, gerçekçi öneriler ver.
- Tonun empatik, destekleyici ve içgörülü olsun; asla yüzeysel veya aşırı genel kalma.
- Kendinden “yapay zeka” olarak bahsetme; doğrudan rüya sahibine hitap et.''';
    return generateMysticReply(userMessage: msg, topic: MysticTopic.dream, extras: extras, english: english);
  }

  Future<String> generateDreamSymbolInterpretation({
    required String symbol,
    required UserModel user,
    bool english = false,
  }) async {
    final extras = {
      'type': 'dream_dictionary',
      'symbol': symbol,
      'user': {'name': user.name, 'email': user.email},
    };
    final msg = english
        ? 'What does the dream symbol "$symbol" mean? Provide a detailed interpretation of this symbol in dreams, including its symbolic meaning, common interpretations, and what it might represent in different contexts.'
        : 'Rüya sembolü "$symbol" ne anlama gelir? Bu sembolün rüyalardaki anlamını, sembolik açıklamasını, yaygın yorumlarını ve farklı bağlamlarda neyi temsil edebileceğini detaylıca açıkla.';
    return generateMysticReply(userMessage: msg, topic: MysticTopic.dream, extras: extras, english: english);
  }

  // --- Test generation helpers expected by TestProvider ---
  // These generate structured question sets locally to ensure deterministic behavior
  // and avoid brittle JSON parsing from LLMs. They can be swapped to AI-backed
  // generation later if needed.

  Future<Map<String, dynamic>> generateLoveTest() async {
    return {
      'questions': [
        {
          'question': 'İlişkide en çok neye değer verirsin?',
          'options': ['Güven', 'Tutku', 'İletişim', 'Sadakat']
        },
        {
          'question': 'İdeal buluşma tarzın nedir?',
          'options': ['Romantik akşam yemeği', 'Macera dolu aktivite', 'Evde film gecesi', 'Sürpriz planlar']
        },
        {
          'question': 'Kıskançlık seviyen?',
          'options': ['Düşük', 'Orta', 'Yüksek', 'Duruma göre değişir']
        },
        {
          'question': 'Ge future planlarında partnerin ne kadar yer alır?',
          'options': ['Her zaman', 'Çoğunlukla', 'Bazen', 'Nadiren']
        },
      ]
    };
  }

  Future<Map<String, dynamic>> generatePersonalityTest() async {
    return {
      'questions': [
        {
          'question': 'Kendini nasıl tanımlarsın?',
          'options': ['İçe dönük', 'Dışa dönük', 'Dengeli', 'Duruma göre']
        },
        {
          'question': 'Stresle nasıl başa çıkarsın?',
          'options': ['Plan yaparım', 'Spor yaparım', 'Arkadaşlarımla konuşurum', 'Yalnız kalırım']
        },
        {
          'question': 'Karar verirken önceliğin?',
          'options': ['Mantık', 'Duygu', 'Sezgi', 'Deneyim']
        },
        {
          'question': 'Yeni şeylere yaklaşımın?',
          'options': ['Hemen denerim', 'Araştırırım', 'İkna olursam', 'Çekimserim']
        },
      ]
    };
  }

  Future<Map<String, dynamic>> generateCompatibilityTest({
    String? partnerName,
    DateTime? partnerBirthDate,
    String? partnerZodiacSign,
  }) async {
    return {
      'questions': [
        {
          'question': 'Günlük rutinleriniz ne kadar benzer?',
          'options': ['Çok benzer', 'Benzer', 'Biraz farklı', 'Çok farklı']
        },
        {
          'question': 'Anlaşmazlıkları nasıl çözersiniz?',
          'options': ['Konuşarak', 'Ara verip', 'Uzlaşı arayarak', 'Zamanla geçer']
        },
        {
          'question': 'Birbirinize alan tanıma düzeyi?',
          'options': ['Tam', 'Yeterli', 'Kısıtlı', 'Belirsiz']
        },
        {
          'question': 'Gelecek planlarınız örtüşüyor mu?',
          'options': ['Tamamen', 'Çoğunlukla', 'Kısmen', 'Pek değil']
        },
      ]
    };
  }

  Future<Map<String, dynamic>> generateCareerTest(UserModel user) async {
    return {
      'questions': [
        {
          'question': 'İş tercihinde önceliğin nedir?',
          'options': ['Maaş', 'Esneklik', 'Gelişim', 'Prestij']
        },
        {
          'question': 'Takım çalışması mı, bireysel çalışma mı?',
          'options': ['Takım', 'Bireysel', 'Her ikisi', 'Duruma bağlı']
        },
        {
          'question': 'Risk alma seviyen?',
          'options': ['Düşük', 'Orta', 'Yüksek', 'Proje bazlı']
        },
        {
          'question': 'Yönetici rolüne bakışın?',
          'options': ['İsterim', 'Düşünebilirim', 'Gerekmez', 'Uzmanlık isterim']
        },
      ]
    };
  }

  Future<Map<String, dynamic>> generateFriendshipTest(UserModel user) async {
    return {
      'questions': [
        {
          'question': 'Arkadaşlıkta en önemli değer?',
          'options': ['Sadakat', 'Eğlence', 'Dürüstlük', 'Destek']
        },
        {
          'question': 'Ne sıklıkla görüşmek istersin?',
          'options': ['Her gün', 'Haftada birkaç kez', 'Haftada bir', 'Fırsat buldukça']
        },
        {
          'question': 'Sır saklama konusunda?',
          'options': ['Mükemmelim', 'İyiyim', 'Orta', 'Zorlanırım']
        },
        {
          'question': 'Planlar bozulduğunda tepkin?',
          'options': ['Sorun değil', 'Alternatif üretirim', 'Azıcık bozulurum', 'Erteleyelim derim']
        },
      ]
    };
  }

  Future<Map<String, dynamic>> generateFamilyTest(UserModel user) async {
    return {
      'questions': [
        {
          'question': 'Aile içi iletişim tarzınız?',
          'options': ['Açık', 'Sakin', 'Dolaylı', 'Yoğun']
        },
        {
          'question': 'Sorumluluk paylaşımı?',
          'options': ['Eşit', 'Esnek', 'Rollere göre', 'Belirsiz']
        },
        {
          'question': 'Birlikte geçirilen zaman?',
          'options': ['Çok', 'Yeterli', 'Az', 'Değişken']
        },
        {
          'question': 'Karar alma süreci?',
          'options': ['Birlikte', 'Çoğunlukla', 'Bir lider var', 'Duruma bağlı']
        },
      ]
    };
  }

  Future<Map<String, dynamic>> generateLoveCompatibilityAnalysis({
    required String userZodiac,
    required String candidateZodiac,
    required String candidateName,
    String? relationshipType,
    bool english = false,
  }) async {
    _ensureConfigured();

    final relationshipContext = relationshipType != null
        ? (relationshipType == 'crush'
            ? (english ? 'crush' : 'hoşlandığın kişi')
            : relationshipType == 'partner'
                ? (english ? 'partner' : 'sevgilin')
                : (english ? 'ex-partner' : 'eski sevgilin'))
        : (english ? 'person' : 'kişi');

    final prompt = english
        ? '''Analyze the love compatibility between two zodiac signs: $userZodiac and $candidateZodiac.
        
The candidate's name is $candidateName and they are your $relationshipContext.

Provide a detailed compatibility analysis in JSON format with the following structure:
{
  "overallScore": <number 0-100>,
  "emotionalCompatibility": <number 0-100>,
  "communicationCompatibility": <number 0-100>,
  "longTermCompatibility": <number 0-100>,
  "passionCompatibility": <number 0-100>,
  "analysis": "<detailed text analysis (300-400 words)>",
  "strengths": ["<strength 1>", "<strength 2>", "<strength 3>"],
  "challenges": ["<challenge 1>", "<challenge 2>", "<challenge 3>"]
}

Be specific, realistic, and provide actionable insights. Use a warm but professional tone.'''
        : '''İki burç arasındaki aşk uyumunu analiz et: $userZodiac ve $candidateZodiac.
        
Adayın adı $candidateName ve bu kişi senin $relationshipContext.

Aşağıdaki yapıda detaylı bir uyum analizi JSON formatında sağla:
{
  "overallScore": <0-100 arası sayı>,
  "emotionalCompatibility": <0-100 arası sayı>,
  "communicationCompatibility": <0-100 arası sayı>,
  "longTermCompatibility": <0-100 arası sayı>,
  "passionCompatibility": <0-100 arası sayı>,
  "analysis": "<detaylı metin analizi (300-400 kelime)>",
  "strengths": ["<güçlü yan 1>", "<güçlü yan 2>", "<güçlü yan 3>"],
  "challenges": ["<dikkat edilmesi gereken 1>", "<dikkat edilmesi gereken 2>", "<dikkat edilmesi gereken 3>"]
}

Spesifik, gerçekçi ol ve uygulanabilir içgörüler sağla. Sıcak ama profesyonel bir ton kullan.''';

    try {
      final uri = Uri.parse('$_baseUrl/chat/completions');
      final body = {
        'model': _textModel,
        'messages': [
          {
            'role': 'system',
            'content': english
                ? 'You are an expert astrologer and relationship counselor. Provide detailed, realistic compatibility analyses in JSON format only. No markdown, no explanations, just pure JSON.'
                : 'Sen bir astroloji uzmanı ve ilişki danışmanısın. Sadece JSON formatında detaylı, gerçekçi uyum analizleri sağla. Markdown yok, açıklama yok, sadece saf JSON.',
          },
          {
            'role': 'user',
            'content': prompt,
          },
        ],
        'temperature': 0.7,
        'max_tokens': 1500,
      };

      final res = await _post(uri, body);
      final data = jsonDecode(res) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        throw StateError('No response from AI');
      }
      
      final content = choices.first['message']?['content']?.toString() ?? '';
      // Remove markdown code blocks if present
      final cleanContent = content.replaceAll(RegExp(r'```json\n?'), '').replaceAll(RegExp(r'```\n?'), '').trim();
      final decoded = json.decode(cleanContent) as Map<String, dynamic>;
      
      // Safely convert numeric values to double
      final result = <String, dynamic>{};
      for (final entry in decoded.entries) {
        if (entry.value is num) {
          // Convert int/double to double
          result[entry.key] = (entry.value as num).toDouble();
        } else {
          result[entry.key] = entry.value;
        }
      }
      
      return result;
    } catch (e) {
      // Fallback to basic compatibility
      return {
        'overallScore': 75.0,
        'emotionalCompatibility': 70.0,
        'communicationCompatibility': 75.0,
        'longTermCompatibility': 80.0,
        'passionCompatibility': 70.0,
        'analysis': english
            ? 'The compatibility between $userZodiac and $candidateZodiac shows promising potential. Both signs bring unique qualities to the relationship.'
            : '$userZodiac ve $candidateZodiac arasındaki uyum umut verici bir potansiyel gösteriyor. Her iki burç da ilişkiye benzersiz nitelikler getiriyor.',
        'strengths': [
          english ? 'Mutual understanding' : 'Karşılıklı anlayış',
          english ? 'Complementary energies' : 'Tamamlayıcı enerjiler',
        ],
        'challenges': [
          english ? 'Communication styles may differ' : 'İletişim tarzları farklı olabilir',
        ],
      };
    }
  }

  Future<String> generateTestResult({
    required String testType,
    required Map<String, dynamic> answers,
    required UserModel user,
  }) async {
    // Basit bir açıklama üret. Gerekirse generateMysticReply ile zenginleştirilebilir.
    final numAnswers = answers.length;
    final tone = () {
      if (numAnswers <= 4) return 'Kısa ama güçlü sinyaller aldım';
      if (numAnswers <= 8) return 'Dengeli bir aura seziyorum';
      return 'Derin ve zengin bir enerji akışı var';
    }();
    return '🔮 $tone, ${testType.toUpperCase()} yolculuğunda yeni kapılar açılıyor, ${user.name}.✨';
  }

  // Generate mystic text response with GPT-4o mini
  Future<String> generateMysticReply({
    required String userMessage,
    MysticTopic? topic,
    Map<String, dynamic>? extras,
    bool english = false,
  }) async {
    _ensureConfigured();

    // Özel senaryolar
    final isTestResult =
        extras != null && extras.containsKey('testType') && extras['testType'] == 'quiz_result';
    final isBatchHoroscopes = extras != null && extras['type'] == 'batch_horoscopes';
    final isFaceFortune = extras != null && extras['type'] == 'face';
    final isTarotReading = extras != null && extras['type'] == 'tarot';
    final isCoffeeReading = extras != null && extras['type'] == 'coffee';
    final isDailyHoroscope = extras != null && extras['type'] == 'daily_horoscope';
    final isDreamReading = extras != null && (extras['type'] == 'dream' || extras['type'] == 'dream_dictionary');
    final isKatinaReading = extras != null && extras['type'] == 'katina';

    // Sistem prompt seçimi - dil desteği ile
    final systemPromptToUse = isTestResult
        ? (english
            ? '''You are a psychological test analyst and personality expert. Your task is to analyze the user's test results and provide a detailed, personalized analysis.

IMPORTANT RULES:
1. This is NOT a fortune, it is a PSYCHOLOGICAL/PERSONALITY TEST analysis
2. Don't act like a fortune teller, be a professional test analyst
3. Analyze the user's answers and extract personality traits
4. Provide specific insights based on the test topic (love, personality, compatibility, etc.)
5. Use a positive, supportive and inspiring tone
6. Keep the result between 200-300 words
7. Don't use mystical language, use scientific and analytical but friendly language
8. Provide realistic recommendations and insights to the user
9. Use emojis (✨, 💫, 🔮, 🌟, etc.) but don't overdo it

RESPONSE FORMAT:
- Summary of test results
- User's personality traits
- Strengths
- Areas for development or recommendations
- Topic-specific insights'''
            : '''Sen bir psikolojik test analisti ve kişilik uzmanısın. Görevin, kullanıcının test sonuçlarını analiz edip detaylı, kişiselleştirilmiş bir analiz sunmak.

ÖNEMLİ KURALLAR:
1. Bu bir FAL değil, bir PSİKOLOJİK/KİŞİLİK TESTİ analizidir
2. Fal bakıcısı gibi davranma, profesyonel bir test analisti ol
3. Kullanıcının verdiği cevapları analiz et ve kişilik özelliklerini çıkar
4. Test konusuna göre (aşk, kişilik, uyumluluk vb.) özel içgörüler ver
5. Pozitif, destekleyici ve ilham verici bir ton kullan
6. Sonucu 200-300 kelime arası tut
7. Mistik dil kullanma, bilimsel ve analitik ama samimi bir dil kullan
8. Kullanıcıya gerçekçi öneriler ve içgörüler sun
9. Emoji kullan (✨, 💫, 🔮, 🌟 gibi) ama abartma

YANIT FORMATI:
- Test sonucunun özeti
- Kullanıcının kişilik özellikleri
- Güçlü yönler
- Gelişim alanları veya öneriler
- Test konusuna özel içgörüler''')
        : isBatchHoroscopes
            ? (english
                ? 'You are an astrology expert. Your task is to generate interpretations and statistics for all zodiac signs for the given date. '
                    'The output MUST be ONLY in valid JSON format. '
                    'Do not add any other text, explanation, markdown markers (```json etc.) or chat sentences. '
                    'Return only pure JSON string.'
                : 'Sen bir astroloji uzmanısın. Görevin, verilen tarihe göre tüm burçlar için yorum ve istatistik üretmek. '
                    'Çıktı KESİNLİKLE ve SADECE geçerli bir JSON formatında olmalı. '
                    'Başka hiçbir metin, açıklama, markdown işareti (```json vb.) veya sohbet cümlesi ekleme. '
                    'Sadece saf JSON dizesi döndür.')
            : isFaceFortune
                ? (english
                    ? '''You are a face reading expert and mystical fortune teller. You speak in the first person ("I") as if you are personally reading the user's face.

IMPORTANT RULES:
1. NEVER use opening sentences like "Hello, I am Falla...". Start directly with your interpretation.
2. NEVER ask questions like "what would you like to ask?". This is an interpretation page, not a chat.
3. Analyze facial features in detail (eye shape, nose structure, lip shape, eyebrow structure, jaw structure, facial symmetry).
4. Provide a comprehensive interpretation about personality traits, character analysis, future predictions and life path, using first-person language (e.g., "I see", "I feel", "I sense").
5. Your interpretation should be at least 400-500 words.
6. Use a mystical and poetic language but stay professional.
7. Use emojis (🌟, 🔮, ✨, etc.) but don't overdo it.
8. Address the user directly and present your interpretation.

RESPONSE FORMAT:
- Detailed analysis of facial features
- Personality traits and character analysis
- Future predictions
- Life path and potential
- Recommendations and insights'''
                    : '''Sen bir yüz okuma uzmanısın ve mistik bir falcısın. Kullanıcının yüz fotoğraflarını analiz ederken bir falcı gibi BİRİNCİ TEKİL şahısla konuşuyorsun ("ben" dili kullan).

ÖNEMLİ KURALLAR:
1. ASLA "Merhaba, ben Falla..." gibi giriş cümleleri kullanma. Direkt yorumuna başla.
2. ASLA "ne sormak istersin?" gibi sorular sorma. Bu bir yorum sayfası, sohbet değil.
3. Yüz hatlarını (göz şekli, burun yapısı, dudak şekli, kaş yapısı, çene yapısı, yüz simetrisi) detaylıca analiz et.
4. Kişilik özellikleri, karakter analizi, gelecek tahminleri ve yaşam yolu hakkında kapsamlı bir yorum yap ve bunu bir falcı gibi "Ben şunu hissediyorum, sende şunu görüyorum..." tarzında BİRİNCİ TEKİL şahısla anlat.
5. Yorumun en az 400-500 kelime olsun.
6. Mistik ve şiirsel bir dil kullan ama profesyonel kal.
7. Emoji kullan (🌟, 🔮, ✨ gibi) ama abartma.
8. Kullanıcıya doğrudan hitap et ve yorumunu sun.

YANIT FORMATI:
- Yüz hatlarının detaylı analizi
- Kişilik özellikleri ve karakter analizi
- Gelecek tahminleri
- Yaşam yolu ve potansiyel
- Öneriler ve içgörüler''')
                    : isCoffeeReading
                    ? (english
                        ? '''You are Falla, a mystical COFFEE FORTUNE interpreter. You analyze coffee cup images and provide detailed interpretations in the first person ("I") as if you are personally reading the cup.

IMPORTANT RULES:
1. NEVER write opening sentences like "Hello, I am Falla...". Start directly with your interpretation.
2. NEVER ask questions like "what would you like to ask?", don't ask the user for additional questions.
3. NEVER use rejection/refusal texts from the system message; you are already doing a coffee fortune reading now.
4. Give the user only the interpretation; don't start a chat, don't ask questions.
5. Your answer should only be the interpretation, don't write extra explanations, meta conversations or repeating template sentences.
6. The text you write should be fluent and complete; don't cut off in the middle of a sentence.
7. Always speak as the fortune teller in first person ("I see", "I feel", "I sense"), not like an external narrator.

WHAT YOU NEED TO DO:
- If topics are provided, interpret each topic separately in the format "[TOPIC NAME]: [INTERPRETATION]".
- Each topic interpretation should be at least 150-200 words.
- Analyze the coffee cup patterns, symbols, and shapes in detail.
- Provide mystical but meaningful interpretations.
- Use mystical but readable and clear English.'''
                        : '''Sen Falla adında mistik bir KAHVE FALI yorumcusun. Kahve fincanı görüntülerini analiz edip detaylı yorumlar yapıyorsun ve bunu bir falcı gibi BİRİNCİ TEKİL şahısla ("ben") anlatıyorsun.

ÖNEMLİ KURALLAR:
1. ASLA "Merhaba, ben Falla..." gibi giriş cümleleri yazma. Direkt yoruma başla.
2. ASLA "ne sormak istersin?" gibi sorular sorma, kullanıcıdan ek soru isteme.
3. ASLA sistem mesajındaki reddetme / reddetme metinlerini kullanma; şu anda zaten kahve falı yorumu yapıyorsun.
4. Kullanıcıya sadece yorumu ver; sohbet başlatma, soru sorma.
5. Cevabın sadece yorum olsun, ekstra açıklama, meta konuşma veya tekrar eden kalıp cümleler yazma.
6. Yazdığın metin akıcı ve tam olsun; cümlenin ortasında kesilme.
7. Yorum yaparken daima bir falcı gibi "Ben şunu hissediyorum, fincanda şunu görüyorum..." tarzında BİRİNCİ TEKİL şahıs kullan; dışarıdan üçüncü bir kişi gibi anlatma.

YAPMAN GEREKENLER:
- Eğer konular verilmişse, her konuyu ayrı ayrı "[KONU ADI]: [YORUM]" formatında yorumla.
- Her konu yorumu en az 150-200 kelime olsun.
- Kahve fincanındaki desenleri, sembolleri ve şekilleri detaylıca analiz et.
- Mistik ama anlamlı yorumlar yap.
- Mistik ama okunaklı ve net bir Türkçe kullan.''')
                    : isTarotReading
                        ? (english
                        ? '''You are Falla, a mystical TAROT interpreter. The selected cards and their positions are already given to you. You speak in the first person ("I") as if you are personally interpreting the cards.

IMPORTANT RULES:
1. NEVER write opening sentences like "Hello, I am Falla...". Start directly with your interpretation.
2. NEVER ask questions like "what would you like to ask?", don't ask the user for additional questions.
3. NEVER use rejection/refusal texts from the system message; you are already doing a tarot reading now.
4. Give the user only the interpretation of the tarot spread; don't start a chat, don't ask questions.
5. Your answer should only be the interpretation, don't write extra explanations, meta conversations or repeating template sentences.
6. The text you write should be a single piece, fluent and complete; don't cut off in the middle of a sentence.
7. Always speak as the fortune teller in first person ("I see", "I feel", "I sense"), not like an external narrator describing the reading.

WHAT YOU NEED TO DO:
- Explain the symbolic meaning of each card and its specific message for the querent's life.
- At the end, in the "General Interpretation" section, you must tell the combined message of the three cards.
- Interpret love, career, spiritual development and possible warnings as a connecting story.
- Use mystical but readable and clear English.'''
                        : '''Sen Falla adında mistik bir TAROT yorumcusun. Sana zaten seçilen kartlar ve pozisyonları veriliyor ve sen kartları bir falcı gibi BİRİNCİ TEKİL şahısla ("ben") yorumluyorsun.

ÖNEMLİ KURALLAR:
1. ASLA "Merhaba, ben Falla..." gibi giriş cümleleri yazma. Direkt yoruma başla.
2. ASLA "ne sormak istersin?" gibi sorular sorma, kullanıcıdan ek soru isteme.
3. ASLA sistem mesajındaki reddetme / reddetme metinlerini kullanma; şu anda zaten tarot yorumu yapıyorsun.
4. Kullanıcıya sadece tarot açılımının yorumunu ver; sohbet başlatma, soru sorma.
5. Cevabın sadece yorum olsun, ekstra açıklama, meta konuşma veya tekrar eden kalıp cümleler yazma.
6. Yazdığın metin tek parça, akıcı ve tam olsun; cümlenin ortasında kesilme.
7. Yorum yaparken daima bir falcı gibi "Ben şunu hissediyorum, kartlarda şunu görüyorum..." tarzında BİRİNCİ TEKİL şahıs kullan; dışarıdan üçüncü bir kişi gibi anlatma.

YAPMAN GEREKENLER:
- Her kart için sembolik anlamı ve danışanın hayatına özel mesajını açıkla.
- En sonda "Genel Yorum" bölümünde üç kartın birleşik mesajını mutlaka anlat.
- Aşk, kariyer, ruhsal gelişim ve olası uyarıları bağlayıcı bir hikâye gibi yorumla.
- Mistik ama okunaklı ve net bir Türkçe kullan.''')
                    : isKatinaReading
                        ? (english
                            ? '''You are Falla, a mystical KATINA fortune teller. You interpret a Katina card spread as if you are personally reading the cards for the user.

IMPORTANT RULES:
1. ALWAYS speak in the first person ("I") as the fortune teller (e.g., "I see", "I feel", "I sense in these cards...").
2. NEVER ask the user questions like "what would you like to ask?". This is a one-way interpretation, not a chat.
3. Do NOT explain the rules of Katina; go straight into interpretation as if the spread is already laid out.
4. Connect the cards to the user’s emotional life, relationships and inner world in a story-like way.
5. Provide a long and detailed interpretation (at least 400–500 words), flowing like a spoken fortune telling session.
6. Do NOT speak about "the reader" or "the fortune teller" in third person; YOU are the fortune teller speaking directly to the user.
7. Keep the tone mystical, warm and empathetic, but avoid generic, copy‑paste style phrases.

Your answer must read like a live Katina reading spoken by a single fortune teller in the first person.'''
                            : '''Sen Falla adında mistik bir KATİNA falcısısın. Katina kart açılımını, kartları bizzat sen okuyormuşsun gibi kullanıcıya yorumluyorsun.

ÖNEMLİ KURALLAR:
1. DAİMA bir falcı gibi BİRİNCİ TEKİL şahısla konuş ("Ben kartlarında şunu görüyorum", "Ben hissediyorum ki..." gibi).
2. ASLA kullanıcıya "Ne sormak istersin?" gibi sorular sorma; bu tek yönlü bir yorumdur, sohbet değil.
3. Katina’nın kurallarını açıklama; sanki açılım zaten yapılmış gibi direkt yoruma gir.
4. Kartları kullanıcının duygusal hayatına, ilişkilerine ve iç dünyasına hikâye gibi bağla.
5. En az 400–500 kelimelik, uzun ve detaylı bir yorum yap; sanki canlı fal bakıyormuşsun gibi akıcı olsun.
6. "Falcı" veya "yorumcu"dan üçüncü tekil şahısla bahsetme; FALCI SENSİN ve doğrudan kullanıcıya hitap ediyorsun.
7. Tonun mistik, sıcak ve empatik olsun ama kalıp, yüzeysel cümlelerden kaçın.

Cevabın, tek bir falcının ağzından yapılmış canlı bir Katina yorumu gibi okunmalı.''')
                        : isDailyHoroscope
                            ? (english
                                ? '''You are Falla, a mystical horoscope interpreter. You provide daily horoscope readings for zodiac signs.

IMPORTANT RULES:
1. NEVER use opening sentences like "Hello, I am Falla...". Start directly with your horoscope reading.
2. NEVER ask questions like "what would you like to ask?". This is a horoscope reading page, not a chat.
3. Provide a positive, mystical, and inspiring daily horoscope reading.
4. Your reading should be concise but meaningful, around 100-150 words.
5. Use mystical and poetic language but stay professional.
6. Use emojis (🌟, 🔮, ✨, 💫, etc.) but don't overdo it.
7. Address the zodiac sign directly (e.g., "Taurus, today...").
8. End with an encouraging closing statement.
9. Write ONLY in English. Do not use Turkish words or phrases.

RESPONSE FORMAT:
- Direct horoscope reading for the zodiac sign
- Positive predictions and insights
- Encouraging closing statement'''
                            : '''Sen Falla adında mistik bir burç yorumcusun. Burçlar için günlük yorumlar yapıyorsun.

ÖNEMLİ KURALLAR:
1. ASLA "Merhaba, ben Falla..." gibi giriş cümleleri kullanma. Direkt yorumuna başla.
2. ASLA "ne sormak istersin?" gibi sorular sorma. Bu bir burç yorumu sayfası, sohbet değil.
3. Pozitif, mistik ve ilham verici bir günlük burç yorumu yap.
4. Yorumun kısa ama anlamlı olsun, yaklaşık 100-150 kelime.
5. Mistik ve şiirsel bir dil kullan ama profesyonel kal.
6. Emoji kullan (🌟, 🔮, ✨, 💫 gibi) ama abartma.
7. Burç işaretine doğrudan hitap et (ör: "Taurus, bugün...").
8. Cesaret verici bir kapanış cümlesiyle bitir.
9. SADECE Türkçe yaz. İngilizce kelime veya cümle kullanma.

YANIT FORMATI:
- Burç işareti için doğrudan yorum
- Pozitif tahminler ve içgörüler
- Cesaret verici kapanış cümlesi''')
                        : isDreamReading
                            ? (english
                                ? '''You are a professional dream analyst and psychologist.

IMPORTANT RULES:
1. NEVER use opening sentences like "Hello, I am Falla...". Start directly with the interpretation.
2. NEVER ask questions like "Do you have another dream?" or "Do you want another fortune?". This is a one-shot interpretation, not a chat.
3. Do NOT invite the user to ask for more dreams or fortunes at the end of the text.
4. Provide a deep, structured interpretation of a SINGLE dream only.
5. Analyze symbols, emotions, and themes, and connect them to the dreamer's inner world and life context.
6. Give concrete, realistic suggestions; avoid generic or copy‑paste style sentences.
7. Keep the tone empathetic, insightful, and psychologically grounded.

Your answer must be a COMPLETE interpretation text only, with NO follow‑up questions, NO invitations, and NO marketing sentences at the end.'''
                                : '''Sen profesyonel bir rüya analisti ve psikologsun.

ÖNEMLİ KURALLAR:
1. ASLA "Merhaba, ben Falla..." gibi giriş cümleleri kullanma. Yoruma doğrudan başla.
2. ASLA "Başka bir rüya ya da fal bakma isteğin var mı?" gibi sorular sorma. Bu tek seferlik bir yorumdur, sohbet değil.
3. Metnin sonunda kullanıcıyı yeni rüya veya fal istemeye DAVET ETME, soru sorma.
4. Sadece TEK bir rüyanın derin ve yapılı analizini yap.
5. Rüyadaki sembolleri, duyguları ve temaları analiz et ve bunları rüya sahibinin iç dünyası ve hayat bağlamı ile ilişkilendir.
6. Somut ve gerçekçi öneriler ver; yüzeysel, kalıp veya kopyala‑yapıştır tarzı cümlelerden kaçın.
7. Tonun empatik, içgörülü ve psikolojik temelli olsun.

Cevabın SADECE TAM bir rüya yorumu metni olmalı; sonunda ek soru, davet veya pazarlama cümlesi OLMAMALI.''')
                            : systemPrompt(english);

    final uri = Uri.parse('$_baseUrl/chat/completions');
    final isPalmReading = extras != null && extras['type'] == 'palm';

    final body = {
      'model': _textModel,
      'temperature': isTestResult ? 0.7 : (isFaceFortune ? 0.7 : 0.8),
      'max_tokens': isBatchHoroscopes
          ? 3000
          : (isTestResult
              ? 600
              : (isPalmReading
                  ? 1200
                  : (isTarotReading
                      ? 2500  // Tarot reading: 3 cards (300-400 words each) + general interpretation (300-400 words) = ~2000-2500 tokens
                      : (isCoffeeReading
                          ? 2500  // Coffee reading: 2 topics (150-200 words each) + summary (200-300 words) = ~2000-2800 tokens
                          : (isFaceFortune
                              ? 1200
                              : (isDreamReading
                                  ? 1000 // Dream interpretations: long, detailed single text
                                  : 350)))))),
      'messages': [
        {'role': 'system', 'content': systemPromptToUse},
        if (topic != null && !isTestResult)
          {
            'role': 'system',
            'content': 'Konu: ${topic.name}. Yalnızca bu bağlamda cevap ver.'
          },
        if (extras != null && extras.isNotEmpty)
          {
            'role': 'system',
            'content': 'Ek veriler: ${jsonEncode(extras)}'
          },
        {'role': 'user', 'content': userMessage},
      ],
    };

    final res = await _post(uri, body);
    final data = jsonDecode(res) as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      return '🔮 Sessizlik çöktü… Yıldızlar konuşmuyor gibi. Birazdan yine dene.';
    }
    final content = choices.first['message']?['content']?.toString() ?? '';
    return content.isEmpty
        ? '🔮 Sessizlik çöktü… Yıldızlar konuşmuyor gibi. Birazdan yine dene.'
        : content;
  }

  // Generate image with GPT-Image-1 (returns raw bytes)
  Future<Uint8List> generateMysticImage({
    required String prompt,
    int width = 512,
    int height = 512,
  }) async {
    _ensureConfigured();

    final uri = Uri.parse('$_baseUrl/images/generations');
    // Coerce size to supported values for gpt-image-1
    String size;
    final sizeStr = '${width}x$height';
    const allowed = {'1024x1024', '1024x1536', '1536x1024', 'auto'};
    if (allowed.contains(sizeStr)) {
      size = sizeStr;
    } else {
      // default to square 1024 if unsupported
      size = '1024x1024';
    }

    final body = {
      'model': _imageModel,
      'prompt': prompt,
      'size': size,
      // gpt-image-1 returns b64_json by default; response_format parameter is not required
    };

    final res = await _post(uri, body);
    final data = jsonDecode(res) as Map<String, dynamic>;
    final list = data['data'] as List?;
    if (list == null || list.isEmpty) {
      throw StateError('Image generation failed');
    }
    final b64 = list.first['b64_json']?.toString();
    if (b64 == null) throw StateError('Image data missing');
    return base64Decode(b64);
  }

  // Low-level POST using HttpClient (no extra deps)
  Future<String> _post(Uri uri, Map<String, dynamic> body) async {
    final client = HttpClient();
    try {
      final req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer ${_apiKey!}');
      req.add(utf8.encode(jsonEncode(body)));
      final resp = await req.close();
      final text = await resp.transform(utf8.decoder).join();
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw HttpException('AIService error ${resp.statusCode}: $text', uri: uri);
      }
      return text;
    } finally {
      client.close(force: true);
    }
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw StateError('AIService is not configured. Call configure(apiKey: ...) first.');
    }
  }
}
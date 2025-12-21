/// API Endpoint sabitleri
/// Falla uygulaması için tüm API endpoint'leri
class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://api.falla.com';
  static const String openaiApi = 'https://api.openai.com/v1';
  static const String firebaseApi = 'https://firestore.googleapis.com/v1';
  
  // Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  
  // Fortune reading endpoints
  static const String fortuneReading = '/fortune/reading';
  static const String tarotReading = '/fortune/tarot';
  static const String palmReading = '/fortune/palm';
  static const String astrologyReading = '/fortune/astrology';
  static const String dreamInterpretation = '/fortune/dream';
  static const String coffeeReading = '/fortune/coffee';
  
  // AI Integration endpoints
  static const String openaiChat = '/chat/completions';
  static const String openaiImage = '/images/generations';
  static const String openaiModeration = '/moderations';
  
  // User management endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/update';
  static const String userKarma = '/user/karma';
  static const String userHistory = '/user/history';
  
  // Aura matching endpoints
  static const String auraMatching = '/aura/matching';
  static const String biorhythmAnalysis = '/aura/biorhythm';
  static const String compatibilityCheck = '/aura/compatibility';
  static const String dailyMatches = '/aura/daily-matches';
  
  // Social features endpoints
  static const String socialFeed = '/social/feed';
  static const String friendRequests = '/social/friend-requests';
  static const String chatMessages = '/social/chat';
  static const String sendMessage = '/social/send-message';
  static const String blockUser = '/social/block';
  static const String reportUser = '/social/report';
  
  // Mini games endpoints
  static const String wheelOfFortune = '/games/wheel';
  static const String cardGames = '/games/cards';
  static const String predictionGames = '/games/prediction';
  static const String gameRewards = '/games/rewards';
  
  // Admin panel endpoints
  static const String adminUsers = '/admin/users';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminModeration = '/admin/moderation';
  static const String adminSettings = '/admin/settings';
  static const String adminReports = '/admin/reports';
  
  // Payment endpoints
  static const String premiumSubscription = '/payment/subscription';
  static const String inAppPurchase = '/payment/purchase';
  static const String paymentHistory = '/payment/history';
  static const String refundRequest = '/payment/refund';
  
  // Analytics endpoints
  static const String userAnalytics = '/analytics/user';
  static const String appAnalytics = '/analytics/app';
  static const String revenueAnalytics = '/analytics/revenue';
  static const String engagementAnalytics = '/analytics/engagement';
  
  // Content endpoints
  static const String tarotCards = '/content/tarot-cards';
  static const String oracleCards = '/content/oracle-cards';
  static const String zodiacSigns = '/content/zodiac-signs';
  static const String dreamSymbols = '/content/dream-symbols';
  static const String palmLines = '/content/palm-lines';
  
  // Notification endpoints
  static const String sendNotification = '/notifications/send';
  static const String notificationHistory = '/notifications/history';
  static const String notificationSettings = '/notifications/settings';
  
  // File upload endpoints
  static const String uploadImage = '/upload/image';
  static const String uploadAudio = '/upload/audio';
  static const String uploadVideo = '/upload/video';
  static const String deleteFile = '/upload/delete';
  
  // Utility endpoints
  static const String healthCheck = '/health';
  static const String versionCheck = '/version';
  static const String maintenanceMode = '/maintenance';
  static const String featureFlags = '/features';
  
  // External API endpoints
  static const String weatherApi = 'https://api.openweathermap.org/data/2.5/weather';
  static const String horoscopeApi = 'https://api.horoscope.com/v1';
  static const String numerologyApi = 'https://api.numerology.com/v1';
  static const String chineseZodiacApi = 'https://api.chinese-zodiac.com/v1';
  
  // WebSocket endpoints
  static const String chatWebSocket = 'wss://api.falla.com/chat';
  static const String realTimeUpdates = 'wss://api.falla.com/updates';
  static const String liveFortune = 'wss://api.falla.com/live-fortune';
  
  // Helper methods
  static String getFortuneEndpoint(String fortuneType) {
    switch (fortuneType.toLowerCase()) {
      case 'tarot':
        return tarotReading;
      case 'palm':
        return palmReading;
      case 'astrology':
        return astrologyReading;
      case 'dream':
        return dreamInterpretation;
      case 'coffee':
        return coffeeReading;
      default:
        return fortuneReading;
    }
  }
  
  static String getUserEndpoint(String userId) {
    return '$userProfile/$userId';
  }
  
  static String getChatEndpoint(String chatId) {
    return '$chatMessages/$chatId';
  }
  
  static String getGameEndpoint(String gameType) {
    switch (gameType.toLowerCase()) {
      case 'wheel':
        return wheelOfFortune;
      case 'cards':
        return cardGames;
      case 'prediction':
        return predictionGames;
      default:
        return wheelOfFortune;
    }
  }
  
  static String getAdminEndpoint(String resource) {
    switch (resource.toLowerCase()) {
      case 'users':
        return adminUsers;
      case 'analytics':
        return adminAnalytics;
      case 'moderation':
        return adminModeration;
      case 'settings':
        return adminSettings;
      case 'reports':
        return adminReports;
      default:
        return adminUsers;
    }
  }
}

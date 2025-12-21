import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

/// Google AdMob entegrasyonu
/// Banner, interstitial, rewarded ads yönetimi
class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  // Production AdMob Ad Unit IDs
  static String get _bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-5956124359067452/4128426232'
      : 'ca-app-pub-5956124359067452/3098716914';
  static String get _interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-5956124359067452/1158647968'
      : 'ca-app-pub-5956124359067452/9225141569';

  static String get _rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-5956124359067452/7944027092'
      : 'ca-app-pub-5956124359067452/6477643001';
  
  // Public getters for ad unit IDs
  String get bannerAdUnitId => _bannerAdUnitId;
  String get interstitialAdUnitId => _interstitialAdUnitId;
  String get rewardedAdUnitId => _rewardedAdUnitId;

  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  // Ad state
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;
  
  // Ad revenue tracking
  double _totalAdRevenue = 0.0;
  int _adImpressions = 0;
  int _adClicks = 0;

  // Getters
  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;
  double get totalAdRevenue => _totalAdRevenue;
  int get adImpressions => _adImpressions;
  int get adClicks => _adClicks;

  /// Initialize Mobile Ads SDK
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      
      // Configure test devices for debug mode
      if (kDebugMode) {
        final requestConfiguration = RequestConfiguration(
          testDeviceIds: [
            '19b2ec0eccd418346992bdb2a9ccf5bc', // From iOS console log
            // Add more test device IDs as needed
          ],
        );
        MobileAds.instance.updateRequestConfiguration(requestConfiguration);
        print('🎯 AdMob SDK initialized with test device configuration');
      } else {
        print('🎯 AdMob SDK initialized (production mode)');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ AdMob SDK initialization failed: $e');
        print('Stack trace: $stackTrace');
        print('⚠️ Check Info.plist: GADApplicationIdentifier must be set');
        print('⚠️ Verify Ad Unit IDs are correct in AdMob console');
      }
      rethrow;
    }
  }

  /// Create and load banner ad
  Future<BannerAd?> createBannerAd({
    required AdSize adSize,
    required String adUnitId,
    Function(BannerAd)? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    try {
      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerLoaded = true;
            _adImpressions++;
            if (kDebugMode) {
              print('🎯 Banner ad loaded successfully');
            }
            onAdLoaded?.call(ad as BannerAd);
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerLoaded = false;
            if (kDebugMode) {
              print('❌ Banner ad failed to load: ${error.message}');
            }
            onAdFailedToLoad?.call(error);
          },
          onAdOpened: (ad) {
            _adClicks++;
            if (kDebugMode) {
              print('🎯 Banner ad opened');
            }
          },
          onAdClosed: (ad) {
            if (kDebugMode) {
              print('🎯 Banner ad closed');
            }
          },
        ),
      );

      await _bannerAd!.load();
      return _bannerAd;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating banner ad: $e');
      }
      return null;
    }
  }

  /// Create and load interstitial ad
  Future<InterstitialAd?> createInterstitialAd({
    required String adUnitId,
    Function(InterstitialAd)? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
    Function()? onAdDismissed,
  }) async {
    try {
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialLoaded = true;
            _adImpressions++;
            if (kDebugMode) {
              print('🎯 Interstitial ad loaded successfully');
            }
            onAdLoaded?.call(ad);
          },
          onAdFailedToLoad: (error) {
            _isInterstitialLoaded = false;
            if (kDebugMode) {
              print('❌ Interstitial ad failed to load: ${error.message}');
            }
            onAdFailedToLoad?.call(error);
          },
        ),
      );

      return _interstitialAd;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating interstitial ad: $e');
      }
      return null;
    }
  }

  /// Create and load rewarded ad
  Future<RewardedAd?> createRewardedAd({
    required String adUnitId,
    Function(RewardedAd)? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
    Function(RewardItem)? onUserEarnedReward,
  }) async {
    try {
      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedLoaded = true;
            _adImpressions++;
            if (kDebugMode) {
              print('🎯 Rewarded ad loaded successfully');
            }
            onAdLoaded?.call(ad);
          },
          onAdFailedToLoad: (error) {
            _isRewardedLoaded = false;
            if (kDebugMode) {
              print('❌ Rewarded ad failed to load: ${error.message}');
            }
            onAdFailedToLoad?.call(error);
          },
        ),
      );

      return _rewardedAd;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating rewarded ad: $e');
      }
      return null;
    }
  }

  /// Show interstitial ad
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd == null || !_isInterstitialLoaded) {
      if (kDebugMode) {
        print('❌ Interstitial ad not loaded');
      }
      return false;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          if (kDebugMode) {
            print('🎯 Interstitial ad showed full screen content');
          }
        },
        onAdDismissedFullScreenContent: (ad) {
          _interstitialAd = null;
          _isInterstitialLoaded = false;
          if (kDebugMode) {
            print('🎯 Interstitial ad dismissed');
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _interstitialAd = null;
          _isInterstitialLoaded = false;
          if (kDebugMode) {
            print('❌ Interstitial ad failed to show: ${error.message}');
          }
        },
      );

      await _interstitialAd!.show();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error showing interstitial ad: $e');
      }
      return false;
    }
  }

  /// Show rewarded ad
  Future<RewardItem?> showRewardedAd() async {
    if (_rewardedAd == null || !_isRewardedLoaded) {
      if (kDebugMode) {
        print('❌ Rewarded ad not loaded');
      }
      return null;
    }

    try {
      final completer = Completer<RewardItem?>();
      
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          if (kDebugMode) {
            print('🎯 Rewarded ad showed full screen content');
          }
        },
        onAdDismissedFullScreenContent: (ad) {
          _rewardedAd = null;
          _isRewardedLoaded = false;
          if (kDebugMode) {
            print('🎯 Rewarded ad dismissed');
          }
          // If reward wasn't earned and ad was dismissed, complete with null
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          _rewardedAd = null;
          _isRewardedLoaded = false;
          if (kDebugMode) {
            print('❌ Rewarded ad failed to show: ${error.message}');
          }
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, rewardItem) {
          _totalAdRevenue += rewardItem.amount.toDouble();
          if (kDebugMode) {
            print('🎯 User earned reward: ${rewardItem.amount} ${rewardItem.type}');
          }
          // Complete with reward when user earns it
          if (!completer.isCompleted) {
            completer.complete(rewardItem);
          }
        },
      );

      // Wait for the reward to be earned or ad to be dismissed
      return await completer.future;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error showing rewarded ad: $e');
      }
      return null;
    }
  }

  /// Dispose banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  /// Dispose interstitial ad
  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialLoaded = false;
  }

  /// Dispose rewarded ad
  void disposeRewardedAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedLoaded = false;
  }

  /// Dispose all ads
  void disposeAllAds() {
    disposeBannerAd();
    disposeInterstitialAd();
    disposeRewardedAd();
  }

  /// Get ad revenue analytics
  Map<String, dynamic> getAdAnalytics() {
    return {
      'totalRevenue': _totalAdRevenue,
      'impressions': _adImpressions,
      'clicks': _adClicks,
      'ctr': _adImpressions > 0 ? (_adClicks / _adImpressions) * 100 : 0.0,
      'revenuePerImpression': _adImpressions > 0 ? _totalAdRevenue / _adImpressions : 0.0,
    };
  }

  /// Reset analytics
  void resetAnalytics() {
    _totalAdRevenue = 0.0;
    _adImpressions = 0;
    _adClicks = 0;
  }

  /// Check if ads are available
  bool get areAdsAvailable {
    return _isBannerLoaded || _isInterstitialLoaded || _isRewardedLoaded;
  }

  /// Get default banner ad size
  static AdSize getDefaultBannerSize() {
    return AdSize.banner;
  }

}

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/ads_service.dart';
import 'package:flutter/foundation.dart';

/// Banner reklam widget'ı
/// Otomatik olarak reklam yükler ve gösterir
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final String? adUnitId;
  final EdgeInsets? margin;
  
  const BannerAdWidget({
    Key? key,
    this.adSize = AdSize.banner,
    this.adUnitId,
    this.margin,
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  final AdsService _adsService = AdsService();

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adUnitId = widget.adUnitId ?? _adsService.bannerAdUnitId;
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('❌ Banner ad failed to load: ${error.message}');
          }
          ad.dispose();
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
        onAdOpened: (_) {
          if (kDebugMode) {
            print('🎯 Banner ad opened');
          }
        },
        onAdClosed: (_) {
          if (kDebugMode) {
            print('🎯 Banner ad closed');
          }
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin ?? EdgeInsets.zero,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}


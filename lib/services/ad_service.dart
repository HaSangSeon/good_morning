import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;

  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3702899361747571/1772844688'; // Android Real ID (배포용)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3702899361747571/3890324259'; // Android Real ID (배포용)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  void loadInterstitialAd() {
    try {
      if (_isAdLoading || interstitialAdUnitId.isEmpty) return;

      _isAdLoading = true;
      InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isAdLoading = false;
          },
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
            _interstitialAd = null;
            _isAdLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('Ad load exception: $e');
      _isAdLoading = false;
    }
  }

  int _shareCount = 0;

  /// 공유 3회당 1회씩만 전면 광고 노출 (사용자 피로도 방지)
  void showInterstitialAdOnShare({VoidCallback? onAdDismissed}) {
    _shareCount++;
    debugPrint('AdService: 현재 공유 횟수 = $_shareCount (3회당 1회 광고 노출)');
    if (_shareCount % 3 == 0) {
      showInterstitialAd(onAdDismissed: onAdDismissed);
    } else {
      onAdDismissed?.call();
    }
  }

  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      onAdDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Load the next ad
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _interstitialAd = null;
        onAdDismissed?.call();
      },
    );

    _interstitialAd!.show();
  }
}

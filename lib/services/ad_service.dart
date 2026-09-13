import 'dart:io';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  /// 📸 스토어 등록용 프로덕션 스크린샷 캡처를 위한 배너 광고 임시 숨김 플래그 (현재 정상 운영 모드)
  static bool hideBannerAdsForScreenshots = false;

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3702899361747571/3890324259'; // Android Real ID (배포용)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  // 공유시 전면광고 ID
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3702899361747571/1772844688'; // 공유시전면광고 Real ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  // Medium Rectangle 광고 ID (현재는 배너 광고 ID와 동일하게 사용하거나, 리얼 ID가 나오면 교체)
  String get mediumRectangleAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3702899361747571/3890324259'; // 임시로 배너 ID 재사용 (300x250)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  /// 공유 시 광고 호출 (인터스티셜 미사용 시 안전하게 콜백 호출)
  void showInterstitialAdOnShare({VoidCallback? onAdDismissed}) {
    onAdDismissed?.call();
  }
}

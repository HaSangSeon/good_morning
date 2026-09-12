import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3702899361747571/3890324259'; // Android Real ID (배포용)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
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

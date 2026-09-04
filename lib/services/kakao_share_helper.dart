import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class KakaoShareHelper {
  static const MethodChannel _kakaoChannel =
      MethodChannel('com.sintong.good_morning/kakao_share');

  /// 안드로이드 기기에 카카오톡이 설치되어 있는지 확인
  static Future<bool> isKakaoInstalled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool isInstalled =
          await _kakaoChannel.invokeMethod('isKakaoInstalled') ?? false;
      return isInstalled;
    } catch (_) {
      return false;
    }
  }

  /// 카카오톡 직접 공유 (이미지 및/또는 텍스트)
  /// 카카오톡 미설치 기기거나 iOS인 경우 share_plus 시스템 공유 시트로 안전하게 폴백
  static Future<bool> share({
    String? filePath,
    String? text,
    String? subject,
  }) async {
    bool sharedDirectly = false;

    if (Platform.isAndroid) {
      try {
        final bool isInstalled = await isKakaoInstalled();
        if (isInstalled) {
          sharedDirectly = await _kakaoChannel.invokeMethod('shareToKakao', {
            if (filePath != null) 'filePath': filePath,
            if (text != null) 'text': text,
          }) ?? false;
        }
      } catch (e) {
        debugPrint('KakaoShareHelper direct share exception: $e');
      }
    }

    // 카카오톡 미설치 기기이거나 iOS 등에서는 표준 시스템 공유 시트 실행
    if (!sharedDirectly) {
      if (filePath != null && filePath.isNotEmpty) {
        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'image/jpeg')],
          text: text,
          subject: subject,
        );
      } else if (text != null && text.isNotEmpty) {
        await Share.share(
          text,
          subject: subject,
        );
      }
    }

    return sharedDirectly;
  }
}

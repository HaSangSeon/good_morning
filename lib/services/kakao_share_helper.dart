import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:share_plus/share_plus.dart';

class KakaoShareHelper {
  static const MethodChannel _kakaoChannel =
      MethodChannel('com.sintong.good_morning/kakao_share');

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.sintong.good_morning';

  /// 안드로이드 기기에 카카오톡이 설치되어 있는지 확인
  static Future<bool> isKakaoInstalled() async {
    if (!Platform.isAndroid) return false;
    try {
      final bool isInstalled =
          await ShareClient.instance.isKakaoTalkSharingAvailable();
      if (isInstalled) return true;
      final bool isNativeInstalled =
          await _kakaoChannel.invokeMethod('isKakaoInstalled') ?? false;
      return isNativeInstalled;
    } catch (_) {
      return false;
    }
  }

  /// 카카오톡 피드 템플릿(카드 이미지 + 다운로드 링크 버튼) 공유
  /// SDK 실패 시 기존 네이티브 인텐트 / share_plus로 안전하게 자동 폴백
  static Future<bool> share({
    String? filePath,
    String? text,
    String? subject,
  }) async {
    bool sharedDirectly = false;

    // 1. 카카오톡이 설치되어 있고 이미지 파일이 존재하는 경우: 카카오 SDK 피드 템플릿 전송
    if (Platform.isAndroid && filePath != null && filePath.isNotEmpty) {
      try {
        final bool isAvailable =
            await ShareClient.instance.isKakaoTalkSharingAvailable();

        if (isAvailable) {
          final File imageFile = File(filePath);
          if (imageFile.existsSync()) {
            // 카카오 이미지 서버에 카드 업로드 (링크 말풍선 고화질 노출용)
            final ImageUploadResult uploadResult =
                await ShareClient.instance.uploadImage(imagePath: filePath);
            final String imageUrl = uploadResult.infos.original.url;

            final FeedTemplate template = FeedTemplate(
              content: Content(
                imageUrl: Uri.parse(imageUrl),
                link: Link(
                  androidExecutionParams: {'route': '/home'},
                  webUrl: Uri.parse(playStoreUrl),
                  mobileWebUrl: Uri.parse(playStoreUrl),
                ),
              ),
              buttons: [
                Button(
                  title: '나도 카드 만들기',
                  link: Link(
                    androidExecutionParams: {'route': '/home'},
                    webUrl: Uri.parse(playStoreUrl),
                    mobileWebUrl: Uri.parse(playStoreUrl),
                  ),
                ),
              ],
            );

            await ShareClient.instance.shareDefault(template: template);
            sharedDirectly = true;
          }
        }
      } catch (e) {
        debugPrint('KakaoShareHelper FeedTemplate share exception: $e');
      }

      // 2. 카카오 SDK 피드 템플릿 실패 시 (네트워크 오류, 키 해시 설정 대기 등): 기존 고속 직접 전송으로 폴백
      if (!sharedDirectly) {
        try {
          final bool isInstalled = await _kakaoChannel.invokeMethod('isKakaoInstalled') ?? false;
          if (isInstalled) {
            sharedDirectly = await _kakaoChannel.invokeMethod('shareToKakao', {
              'filePath': filePath,
              'text': text,
            }) ?? false;
          }
        } catch (e) {
          debugPrint('KakaoShareHelper fallback direct share exception: $e');
        }
      }
    }

    // 3. 카카오톡 미설치 기기이거나 모든 카카오 전송이 불가할 때: 표준 시스템 공유 시트 실행
    if (!sharedDirectly) {
      if (filePath != null && filePath.isNotEmpty) {
        // ignore: deprecated_member_use
        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'image/jpeg')],
          text: text,
          subject: subject,
        );
      } else if (text != null && text.isNotEmpty) {
        // ignore: deprecated_member_use
        await Share.share(
          text,
          subject: subject,
        );
      }
    }

    return sharedDirectly;
  }
}

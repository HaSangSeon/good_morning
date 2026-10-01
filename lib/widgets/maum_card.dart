import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'keep_all_text.dart';

/// 메인 화면과 수정 팝업에서 **import하여 사용하는 유일한 카드 위젯**.
/// 이 파일 하나가 카드 렌더링의 유일한 소스이므로
/// 어디에서 불러와도 100% 동일한 화면이 보장된다.
class MaumCard extends StatelessWidget {
  /// 카드에 표시할 텍스트
  final String text;

  /// 배경 이미지
  final ImageProvider backgroundImage;

  /// 텍스트 스타일 (폰트, 크기, 행간 등)
  final TextStyle textStyle;

  /// 메인 화면에서 캡처용으로 전달 (수정 팝업에서는 null)
  final ScreenshotController? screenshotController;

  /// 편집 모드일 때 텍스트 대신 표시할 위젯 (TextField 등)
  /// null이면 기본 Text 위젯으로 표시 (보기 모드)
  final Widget? editingWidget;

  /// 편집 모드일 때 카드 위에 띄울 추가 위젯들 (글자 수 카운터 등)
  final List<Widget> overlayWidgets;

  const MaumCard({
    super.key,
    required this.text,
    required this.backgroundImage,
    required this.textStyle,
    this.screenshotController,
    this.editingWidget,
    this.overlayWidgets = const [],
  });

  @override
  Widget build(BuildContext context) {
    // ── 카드 내부 콘텐츠 ──
    Widget cardInner = AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 배경 이미지
          Image(
            image: backgroundImage,
            fit: BoxFit.cover,
          ),
          // 2. 반투명 오버레이
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
          // 3. 텍스트 영역 (보기 모드 or 편집 모드)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Center(
              child: editingWidget ??
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 섀도우 레이어 (이모지 렌더링 버그를 피하기 위해 TextStyle.shadows 대신 ImageFiltered 사용)
                        ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                          child: Text(
                            text.keepAll,
                            textAlign: TextAlign.center,
                            style: textStyle.copyWith(color: Colors.black87),
                          ),
                        ),
                        // 실제 텍스트
                        Text(
                          text.keepAll,
                          textAlign: TextAlign.center,
                          style: textStyle,
                        ),
                      ],
                    ),
                  ),
            ),
          ),
          // 4. 추가 오버레이 위젯 (글자 수 카운터 등)
          ...overlayWidgets,
        ],
      ),
    );

    // ── Screenshot 래퍼 (메인 화면 전용) ──
    if (screenshotController != null) {
      cardInner = Screenshot(controller: screenshotController!, child: cardInner);
    }

    // ── 외부 컨테이너 (그림자 + 라운딩) ──
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: cardInner,
      ),
    );
  }
}

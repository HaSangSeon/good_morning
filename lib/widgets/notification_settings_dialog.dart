import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';

class NotificationSettingsDialog extends StatefulWidget {
  const NotificationSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const NotificationSettingsDialog(),
    );
  }

  @override
  State<NotificationSettingsDialog> createState() =>
      _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState
    extends State<NotificationSettingsDialog> {
  bool _isEnabled = true;
  int _selectedHour = 8; // 기본 오전 8시
  bool _isLoading = true;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await NotificationService.instance.isNotificationEnabled();
    final time = await NotificationService.instance.getNotificationTime();
    setState(() {
      _isEnabled = enabled;
      if (time.hour == 7 || time.hour == 8 || time.hour == 9) {
        _selectedHour = time.hour;
      } else {
        _selectedHour = 8;
      }
      _statusMessage = _isEnabled
          ? '매일 오전 $_selectedHour시 알람 설정됨'
          : '알람이 꺼져 있습니다';
      _isLoading = false;
    });
  }

  /// 켜기/끄기 토글 시 즉시 저장
  Future<void> _toggleEnable(bool enable) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isEnabled = enable;
      _statusMessage = enable
          ? '매일 오전 $_selectedHour시 알람이 켜졌습니다'
          : '알람이 꺼졌습니다';
    });

    await NotificationService.instance.saveSettings(
      isEnabled: enable,
      time: TimeOfDay(hour: _selectedHour, minute: 0),
    );
  }

  /// 시간 선택 시 즉시 저장
  Future<void> _selectHour(int hour) async {
    HapticFeedback.selectionClick();
    setState(() {
      _isEnabled = true;
      _selectedHour = hour;
      _statusMessage = '매일 오전 $hour시 알람으로 저장되었습니다';
    });

    await NotificationService.instance.saveSettings(
      isEnabled: true,
      time: TimeOfDay(hour: hour, minute: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Dialog(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: isDark ? const Color(0xFF1B1E2B) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 상단 선셋 골드 그라데이션 헤더
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 14, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                    : [const Color(0xFFB71C1C), const Color(0xFFD35400), const Color(0xFFE67E22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFD54F), size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '아침 안부와 덕담 배달',
                        style: GoogleFonts.jua(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '매일 아침 전해드리는 따뜻한 마음과 인사',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 24),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                  tooltip: '닫기',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. 큼직하고 명확한 [알림 켜기] vs [알림 끄기] 2개 버튼
                Row(
                  children: [
                    // [ 알림 켜기 ] 버튼
                    Expanded(
                      child: InkWell(
                        onTap: () => _toggleEnable(true),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _isEnabled
                                ? const Color(0xFFD35400)
                                : (isDark ? const Color(0xFF232738) : const Color(0xFFF5F5F5)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isEnabled
                                  ? const Color(0xFFD35400)
                                  : (isDark ? Colors.white12 : Colors.grey.shade300),
                              width: _isEnabled ? 2.0 : 1.2,
                            ),
                            boxShadow: _isEnabled
                                ? [
                                    const BoxShadow(
                                      color: Color(0x40D35400),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isEnabled ? Icons.check_circle_rounded : Icons.notifications_active_rounded,
                                size: 20,
                                color: _isEnabled
                                    ? Colors.white
                                    : (isDark ? Colors.white60 : Colors.grey.shade700),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '알람 켜기',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: _isEnabled
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : Colors.grey.shade800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // [ 알람 끄기 ] 버튼
                    Expanded(
                      child: InkWell(
                        onTap: () => _toggleEnable(false),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: !_isEnabled
                                ? (isDark ? const Color(0xFF37474F) : const Color(0xFF546E7A))
                                : (isDark ? const Color(0xFF232738) : const Color(0xFFF5F5F5)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: !_isEnabled
                                  ? (isDark ? Colors.white38 : const Color(0xFF546E7A))
                                  : (isDark ? Colors.white12 : Colors.grey.shade300),
                              width: !_isEnabled ? 2.0 : 1.2,
                            ),
                            boxShadow: !_isEnabled
                                ? [
                                    const BoxShadow(
                                      color: Color(0x33000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                !_isEnabled ? Icons.check_circle_rounded : Icons.notifications_off_rounded,
                                size: 20,
                                color: !_isEnabled
                                    ? Colors.white
                                    : (isDark ? Colors.white60 : Colors.grey.shade700),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '알람 끄기',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: !_isEnabled
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : Colors.grey.shade800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // 3. 켜기를 누르면 시간 선택 영역이 나타남! (끄기를 누르면 사라짐)
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 250),
                  crossFadeState: _isEnabled
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled_rounded,
                            size: 18,
                            color: isDark ? const Color(0xFFFFD700) : const Color(0xFFD35400),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            '알람 시간 선택',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFFFD700) : const Color(0xFFBF360C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildTimeButton(7, '오전 7시', '상쾌한 아침 🌅', isDark),
                          const SizedBox(width: 8),
                          _buildTimeButton(8, '오전 8시', '활기찬 아침 ☀️', isDark),
                          const SizedBox(width: 8),
                          _buildTimeButton(9, '오전 9시', '여유로운 아침 ☕', isDark),
                        ],
                      ),
                    ],
                  ),
                  secondChild: const SizedBox(width: double.infinity, height: 6),
                ),

                const SizedBox(height: 18),

                // 4. 선택과 동시에 저장되었다는 직관적인 실시간 안내 문구 박스
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _isEnabled
                        ? (isDark ? const Color(0xFF2C2220) : const Color(0xFFFFF3E0))
                        : (isDark ? const Color(0xFF242730) : const Color(0xFFECEFF1)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isEnabled
                          ? (isDark ? const Color(0xFFD35400) : const Color(0xFFFFCC80))
                          : (isDark ? Colors.white12 : const Color(0xFFCFD8DC)),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEnabled ? Icons.check_circle_rounded : Icons.notifications_off_rounded,
                        size: 19,
                        color: _isEnabled
                            ? const Color(0xFFD35400)
                            : (isDark ? Colors.white70 : const Color(0xFF546E7A)),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 14.5,
                            letterSpacing: -0.3,
                            fontWeight: FontWeight.bold,
                            color: _isEnabled
                                ? (isDark ? const Color(0xFFFFCC80) : const Color(0xFFBF360C))
                                : (isDark ? Colors.white70 : const Color(0xFF37474F)),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 5. 완료 / 닫기 버튼
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isEnabled ? const Color(0xFFD35400) : Colors.grey.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: Text(
                    '확인 및 닫기',
                    style: GoogleFonts.jua(fontSize: 18, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 7시, 8시, 9시 시간 버튼 위젯 (누르면 즉시 저장 & 안내문구 갱신)
  Widget _buildTimeButton(int hour, String title, String subTitle, bool isDark) {
    final isSelected = _selectedHour == hour;
    return Expanded(
      child: InkWell(
        onTap: () => _selectHour(hour),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD35400)
                : (isDark ? const Color(0xFF282D42) : const Color(0xFFFFF1E6)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFD35400)
                  : (isDark ? Colors.white12 : const Color(0xFFFFCCBC)),
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color(0x3DD35400),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : const Color(0xFF3E2723)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subTitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Colors.white.withAlpha(220)
                        : (isDark ? Colors.white60 : const Color(0xFF8D6E63)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

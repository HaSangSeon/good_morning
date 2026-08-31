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
      _isLoading = false;
    });
  }

  Future<void> _saveAndClose() async {
    HapticFeedback.mediumImpact();
    await NotificationService.instance.saveSettings(
      isEnabled: _isEnabled,
      time: TimeOfDay(hour: _selectedHour, minute: 0),
    );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEnabled
                ? '매일 오전 $_selectedHour시에 따뜻한 아침 안부가 배달됩니다 ☀️'
                : '아침 안부 알림이 해제되었습니다.',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          backgroundColor: _isEnabled ? const Color(0xFFD35400) : Colors.black87,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
          // 1. 상단 선셋 그라데이션 헤더
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1B1B2F), const Color(0xFF2C1938), const Color(0xFF381A40)]
                    : [const Color(0xFFC0392B), const Color(0xFFD35400), const Color(0xFFE67E22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: Color(0xFFFFD700), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '아침 안부 알림 설정',
                    style: GoogleFonts.jua(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. 매일 아침 안부 받기 (스위치 카드)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252A3D) : const Color(0xFFFFF6EE),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFFFFCCBC),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isEnabled ? Icons.wb_sunny_rounded : Icons.notifications_off_rounded,
                        color: _isEnabled ? const Color(0xFFD35400) : Colors.grey,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '매일 아침 안부 받기',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF2C1810),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _isEnabled,
                        activeThumbColor: const Color(0xFFD35400),
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isEnabled = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                if (_isEnabled) ...[
                  const SizedBox(height: 22),

                  // 3. 알림 받을 시간 선택 (단순하고 큼직한 3개 버튼)
                  Text(
                    '⏰ 알림 받을 시간',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFFFD700) : const Color(0xFFBF360C),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _buildSimpleTimeButton(7, '오전 7시', isDark),
                      const SizedBox(width: 10),
                      _buildSimpleTimeButton(8, '오전 8시', isDark),
                      const SizedBox(width: 10),
                      _buildSimpleTimeButton(9, '오전 9시', isDark),
                    ],
                  ),
                ],

                const SizedBox(height: 26),

                // 4. 설정 완료 버튼 (큼직하고 럭셔리한 디자인)
                ElevatedButton(
                  onPressed: _saveAndClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD35400),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                    shadowColor: const Color(0x66D35400),
                  ),
                  child: Text(
                    '설정 완료',
                    style: GoogleFonts.jua(fontSize: 19.5, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTimeButton(int hour, String label, bool isDark) {
    final isSelected = _selectedHour == hour;
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedHour = hour;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
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
              width: isSelected ? 2.0 : 1.0,
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : const Color(0xFF5D4037)),
            ),
          ),
        ),
      ),
    );
  }
}

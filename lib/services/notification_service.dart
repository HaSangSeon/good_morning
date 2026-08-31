import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 푸시 알림으로 전달되는 오늘의 추천 아침 안부 & 덕담 데이터셋
class NotificationQuoteData {
  static const List<Map<String, String>> morningQuotes = [
    {
      'title': '🌅 좋은 아침입니다!',
      'body': '새로운 하루가 밝았습니다. 오늘도 활기차고 행복한 시간 보내세요 ☀️',
    },
    {
      'title': '🌸 감사와 기쁨이 넘치는 오늘',
      'body': '오늘 하루도 당신의 마음에 감사와 행복이 가득하기를 소망합니다 🌿',
    },
    {
      'title': '☕ 상쾌한 아침, 미소꽃 피는 날',
      'body': '따뜻한 차 한 잔과 함께 온화하고 기분 좋은 하루 보내세요 😊',
    },
    {
      'title': '🍀 당신을 위한 따뜻한 축복',
      'body': '복되고 좋은 아침, 언제나 당신을 마음 깊이 응원합니다! 🙏',
    },
    {
      'title': '🌿 건강과 평안을 기원합니다',
      'body': '첫째도 건강, 둘째도 건강! 몸과 마음 모두 무탈하고 평안하세요 💪',
    },
    {
      'title': '✨ 당신이 있어 세상이 따뜻합니다',
      'body': '소중한 당신, 오늘도 스스로를 가장 귀하게 아껴주는 날 되세요 💖',
    },
    {
      'title': '🌷 향기로운 꽃길만 가득하길',
      'body': '오늘도 당신이 걷는 발걸음마다 좋은 일과 행운만 가득하길 바랍니다 🍃',
    },
    {
      'title': '🕊️ 마음의 평화가 깃드는 아침',
      'body': '어려운 일도 슬기롭게 잘 지나갈 것입니다. 힘내세요, 파이팅! 🔥',
    },
    {
      'title': '🍚 소중한 분들과 행복한 하루',
      'body': '맛있는 식사 든든히 챙겨 드시고, 활기찬 미소 잃지 마세요 🍵',
    },
    {
      'title': '🎁 오늘이라는 가장 큰 선물',
      'body': '매일 만나는 소중한 하루하루가 삶의 가장 큰 기적입니다. 행복하세요 ✨',
    },
    {
      'title': '🌞 찬란한 햇살처럼 빛나는 하루',
      'body': '당신의 맑은 미소가 온 세상을 환하게 밝힙니다. 기분 좋은 하루 되세요 🌼',
    },
    {
      'title': '⭐ 당신의 오늘을 응원합니다',
      'body': '꿈꾸고 바라는 모든 일들이 술술 풀리는 축복의 날 되세요 👍',
    },
    {
      'title': '🎨 오늘이라는 하얀 도화지',
      'body': '근심과 걱정은 지우고, 기쁨과 미소로 가장 아름다운 하루를 그려보세요 🎨',
    },
    {
      'title': '🍃 맑은 아침 공기처럼',
      'body': '오늘 당신의 마음에도 맑고 향기로운 바람이 불어오길 바랍니다 🍃',
    },
    {
      'title': '🍇 곱게 익어가는 세월',
      'body': '우리는 늙어가는 것이 아니라 조금씩 곱게 익어가는 것입니다 🍇',
    },
    {
      'title': '💬 다정한 말 한마디의 힘',
      'body': '따뜻한 말 한마디는 지친 이의 하루를 살리는 보약이 됩니다 💌',
    },
    {
      'title': '💧 물처럼 흐르는 지혜로운 삶',
      'body': '낮은 곳으로 흐르며 만물을 이롭게 하는 겸손하고 평온한 하루 되세요 💧',
    },
    {
      'title': '💎 진정한 마음의 부자',
      'body': '가진 것에 만족하고 남에게 베풀 줄 아는 당신이 가장 큰 부자입니다 💎',
    },
    {
      'title': '⛅ 구름 뒤의 푸른 하늘',
      'body': '먹구름 뒤에는 언제나 눈부신 태양이 기다립니다. 힘내세요! 🌤️',
    },
    {
      'title': '👑 당신은 언제나 최고입니다',
      'body': '묵묵히 사랑과 정성으로 살아오신 당신은 세상에서 가장 존경스럽습니다 👑',
    },
    {
      'title': '🌳 참 좋은 당신을 만났습니다',
      'body': '내 인생의 든든한 나무가 되어준 참 좋은 당신이 있어 행복합니다 🌳',
    },
    {
      'title': '🤝 오랜 벗의 따스한 눈빛',
      'body': '말하지 않아도 마음을 알아주는 소중한 벗이 있어 참 감사한 날입니다 🤝',
    },
    {
      'title': '💐 베푸는 기쁨, 피어나는 행복',
      'body': '꽃을 건네는 손에 꽃향기가 남듯 사랑을 나눌 때 마음에 꽃이 핍니다 💐',
    },
    {
      'title': '🕊️ 내려놓으면 비로소 자유롭다',
      'body': '욕심을 비워낼 때 마음은 새처럼 가볍고 평화로워집니다 🕊️',
    },
    {
      'title': '🪞 맑은 마음의 거울',
      'body': '내 마음이 고요하면 비치는 온 세상도 아름답고 평화로워집니다 🪞',
    },
    {
      'title': '🌿 지금 이 순간을 사랑하세요',
      'body': '과거의 후회와 미래의 불안을 내려놓고 지금 이 순간을 기쁘게 누리세요 🌿',
    },
    {
      'title': '💖 가슴으로 느끼는 참된 행복',
      'body': '세상에서 가장 아름다운 것은 볼 수 없지만 오직 가슴으로 느낄 수 있습니다 💖',
    },
    {
      'title': '🏆 나를 이기는 위대한 하루',
      'body': '자신을 다스리는 사람이 진정으로 강한 자입니다. 멋진 하루 보내세요 🏆',
    },
    {
      'title': '🚪 새로운 희망의 문',
      'body': '하나의 문이 닫히면 언제나 더 크고 밝은 새로운 문이 열립니다 🚪',
    },
    {
      'title': '🌾 풍요로운 감사의 마음',
      'body': '작은 일에도 감사하는 마음에 기적과 행복이 깃듭니다 🌾',
    },
    {
      'title': '🌕 평안하고 넉넉한 하루',
      'body': '보름달처럼 둥글고 넉넉한 마음으로 기쁨 가득한 하루 보내세요 🌕',
    },
  ];

  /// 오늘 날짜 기준 로테이션 문구 반환
  static Map<String, String> getTodayQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % morningQuotes.length;
    return morningQuotes[index];
  }

  /// 특정 날짜 기준 문구 반환
  static Map<String, String> getQuoteForDate(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final index = dayOfYear % morningQuotes.length;
    return morningQuotes[index];
  }
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefEnabledKey = 'morning_notification_enabled';
  static const String _prefHourKey = 'morning_notification_hour';
  static const String _prefMinuteKey = 'morning_notification_minute';

  static const int _notificationId = 1001;
  static const String _channelId = 'morning_greeting_channel';
  static const String _channelName = '아침 안부 & 덕담 알림';
  static const String _channelDescription = '매일 아침 따뜻한 안부 문구와 카드를 전달합니다.';

  bool _isInitialized = false;

  /// 푸시 클릭 시 메인 화면에 텍스트를 자동 세팅하기 위한 콜백 핸들러
  Function(String quoteText)? onNotificationClick;

  /// 서비스 초기화
  Future<void> initialize({Function(String quoteText)? onSelectNotification}) async {
    if (_isInitialized) return;
    onNotificationClick = onSelectNotification;

    // 1. 타임존 초기화
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Could not get local timezone, fallback to Asia/Seoul: $e');
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
      } catch (_) {}
    }

    // 2. Android 초기화 설정
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS 초기화 설정
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          onNotificationClick?.call(response.payload!);
        }
      },
    );

    _isInitialized = true;

    // 저장된 설정 불러와서 알림 재등록
    final isEnabled = await isNotificationEnabled();
    if (isEnabled) {
      final time = await getNotificationTime();
      await scheduleDailyMorningNotification(time.hour, time.minute);
    }
  }

  /// 권한 요청 (Android 13+ 및 iOS)
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  /// 매일 아침 안부 알림 스케줄링
  Future<void> scheduleDailyMorningNotification(int hour, int minute) async {
    // 기존 스케줄 취소
    await cancelMorningNotification();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 설정한 시간이 오늘 이미 지났다면 내일부터 울리도록 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final todayQuote = NotificationQuoteData.getQuoteForDate(scheduledDate);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: _notificationId,
      title: todayQuote['title'],
      body: todayQuote['body'],
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 해당 시간에 반복
      payload: todayQuote['body'],
    );

    debugPrint('Morning notification scheduled for $scheduledDate ($hour:$minute)');
  }

  /// 알림 즉시 취소
  Future<void> cancelMorningNotification() async {
    await _notificationsPlugin.cancel(id: _notificationId);
  }

  /// 즉시 테스트 알림 발송 (사용자가 바로 확인해 볼 수 있는 기능)
  Future<void> showTestNotification() async {
    final quote = NotificationQuoteData.getTodayQuote();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id: 9999, // Test Notification ID
      title: quote['title'],
      body: quote['body'],
      notificationDetails: notificationDetails,
      payload: quote['body'],
    );
  }

  /// 알림 활성화 여부 확인
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // 기본값은 활성화(true)
    return prefs.getBool(_prefEnabledKey) ?? true;
  }

  /// 알림 시간(TimeOfDay) 불러오기
  Future<TimeOfDay> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_prefHourKey) ?? 8; // 기본 오전 8시
    final minute = prefs.getInt(_prefMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// 알림 설정 저장 및 스케줄 갱신
  Future<void> saveSettings({required bool isEnabled, required TimeOfDay time}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefEnabledKey, isEnabled);
    await prefs.setInt(_prefHourKey, time.hour);
    await prefs.setInt(_prefMinuteKey, time.minute);

    if (isEnabled) {
      await requestPermissions();
      await scheduleDailyMorningNotification(time.hour, time.minute);
    } else {
      await cancelMorningNotification();
    }
  }
}

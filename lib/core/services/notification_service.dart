import 'dart:convert';
import 'dart:typed_data';

import 'package:doctor_appointment/core/config/app_config.dart';
import 'package:doctor_appointment/core/config/env.dart';
import 'package:doctor_appointment/core/logging/log_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/get_my_appointments_usecase.dart';
import 'package:doctor_appointment/features/home/data/datasource/notification_remote_data_source.dart';
import 'package:doctor_appointment/features/home/domain/entities/app_notification_type.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String _replyActionId = 'reply_action';
const String _seenActionId = 'seen_action';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.ensureBackgroundDependencies();
  await NotificationService().handleNotificationResponse(response);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  bool _initialized = false;
  bool _localNotificationsInitialized = false;

  /// Convenience accessor — safe even if LogService isn't registered yet
  /// (e.g. background isolate during early init).
  LogService get _log => getIt.isRegistered<LogService>()
      ? getIt<LogService>()
      : _NoOpLogService();

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    await _ensureLocalNotificationsInitialized();

    FirebaseMessaging.onMessage.listen((message) async {
      await showRemoteMessageNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateBasedOnData(message.data);
    });

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _navigateBasedOnData(initialMessage.data);
    }

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  static Future<void> ensureBackgroundDependencies() async {
    await loadEnv();
    await SharedPreferencesHelper.init();
    if (!getIt.isRegistered<NotificationRemoteDataSource>()) {
      setupServiceLocator();
    }
    tz.initializeTimeZones();
    await NotificationService()._ensureLocalNotificationsInitialized();
  }

  static Future<void> handleBackgroundRemoteMessage(
    RemoteMessage message,
  ) async {
    WidgetsFlutterBinding.ensureInitialized();
    await ensureBackgroundDependencies();
    await NotificationService().showRemoteMessageNotification(
      message,
      fromBackground: true,
    );
  }

  Future<String?> getFcmToken() async => _fcm.getToken();

  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  Future<void> showRemoteMessageNotification(
    RemoteMessage message, {
    bool fromBackground = false,
  }) async {
    print(
      '[FCM] showRemoteMessageNotification: message received! fromBackground=$fromBackground',
    );
    print('[FCM] Message Data: ${message.data}');
    print(
      '[FCM] Message Notification: Title="${message.notification?.title}", Body="${message.notification?.body}"',
    );

    if (fromBackground && message.notification != null) {
      print(
        '[FCM] Ignoring background notification because it contains a Notification block.',
      );
      return;
    }

    final title = _extractNotificationTitle(message);
    final body = _extractNotificationBody(message);
    print('[FCM] Extracted Title: "$title", Body: "$body"');
    if (title == null && body == null) {
      print('[FCM] Title and Body are both null. Aborting.');
      return;
    }

    final payloadMap = Map<String, dynamic>.from(message.data);
    final notificationId = message.messageId?.hashCode ?? message.hashCode;
    
    payloadMap['notificationId'] = notificationId;
    payloadMap['title'] ??= title;
    payloadMap['message'] ??= body;
    payloadMap['relatedEntityId'] =
        payloadMap['relatedEntityId']?.toString() ??
        payloadMap['appointmentId']?.toString() ??
        payloadMap['chatUserId']?.toString();

    final notificationType = _parseNotificationType(payloadMap['type']);
    print('[FCM] Parsed notification type: $notificationType');

    await showNotification(
      id: notificationId,
      title: title ?? 'New Notification',
      body: body ?? '',
      payload: jsonEncode(payloadMap),
      type: notificationType,
      avatarUrl:
          (payloadMap['senderProfilePicture'] ??
                  payloadMap['userProfilePicture'])
              ?.toString(),
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    AppNotificationType? type,
    String? avatarUrl,
  }) async {
    print(
      '[FCM] showNotification: id=$id, title="$title", type=$type, avatarUrl="$avatarUrl"',
    );
    final notificationType = type ?? AppNotificationType.unknown;
    final largeIcon = notificationType.isChat
        ? await _loadAvatarBitmap(avatarUrl)
        : null;
    print('[FCM] Loaded largeIcon: $largeIcon');

    Color getNotificationColor(AppNotificationType type) {
      switch (type) {
        case AppNotificationType.appointmentApproved:
        case AppNotificationType.doctorApproved:
          return const Color(0xFF4CAF50); // Success Green
        case AppNotificationType.appointmentCancelled:
        case AppNotificationType.paymentFailed:
          return const Color(0xFFF44336); // Error Red
        case AppNotificationType.appointmentReminder:
          return const Color(0xFFFF9800); // Warning Orange
        default:
          return const Color(0xff226CEB); // Primary Blue
      }
    }

    final androidDetails = AndroidNotificationDetails(
      'doctor_appointment_channel',
      'Doctor Appointment Notifications',
      channelDescription:
          'Notifications for appointments, status changes, and new messages.',
      importance: Importance.max,
      priority: Priority.high,
      category: notificationType.isChat
          ? AndroidNotificationCategory.message
          : AndroidNotificationCategory.event,
      showWhen: true,
      color: getNotificationColor(notificationType),
      largeIcon: largeIcon,
      actions: notificationType.isChat
          ? <AndroidNotificationAction>[
              AndroidNotificationAction(
                _replyActionId,
                'Reply',
                allowGeneratedReplies: true,
                cancelNotification: false,
                contextual: false,
                semanticAction: SemanticAction.reply,
                inputs: const <AndroidNotificationActionInput>[
                  AndroidNotificationActionInput(label: 'Type a reply'),
                ],
              ),
              const AndroidNotificationAction(
                _seenActionId,
                'Seen',
                semanticAction: SemanticAction.markAsRead,
              ),
            ]
          : null,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        categoryIdentifier: notificationType.isChat ? 'chat_category' : null,
      ),
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
      print('[FCM] Successfully showed local notification in tray!');
    } catch (e, stack) {
      print('[FCM] Error showing local notification: $e');
      print(stack);
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'doctor_appointment_channel',
          'Doctor Appointment Notifications',
          channelDescription:
              'Notifications for appointments, status changes, and new messages.',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.event,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> handleNotificationResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) {
      _log.w(
        '[Notification] handleNotificationResponse: payload is null, ignoring.',
      );
      return;
    }

    _log.d(
      '[Notification] handleNotificationResponse: '
      'actionId="${response.actionId}", notificationId=${response.id}',
    );

    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      _log.d('[Notification] Decoded payload: $data');

      switch (response.actionId) {
        case _replyActionId:
          final replyText = response.input?.trim();
          _log.i('[Notification] Reply action triggered. Text: "$replyText"');
          
          try {
            if (replyText != null && replyText.isNotEmpty) {
              await _sendQuickReply(data, replyText);
            } else {
              _log.w('[Notification] Reply action had empty input — skipping send.');
            }
            await _markAsSeenFromPayload(data);
          } catch (e) {
            _log.e('[Notification] Failed to process quick reply or mark as seen: $e');
          } finally {
            final notifId = response.id ?? _parseInt(data['notificationId'] ?? data['id']);
            if (notifId != null) {
              await _flutterLocalNotificationsPlugin.cancel(id: notifId);
              _log.d('[Notification] Dismissed tray notification id=$notifId.');
            }
          }
          break;

        case _seenActionId:
          _log.i('[Notification] Seen action triggered.');
          try {
            await _markAsSeenFromPayload(data);
          } catch (e) {
            _log.e('[Notification] Failed to mark as seen: $e');
          } finally {
            final seenNotifId = response.id ?? _parseInt(data['notificationId'] ?? data['id']);
            if (seenNotifId != null) {
              await _flutterLocalNotificationsPlugin.cancel(id: seenNotifId);
              _log.d('[Notification] Dismissed tray notification id=$seenNotifId.');
            }
          }
          break;

        default:
          _log.i('[Notification] Tap action — navigating based on data.');
          _navigateBasedOnData(data);
          break;
      }
    } catch (error, stackTrace) {
      _log.e(
        '[Notification] Error in handleNotificationResponse',
        error,
        stackTrace,
      );
    }
  }

  void _navigateBasedOnData(Map<String, dynamic> data) {
    final type = _parseNotificationType(data['type']);
    _log.d(
      '[Notification] _navigateBasedOnData: type=$type, data keys=${data.keys.toList()}',
    );

    if (type.isChat || _isChatPayload(data)) {
      _log.i('[Notification] Routing to chat screen.');
      _openChatFromNotification(data);
    } else if (type.isAppointmentFlow ||
        data['appointmentId'] != null ||
        data['relatedEntityId'] != null) {
      final idStr = data['appointmentId'] ?? data['relatedEntityId'];
      final appointmentId = idStr != null
          ? int.tryParse(idStr.toString())
          : null;
      _log.i(
        '[Notification] Routing to appointment. relatedEntityId="$idStr", parsed=$appointmentId',
      );
      if (appointmentId != null) {
        _handleAppointmentTapAsync(appointmentId);
      } else {
        _log.w(
          '[Notification] Could not parse appointmentId — falling back to CalendarView.',
        );
        AppRouter.router.push(AppRouter.kCalendarView);
      }
    } else {
      _log.i(
        '[Notification] No specific route match — opening NotificationView.',
      );
      AppRouter.router.push(AppRouter.kNotificationView);
    }
  }

  void _openChatFromNotification(Map<String, dynamic> data) async {
    final resolvedUserId = _chatUserIdFromData(data);
    final userName = (data['userName'] ?? data['senderName'] ?? 'Chat')
        .toString()
        .trim();
    final userProfilePicture =
        (data['userProfilePicture'] ?? data['senderProfilePicture'])
            ?.toString();

    _log.d(
      '[Notification] _openChatFromNotification: '
      'resolvedUserId=$resolvedUserId, userName="$userName", '
      'senderId=${data["senderId"]}, relatedEntityId=${data["relatedEntityId"]}',
    );

    if (resolvedUserId == null) {
      _log.w(
        '[Notification] Could not resolve chat userId — falling back to ConversationsView.',
      );
      AppRouter.router.push(AppRouter.kConversationsView);
      return;
    }

    _log.i(
      '[Notification] Opening ChatScreen for userId=$resolvedUserId ("$userName").',
    );
    AppRouter.router.push(
      AppRouter.kChatView.replaceFirst(':userId', '$resolvedUserId'),
      extra: {
        'otherUserName': userName.isNotEmpty ? userName : 'Chat',
        'otherUserProfilePicture': userProfilePicture,
      },
    );
  }

  Future<void> _sendQuickReply(
    Map<String, dynamic> data,
    String replyText,
  ) async {
    final resolvedUserId = _chatUserIdFromData(data);
    _log.d(
      '[Notification] _sendQuickReply: resolvedUserId=$resolvedUserId, '
      'replyLength=${replyText.length}',
    );

    if (resolvedUserId == null) {
      _log.e(
        '[Notification] _sendQuickReply: could not resolve userId from payload: $data',
      );
      throw Exception('Could not resolve conversation for quick reply');
    }

    try {
      await _executeBackgroundApiCall(
        endpoint: '/api/Chat/send',
        method: 'POST',
        data: {'receiverId': resolvedUserId, 'message': replyText},
      );
      _log.i('[Notification] Quick reply sent to userId=$resolvedUserId.');
    } catch (error, stackTrace) {
      _log.e(
        '[Notification] Failed to send quick reply to userId=$resolvedUserId',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _markAsSeenFromPayload(Map<String, dynamic> data) async {
    final notificationId = _parseInt(data['notificationId'] ?? data['id']);
    _log.d(
      '[Notification] _markAsSeenFromPayload: notificationId=$notificationId',
    );

    if (notificationId != null) {
      try {
        await _executeBackgroundApiCall(
          endpoint: '/api/Notification/$notificationId/read',
          method: 'PUT',
        );
        _log.i(
          '[Notification] Marked notification $notificationId as read in backend.',
        );
      } catch (error) {
        _log.w(
          '[Notification] Failed to mark notification $notificationId as read: $error',
        );
      }
    } else {
      _log.d(
        '[Notification] No notificationId in payload — skipping in-app mark-as-read.',
      );
    }

    final resolvedUserId = _chatUserIdFromData(data);
    _log.d(
      '[Notification] _markAsSeenFromPayload: chat resolvedUserId=$resolvedUserId',
    );

    if (resolvedUserId != null) {
      try {
        await _executeBackgroundApiCall(
          endpoint: '/api/Chat/read/$resolvedUserId',
          method: 'PUT',
        );
        _log.i(
          '[Notification] Marked chat messages as read for userId=$resolvedUserId.',
        );
      } catch (error, stackTrace) {
        _log.w(
          '[Notification] Failed to mark chat as read for userId=$resolvedUserId: $error',
        );
      }
    }
  }

  Future<void> _executeBackgroundApiCall({
    required String endpoint,
    required String method,
    Map<String, dynamic>? data,
  }) async {
    final token = SharedPreferencesHelper.getToken();
    if (token == null || token.isEmpty) {
      _log.w(
        '[Notification] _executeBackgroundApiCall: No token available, aborting.',
      );
      return;
    }

    final baseUrl = getIt.isRegistered<AppConfig>()
        ? getIt<AppConfig>().apiUrl
        : Env.apiUrl;

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    try {
      if (method == 'POST') {
        await dio.post(endpoint, data: data);
      } else if (method == 'PUT') {
        await dio.put(endpoint, data: data);
      }
    } finally {
      dio.close();
    }
  }

  void _handleAppointmentTapAsync(int appointmentId) async {
    _log.i(
      '[Notification] _handleAppointmentTapAsync: fetching appointmentId=$appointmentId',
    );
    try {
      final useCase = getIt<GetMyAppointmentsUseCase>();
      final result = await useCase();
      if (result is Success<List<Appointment>>) {
        final appointment = result.data.firstWhere(
          (app) => app.id == appointmentId,
          orElse: () =>
              throw Exception('Appointment $appointmentId not found in list'),
        );
        _log.i(
          '[Notification] Appointment found — opening AppointmentDetailsView.',
        );
        AppRouter.router.push(
          AppRouter.kAppointmentDetailsView,
          extra: appointment,
        );
      } else {
        _log.w(
          '[Notification] GetMyAppointmentsUseCase returned failure — falling back to CalendarView.',
        );
        AppRouter.router.push(AppRouter.kCalendarView);
      }
    } catch (error, stackTrace) {
      _log.e(
        '[Notification] _handleAppointmentTapAsync failed for id=$appointmentId',
        error,
        stackTrace,
      );
      AppRouter.router.push(AppRouter.kCalendarView);
    }
  }

  AppNotificationType _parseNotificationType(dynamic rawType) {
    if (rawType == null) return AppNotificationType.unknown;

    final strVal = rawType.toString().trim();
    final parsedInt = int.tryParse(strVal);
    if (parsedInt != null) {
      return AppNotificationType.fromValue(parsedInt);
    }

    final normalized = strVal.toLowerCase();
    if (normalized == 'chat' ||
        normalized == 'chatmessage' ||
        normalized == '4') {
      return AppNotificationType.chatMessage;
    }
    if (normalized == 'appointment') {
      return AppNotificationType.appointmentBooked;
    }

    for (final type in AppNotificationType.values) {
      if (type.name.toLowerCase() == normalized) {
        return type;
      }
    }

    return AppNotificationType.unknown;
  }

  String? _extractNotificationTitle(RemoteMessage message) {
    final data = message.data;
    final type = _parseNotificationType(data['type']);
    final senderName = (data['senderName'] ?? data['userName'])
        ?.toString()
        .trim();

    if (type.isChat && senderName != null && senderName.isNotEmpty) {
      return senderName;
    }

    return data['title']?.toString() ??
        data['notificationTitle']?.toString() ??
        message.notification?.title;
  }

  String? _extractNotificationBody(RemoteMessage message) {
    final data = message.data;
    final candidates = [
      data['message'],
      data['body'],
      data['content'],
      data['text'],
      data['notificationBody'],
      message.notification?.body,
    ];

    for (final candidate in candidates) {
      final text = candidate?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  String? _extractDataBody(Map<String, dynamic> data) {
    final candidates = [
      data['message'],
      data['body'],
      data['content'],
      data['text'],
      data['notificationBody'],
    ];

    for (final candidate in candidates) {
      final text = candidate?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }

  bool _isGenericChatText(String text) {
    final normalized = text.trim().toLowerCase();
    return normalized.isEmpty ||
        normalized == 'you received a new message' ||
        normalized == 'new message arrived' ||
        normalized == 'new message arrive' ||
        normalized == 'tap to continue the conversation';
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value > 0 ? value : null;
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  int? _chatUserIdFromData(Map<String, dynamic> data) {
    return _parseInt(data['senderId']) ??
        _parseInt(data['chatUserId']) ??
        _parseInt(data['userId']);
  }

  bool _isChatPayload(Map<String, dynamic> data) =>
      // Use type as the primary signal; senderId presence is a secondary indicator.
      // Avoid matching on relatedEntityId alone — appointments also carry it.
      data['type']?.toString().toLowerCase().contains('chat') == true ||
      (data['senderId'] != null && data['senderId'].toString().isNotEmpty);

  Future<void> _ensureLocalNotificationsInitialized() async {
    if (_localNotificationsInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    final darwinCategories = [
      DarwinNotificationCategory(
        'chat_category',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.text(
            _replyActionId,
            'Reply',
            buttonTitle: 'Send',
            placeholder: 'Type a reply',
          ),
          DarwinNotificationAction.plain(
            _seenActionId,
            'Seen',
            options: <DarwinNotificationActionOption>{
              DarwinNotificationActionOption.foreground,
            },
          ),
        ],
      ),
    ];

    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: darwinCategories,
    );

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) async {
        await handleNotificationResponse(response);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    _localNotificationsInitialized = true;
  }

  Future<AndroidBitmap<Object>?> _loadAvatarBitmap(String? avatarUrl) async {
    if (avatarUrl == null || avatarUrl.trim().isEmpty) {
      return null;
    }

    try {
      final fullUrl = ImageUrlHelper.getFullUrl(avatarUrl);
      if (fullUrl.isEmpty) return null;

      final response = await Dio().get<List<int>>(
        fullUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: ImageUrlHelper.getImageHeaders(),
        ),
      );

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        return null;
      }

      return ByteArrayAndroidBitmap(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    }
  }
}

/// No-op fallback so [NotificationService._log] never throws when
/// [LogService] is not yet registered (e.g. inside a background isolate).
class _NoOpLogService extends LogService {
  @override
  void d(String message) {}
  @override
  void i(String message) {}
  @override
  void w(String message) {}
  @override
  void e(String message, [dynamic error, StackTrace? stackTrace]) {}
}

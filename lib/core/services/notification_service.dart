import 'dart:convert';
import 'dart:typed_data';

import 'package:doctor_appointment/core/config/env.dart';
import 'package:doctor_appointment/core/logging/log_service.dart';
import 'package:doctor_appointment/core/services/service_locator.dart';
import 'package:doctor_appointment/core/services/shared_preferences_helper.dart';
import 'package:doctor_appointment/core/utils/go_router.dart';
import 'package:doctor_appointment/core/utils/image_url_helper.dart';
import 'package:doctor_appointment/core/utils/result.dart';
import 'package:doctor_appointment/features/appointment/domain/entities/appointment.dart';
import 'package:doctor_appointment/features/appointment/domain/usecases/get_my_appointments_usecase.dart';
import 'package:doctor_appointment/features/chat/data/datasources/chat_remote_data_source.dart';
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
    print('[FCM] showRemoteMessageNotification: message received! fromBackground=$fromBackground');
    print('[FCM] Message Data: ${message.data}');
    print('[FCM] Message Notification: Title="${message.notification?.title}", Body="${message.notification?.body}"');

    if (fromBackground && message.notification != null) {
      print('[FCM] Ignoring background notification because it contains a Notification block.');
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
    payloadMap['title'] ??= title;
    payloadMap['message'] ??= body;
    payloadMap['relatedEntityId'] =
        payloadMap['relatedEntityId']?.toString() ??
        payloadMap['chatUserId']?.toString();

    final notificationType = _parseNotificationType(payloadMap['type']);
    print('[FCM] Parsed notification type: $notificationType');

    await showNotification(
      id: message.messageId?.hashCode ?? message.hashCode,
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
    print('[FCM] showNotification: id=$id, title="$title", type=$type, avatarUrl="$avatarUrl"');
    final notificationType = type ?? AppNotificationType.unknown;
    final largeIcon = notificationType.isChat
        ? await _loadAvatarBitmap(avatarUrl)
        : null;
    print('[FCM] Loaded largeIcon: $largeIcon');

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
    if (payload == null) return;

    try {
      final data = Map<String, dynamic>.from(jsonDecode(payload) as Map);

      switch (response.actionId) {
        case _replyActionId:
          final replyText = response.input?.trim();
          if (replyText != null && replyText.isNotEmpty) {
            await _sendQuickReply(data, replyText);
          }
          await _markAsSeenFromPayload(data);
          if (response.id != null) {
            await _flutterLocalNotificationsPlugin.cancel(id: response.id!);
          }
          break;
        case _seenActionId:
          await _markAsSeenFromPayload(data);
          if (response.id != null) {
            await _flutterLocalNotificationsPlugin.cancel(id: response.id!);
          }
          break;
        default:
          _navigateBasedOnData(data);
          break;
      }
    } catch (error, stackTrace) {
      if (getIt.isRegistered<LogService>()) {
        getIt<LogService>().e(
          'Error handling notification response',
          error,
          stackTrace,
        );
      }
    }
  }

  void _navigateBasedOnData(Map<String, dynamic> data) {
    final type = _parseNotificationType(data['type']);
    if (type.isChat || _isChatPayload(data)) {
      _openChatFromNotification(data);
    } else if (type.isAppointmentFlow ||
        data['appointmentId'] != null ||
        data['relatedEntityId'] != null) {
      final idStr = data['appointmentId'] ?? data['relatedEntityId'];
      final appointmentId = idStr != null
          ? int.tryParse(idStr.toString())
          : null;
      if (appointmentId != null) {
        _handleAppointmentTapAsync(appointmentId);
      } else {
        AppRouter.router.push(AppRouter.kCalendarView);
      }
    } else {
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

    if (resolvedUserId == null) {
      AppRouter.router.push(AppRouter.kConversationsView);
      return;
    }

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
    final chatRemoteDataSource = getIt<ChatRemoteDataSource>();
    final resolvedUserId = _chatUserIdFromData(data);

    if (resolvedUserId == null) {
      throw Exception('Could not resolve conversation for quick reply');
    }

    await chatRemoteDataSource.sendMessage(resolvedUserId, replyText);
  }

  Future<void> _markAsSeenFromPayload(Map<String, dynamic> data) async {
    final notificationId = _parseInt(data['notificationId'] ?? data['id']);
    if (notificationId != null) {
      try {
        await getIt<NotificationRemoteDataSource>().markAsRead(notificationId);
      } catch (_) {}
    }

    final chatRemoteDataSource = getIt<ChatRemoteDataSource>();
    final resolvedUserId = _chatUserIdFromData(data);

    if (resolvedUserId != null) {
      try {
        await chatRemoteDataSource.markAsRead(resolvedUserId);
      } catch (_) {}
    }
  }

  void _handleAppointmentTapAsync(int appointmentId) async {
    try {
      final useCase = getIt<GetMyAppointmentsUseCase>();
      final result = await useCase();
      if (result is Success<List<Appointment>>) {
        final appointment = result.data.firstWhere(
          (app) => app.id == appointmentId,
          orElse: () => throw Exception('Appointment not found'),
        );
        AppRouter.router.push(
          AppRouter.kAppointmentDetailsView,
          extra: appointment,
        );
      } else {
        AppRouter.router.push(AppRouter.kCalendarView);
      }
    } catch (_) {
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
    return _parseInt(data['relatedEntityId']) ??
        _parseInt(data['chatUserId']) ??
        _parseInt(data['senderId']) ??
        _parseInt(data['userId']);
  }

  bool _isChatPayload(Map<String, dynamic> data) =>
      data['relatedEntityId'] != null ||
      (data['type']?.toString().toLowerCase().contains('chat') ?? false);

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

      final response = await getIt<Dio>().get<List<int>>(
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

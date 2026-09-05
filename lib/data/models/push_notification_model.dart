import 'notification_model.dart';

/// Represents a remote push notification payload received via FCM (Step 23).
class PushMessagePayload {
  final String messageId;
  final String title;
  final String body;
  final NotificationType type;
  final String? relatedJobId;
  final String? targetRoute;
  final Map<String, dynamic> rawData;
  final DateTime receivedAt;

  const PushMessagePayload({
    required this.messageId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedJobId,
    this.targetRoute,
    this.rawData = const {},
    required this.receivedAt,
  });

  /// Factory constructor to parse Firebase Cloud Messaging payload data
  factory PushMessagePayload.fromFcmData(
    Map<String, dynamic> data, {
    String? notificationTitle,
    String? notificationBody,
  }) {
    final typeStr = data['type'] as String? ?? 'system';
    NotificationType notifType;
    switch (typeStr) {
      case 'new_job_match':
        notifType = NotificationType.newJobMatch;
        break;
      case 'govt_job_alert':
        notifType = NotificationType.govtJobAlert;
        break;
      case 'deadline_reminder':
        notifType = NotificationType.deadlineReminder;
        break;
      case 'recommendation':
        notifType = NotificationType.recommendation;
        break;
      case 'system':
      default:
        notifType = NotificationType.system;
        break;
    }

    return PushMessagePayload(
      messageId: data['message_id'] as String? ??
          'fcm_${DateTime.now().millisecondsSinceEpoch}',
      title: notificationTitle ?? data['title'] as String? ?? 'JobVaani Alert',
      body: notificationBody ??
          data['body'] as String? ??
          'New recruitment update received.',
      type: notifType,
      relatedJobId: data['job_id'] as String? ?? data['relatedJobId'] as String?,
      targetRoute: data['route'] as String? ?? data['targetRoute'] as String?,
      rawData: data,
      receivedAt: DateTime.now(),
    );
  }

  /// Converts this push payload into a standard in-app [NotificationModel]
  NotificationModel toNotificationModel() {
    return NotificationModel(
      id: messageId,
      title: title,
      message: body,
      type: type,
      timestamp: receivedAt,
      isRead: false,
      relatedJobId: relatedJobId,
      targetRoute: targetRoute ?? _defaultRouteForType(type),
    );
  }

  static String _defaultRouteForType(NotificationType type) {
    switch (type) {
      case NotificationType.govtJobAlert:
        return 'govt_job_details';
      case NotificationType.newJobMatch:
      case NotificationType.deadlineReminder:
      case NotificationType.recommendation:
        return 'job_details';
      case NotificationType.system:
      default:
        return 'notifications';
    }
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'title': title,
        'body': body,
        'type': type.name,
        'relatedJobId': relatedJobId,
        'targetRoute': targetRoute,
        'rawData': rawData,
        'receivedAt': receivedAt.toIso8601String(),
      };
}

/// Model for registering device push tokens securely with the backend API (Step 23).
class DeviceTokenRegistration {
  final String token;
  final String userId;
  final String platform; // 'android', 'ios', 'web'
  final String appVersion;
  final String locale;
  final List<String> subscribedTopics;
  final DateTime registeredAt;

  const DeviceTokenRegistration({
    required this.token,
    required this.userId,
    required this.platform,
    this.appVersion = '1.0.0',
    required this.locale,
    this.subscribedTopics = const [],
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
        'device_token': token,
        'user_id': userId,
        'platform': platform,
        'app_version': appVersion,
        'locale': locale,
        'subscribed_topics': subscribedTopics,
        'registered_at': registeredAt.toIso8601String(),
      };

  factory DeviceTokenRegistration.fromJson(Map<String, dynamic> json) =>
      DeviceTokenRegistration(
        token: json['device_token'] as String,
        userId: json['user_id'] as String,
        platform: json['platform'] as String? ?? 'android',
        appVersion: json['app_version'] as String? ?? '1.0.0',
        locale: json['locale'] as String? ?? 'en',
        subscribedTopics: (json['subscribed_topics'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        registeredAt: DateTime.tryParse(
                json['registered_at'] as String? ?? '') ??
            DateTime.now(),
      );
}

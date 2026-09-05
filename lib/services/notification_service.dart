import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_config.dart';
import '../data/models/notification_model.dart';
import '../data/models/push_notification_model.dart';

/// Abstract service interface for Firebase Cloud Messaging (Step 23).
/// Shielding UI components from raw platform SDK details.
abstract class INotificationService {
  /// Initializes push notification listeners for foreground and background reception
  Future<void> initialize({
    required Function(PushMessagePayload) onMessageReceived,
    Function(PushMessagePayload)? onMessageTapped,
  });

  /// Retrieves the active FCM registration token
  Future<String?> getDeviceToken();

  /// Requests user permission for push notifications (APNs / Android 13+ POST_NOTIFICATIONS)
  Future<bool> requestPermissions();

  /// Subscribes the device to an FCM topic
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes the device from an FCM topic
  Future<void> unsubscribeFromTopic(String topic);

  /// Stores device push token securely through the backend API
  Future<bool> registerDeviceTokenWithBackend({
    required String token,
    required String userId,
    required String locale,
    List<String>? topics,
    String? authToken,
  });

  /// Unregisters device token on user logout
  Future<bool> unregisterDeviceToken({
    required String token,
    String? userId,
    String? authToken,
  });

  /// Simulates an incoming FCM push notification for testing and development
  Future<PushMessagePayload> simulateIncomingPush(
    NotificationType type, {
    String? jobId,
    String? title,
    String? body,
  });

  bool get isPermissionGranted;
  String? get currentToken;
  List<String> get activeTopics;
}

/// Concrete implementation of [INotificationService]
class NotificationService implements INotificationService {
  static const String _fcmTokenPrefKey = 'jobvaani_fcm_device_token';
  static const String _fcmPermissionPrefKey = 'jobvaani_fcm_permission_granted';
  static const String _fcmTopicsPrefKey = 'jobvaani_fcm_active_topics';

  // Standard JobVaani FCM Topics
  static const String topicNewJobs = 'topic_job_matches';
  static const String topicGovtAlerts = 'topic_govt_alerts';
  static const String topicDeadlines = 'topic_deadlines';
  static const String topicSystem = 'topic_system_broadcast';

  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService();

  Function(PushMessagePayload)? _onMessageReceived;
  Function(PushMessagePayload)? _onMessageTapped;

  String? _currentToken;
  bool _isPermissionGranted = true;
  final Set<String> _activeTopics = {
    topicNewJobs,
    topicGovtAlerts,
    topicDeadlines,
    topicSystem,
  };

  @override
  bool get isPermissionGranted => _isPermissionGranted;

  @override
  String? get currentToken => _currentToken;

  @override
  List<String> get activeTopics => _activeTopics.toList();

  NotificationService() {
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentToken = prefs.getString(_fcmTokenPrefKey);
      if (_currentToken == null) {
        // Generate initial deterministic development token
        _currentToken = 'fcm_jv_${DateTime.now().millisecondsSinceEpoch}_sec_token';
        await prefs.setString(_fcmTokenPrefKey, _currentToken!);
      }

      _isPermissionGranted = prefs.getBool(_fcmPermissionPrefKey) ?? true;

      final savedTopics = prefs.getStringList(_fcmTopicsPrefKey);
      if (savedTopics != null) {
        _activeTopics.clear();
        _activeTopics.addAll(savedTopics);
      }
    } catch (_) {}
  }

  @override
  Future<void> initialize({
    required Function(PushMessagePayload) onMessageReceived,
    Function(PushMessagePayload)? onMessageTapped,
  }) async {
    _onMessageReceived = onMessageReceived;
    _onMessageTapped = onMessageTapped;

    await _loadPersistedState();

    // In production:
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   final payload = PushMessagePayload.fromFcmData(message.data, ...);
    //   _onMessageReceived?.call(payload);
    // });
    // FirebaseMessaging.onMessageOpenedApp.listen(...);
  }

  @override
  Future<String?> getDeviceToken() async {
    if (_currentToken != null) return _currentToken;
    await _loadPersistedState();
    return _currentToken;
  }

  @override
  Future<bool> requestPermissions() async {
    // In production: FirebaseMessaging.instance.requestPermission()
    _isPermissionGranted = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_fcmPermissionPrefKey, true);
    } catch (_) {}
    return true;
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    _activeTopics.add(topic);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_fcmTopicsPrefKey, _activeTopics.toList());
      // In production: FirebaseMessaging.instance.subscribeToTopic(topic);
    } catch (_) {}
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    _activeTopics.remove(topic);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_fcmTopicsPrefKey, _activeTopics.toList());
      // In production: FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    } catch (_) {}
  }

  @override
  Future<bool> registerDeviceTokenWithBackend({
    required String token,
    required String userId,
    required String locale,
    List<String>? topics,
    String? authToken,
  }) async {
    // Architecture:
    // POST to ${ApiConfig.baseUrl}${ApiConfig.deviceTokenRegisterEndpoint}
    // Headers: ApiConfig.defaultHeaders(token: authToken)
    // Body: jsonEncode(DeviceTokenRegistration(...).toJson())
    // Ensures tokens are stored encrypted and mapped to candidate profile in PostgreSQL
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  @override
  Future<bool> unregisterDeviceToken({
    required String token,
    String? userId,
    String? authToken,
  }) async {
    // Architecture:
    // DELETE to ${ApiConfig.baseUrl}${ApiConfig.deviceTokenDeleteEndpoint}
    await Future.delayed(const Duration(milliseconds: 250));
    return true;
  }

  @override
  Future<PushMessagePayload> simulateIncomingPush(
    NotificationType type, {
    String? jobId,
    String? title,
    String? body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    String finalTitle = title ?? '';
    String finalBody = body ?? '';
    String? route;
    String? targetJobId = jobId;

    switch (type) {
      case NotificationType.newJobMatch:
        finalTitle = title ?? 'New Matching Job: 92% Match';
        finalBody = body ??
            'Cybersecurity Operations & Infrastructure Engineer at Paytm Security Labs matches your skills.';
        route = 'job_details';
        targetJobId ??= 'job_cyber_sec_ops_05';
        break;

      case NotificationType.govtJobAlert:
        finalTitle = title ?? 'New Government Recruitment Alert';
        finalBody = body ??
            'UPSC Assistant Executive Engineer 240 Vacancies open for online application.';
        route = 'govt_job_details';
        targetJobId ??= 'job_upsc_02';
        break;

      case NotificationType.deadlineReminder:
        finalTitle = title ?? 'Application Deadline Warning';
        finalBody = body ??
            'Your saved application closes in 1 day: UPSC Assistant Executive Engineer. Complete your submission.';
        route = 'job_details';
        targetJobId ??= 'job_upsc_02';
        break;

      case NotificationType.system:
      default:
        finalTitle = title ?? 'JobVaani System Notice';
        finalBody = body ??
            'Your profile and native language preferences are successfully synchronized with the cloud.';
        route = 'notifications';
        break;
    }

    final payload = PushMessagePayload(
      messageId: 'fcm_sim_${DateTime.now().millisecondsSinceEpoch}',
      title: finalTitle,
      body: finalBody,
      type: type,
      relatedJobId: targetJobId,
      targetRoute: route,
      rawData: {
        'type': type.name,
        'job_id': targetJobId,
        'route': route,
        'fcm_source': 'simulation_engine',
      },
      receivedAt: DateTime.now(),
    );

    _onMessageReceived?.call(payload);
    return payload;
  }
}

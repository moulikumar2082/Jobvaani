import '../data/models/job_model.dart';
import '../data/models/notification_model.dart';

/// Service responsible for evaluating application deadlines and scheduling alerts (Step 22).
/// Supports thresholds:
/// - 7 days before deadline
/// - 3 days before deadline
/// - 1 day before deadline
/// - Deadline day (0 days left)
/// Strictly enforces that notifications are ONLY generated for valid, non-expired jobs.
class DeadlineAlertService {
  DeadlineAlertService._();

  /// Milestone days before deadline that trigger notification alerts
  static const List<int> milestoneDays = [7, 3, 1, 0];

  /// Set of generated alert signature keys to prevent duplicate notifications
  static final Set<String> _emittedAlertKeys = {};

  /// Checks a list of saved jobs and generates appropriate deadline notifications
  /// for valid, non-expired applications.
  static List<NotificationModel> evaluateSavedJobs(
    List<JobModel> savedJobs, {
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<NotificationModel> generatedAlerts = [];

    for (final job in savedJobs) {
      final deadline = DateTime(
        job.deadlineDate.year,
        job.deadlineDate.month,
        job.deadlineDate.day,
      );

      final differenceInDays = deadline.difference(today).inDays;

      // Rule: Notifications must ONLY be generated for valid, non-expired jobs
      if (differenceInDays < 0) {
        continue; // Expired job: skip completely
      }

      // Check if current remaining days matches any supported milestone threshold
      if (milestoneDays.contains(differenceInDays)) {
        final alertKey = '${job.id}_milestone_${differenceInDays}d';
        if (!_emittedAlertKeys.contains(alertKey)) {
          _emittedAlertKeys.add(alertKey);

          final notification = _createMilestoneNotification(
            job: job,
            daysRemaining: differenceInDays,
            timestamp: now,
          );
          generatedAlerts.add(notification);
        }
      }
    }

    return generatedAlerts;
  }

  /// Constructs a structured NotificationModel for a deadline milestone
  static NotificationModel _createMilestoneNotification({
    required JobModel job,
    required int daysRemaining,
    required DateTime timestamp,
  }) {
    String title;
    String message;

    if (daysRemaining == 0) {
      title = 'Deadline Alert: Closes Today';
      message =
          'Your saved application closes today: ${job.title} at ${job.company}. Complete and submit your application now.';
    } else if (daysRemaining == 1) {
      title = 'Deadline Alert: 1 Day Left';
      message =
          'Your saved application closes in 1 day: ${job.title} at ${job.company}. Do not miss the application window.';
    } else {
      title = 'Deadline Alert: $daysRemaining Days Left';
      message =
          'Your saved application closes in $daysRemaining days: ${job.title} at ${job.company}. Ensure all eligibility documents are ready.';
    }

    return NotificationModel(
      id: 'alert_${job.id}_${daysRemaining}d_${timestamp.millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: NotificationType.deadlineReminder,
      timestamp: timestamp,
      relatedJobId: job.id,
      targetRoute: 'job_details',
    );
  }

  /// Formats milestone countdown text for UI display
  static String formatMilestoneLabel(int daysRemaining) {
    if (daysRemaining < 0) {
      return 'Expired';
    } else if (daysRemaining == 0) {
      return 'Closes today';
    } else if (daysRemaining == 1) {
      return 'Closes in 1 day';
    } else {
      return 'Closes in $daysRemaining days';
    }
  }

  /// Clears in-memory emitted keys (useful for testing or cache resets)
  static void clearEmittedCache() {
    _emittedAlertKeys.clear();
  }
}

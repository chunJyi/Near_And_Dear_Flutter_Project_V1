import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static int counter = 0; // To track service execution

  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await _initializeNotifications(); // Initialize notifications

    /// Configure background service
 await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true, // ✅ Required to prevent default notification
        autoStart: true,
        notificationChannelId: 'background_service',
        foregroundServiceNotificationId: 1001, // ✅ Prevents default notification
      ),
      iosConfiguration: IosConfiguration(),
    );

    service.startService();
  }

  static void onStart(ServiceInstance service) async {
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService(); // Keeps the service running
    }

    // Handle notification button action
    service.on('STOP_SERVICE').listen((event) {
      service.stopSelf();
    });

    // Start location updates
    // LocationService.startLocationUpdates();

    // Start counting to verify the service is running
    Timer.periodic(const Duration(seconds: 5), (timer) {
      counter++;
      print('Service Running: Counter = $counter'); // Debug log
    });

    // Show single notification with Stop button
     _showNotification();
  }

  /// Initialize notifications
  static Future<void> _initializeNotifications() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'background_service',
      'Background Service',
      description: 'This channel is used for background service notifications',
      importance: Importance.high,
    );

    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings =
        InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'STOP_SERVICE') {
          stopService();
        }
      },
    );

    final FlutterLocalNotificationsPlugin plugin =
        FlutterLocalNotificationsPlugin();
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Show a single persistent notification with a "Stop Service" button
  static Future<void> _showNotification() async {
    print('Showing notification...'); // Debugging log
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'background_service',
      'Background Service',
      importance: Importance.high,
      ongoing: true,
      autoCancel: false,
      enableVibration: false,
      actions: [
        AndroidNotificationAction(
          'STOP_SERVICE', // Action ID (Must match handler)
          'Stop Service',
          showsUserInterface: true,
        ),
      ],
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      1001, // Unique notification ID
      'Location Tracking',
      'Tracking your location...',
      notificationDetails,
      payload: 'STOP_SERVICE',
    );
  }

  /// Stop the background service
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('STOP_SERVICE'); // Trigger the stop event
     _notificationsPlugin.cancel(1001); // ✅ Remove notification when stopping
  }
}

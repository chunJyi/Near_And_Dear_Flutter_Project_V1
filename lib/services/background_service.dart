import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:near_and_dear_flutter_v1/model/current_user.dart';
import 'package:near_and_dear_flutter_v1/model/location_model.dart';
import 'package:near_and_dear_flutter_v1/providers/user_provider.dart';
import 'package:near_and_dear_flutter_v1/services/location_service.dart';
import 'package:near_and_dear_flutter_v1/services/supabase_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final LocationService locationService = LocationService();

Future<void> initializeService(UserProvider userProvider) async {
  final service = FlutterBackgroundService();

  await _initializeNotifications();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: _onStart,
      autoStart: true,
      isForegroundMode: false,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: _onStart,
      onBackground: _onIosBackground,
    ),
  );

  await service.startService();
  _startLocationListener(userProvider);
}

Future<void> _initializeNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit, iOS: null);
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

@pragma('vm:entry-point')
void _onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    await _showCustomNotification();
  }

  service.on('stopService').listen((event) {
    _cancelCustomNotification();
    service.stopSelf();
    locationService.stopListening();
  });
}

Future<void> _startLocationListener(UserProvider userProvider) async {
  bool hasPermission = await locationService.requestPermission();
  if (!hasPermission) {
    debugPrint("❌ Location permission denied.");
    return;
  }

  locationService.startListening((LocationModel newLocation) async {
    if (userProvider.user != null) {
      CurrentUser updatedUser = userProvider.user!.copyWith(
        locationModel: newLocation,
        updated_at: DateTime.now().toIso8601String(),
      );
      userProvider.setUser(updatedUser);
      await SupabaseService.updateUserLocation(updatedUser);
    }
  });
}

@pragma('vm:entry-point')
Future<bool> _onIosBackground(ServiceInstance service) async {
  return true;
}

Future<void> _showCustomNotification() async {
  const androidDetails = AndroidNotificationDetails(
    'new_channel_id',
    'your_channel_name',
    channelDescription: 'This is the description of the channel',
    icon: '@mipmap/ic_launcher',
    priority: Priority.high,
    importance: Importance.defaultImportance,
    ongoing: true,
    autoCancel: false,
  );

  const generalNotificationDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    1,
    'Counter Service',
    'Counting in background',
    generalNotificationDetails,
  );
}

Future<void> _cancelCustomNotification() async {
  await flutterLocalNotificationsPlugin.cancel(1);
}

import 'package:firebase_messaging/firebase_messaging.dart';

void setupFCM() async {
  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    String? token = await messaging.getToken();
    print('🔑 FCM Token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 New notification: ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 User opened notification');
    });
  } catch (e) {
    print('⚠️ FCM setup failed: $e');
  }
}


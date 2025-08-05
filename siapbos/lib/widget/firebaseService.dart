import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

Future<void> saveFcmToken(int userId) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await http.post(
      Uri.parse('http://your-backend.com/api/save-fcm-token'),
      body: {
        'user_id': userId.toString(),
        'fcm_token': token,
      },
    );
  }
}

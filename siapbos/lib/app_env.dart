import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AppEnv {
  String getApiDomain() {
    if (kReleaseMode) {
      // Kalau release mode dan run kat device
      return 'http://192.168.0.108:3000/api'; // Ganti dengan IP PC kamu
    } else {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api'; // Android emulator
      } else {
        return 'http://localhost:3000/api'; // iOS simulator
      }
    }
  }
}

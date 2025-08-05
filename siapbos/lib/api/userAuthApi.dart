import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:siapbos/utils/rest_util.dart';

class UserAuthApi {
  
    static final String baseUrl = RestUtil().baseUrl;

      static Future<Map<String, dynamic>> login(
      String username,
      String password,
    ) async {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message']);
      }
    }

    static Future<Map<String, dynamic>> getProfile(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/profile/$userId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
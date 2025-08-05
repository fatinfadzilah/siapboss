import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:siapbos/utils/rest_util.dart';

class UserMemoApi {

   static final String baseUrl = RestUtil().baseUrl;

static Future<List<Map<String, dynamic>>> getAssignedMemos(int staffId) async {
  final response = await http.get(Uri.parse('$baseUrl/memos/assigned/$staffId'));
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load assigned memos');
  }
}

// Accept memo
static Future<void> acceptMemo(int memoId, int staffId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/memos/$memoId/accept'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'staffId': staffId}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to accept memo');
  }
}


}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:siapbos/utils/rest_util.dart';

class MemoApi {
  
   static final String baseUrl = RestUtil().baseUrl;

    static Future<List<Map<String, dynamic>>> getMemos(int projectId) async {
      final response = await http.get(
        Uri.parse('$baseUrl/displaymemo?project_id=$projectId'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load memos');
      }
    }

    static Future<void> createMemo(Map<String, dynamic> data) async {
      final response = await http.post(
        Uri.parse('$baseUrl/memo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create memo: ${response.body}');
      }
    }

  static Future<void> updateMemo(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updateMemos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) throw Exception('Failed to update memo');
  }


    static Future<void> deleteMemo(int id) async {
      final response = await http.delete( Uri.parse('$baseUrl/deleteMemos/$id'),);
      if (response.statusCode != 200) 
      throw Exception('Failed to delete memo');
    }

    static Future<List<String>> getStaffMembers() async {
      final response = await http.get(Uri.parse('$baseUrl/members'));
      if (response.statusCode != 200) throw Exception('Failed to load members');
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e['name'] as String).toList();
    }

  static Future<List<Map<String, dynamic>>> getProjects() async {
      final response = await http.get(Uri.parse('$baseUrl/projects'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch projects');
      }
    }

      static Future<List<Map<String, dynamic>>> getMemoCount() async {
      final response = await http.get(Uri.parse('$baseUrl/countMemo'));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch memo count');
      }
    }

    static Future<void> sendLocationToBackend(double lat, double lng, String address) async {
      final response = await http.post(
        Uri.parse('$baseUrl/location'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': lat,
          'longitude': lng,
          'address': address,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send location');
      }
    }

      static Future<String> generateMemoSummary(List<Map<String, dynamic>> memos) async {
        final response = await http.post(
          Uri.parse('$baseUrl/memo-summary'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'memos': memos}),
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body)['summary'];
        } else {
          throw Exception('Failed to generate summary');
        }
    }

}

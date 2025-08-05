import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:siapbos/Model/LocationSuggestionModel.dart';
import 'package:siapbos/utils/rest_util.dart';

class LocationApi {
    static final String baseUrl = RestUtil().baseUrl;

  static Future<List<LocationSuggestion>> fetchAISuggestions(String input) async {
    final response = await http.get(Uri.parse('$baseUrl/suggest?q=$input'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return List<LocationSuggestion>.from(
        data.map((item) => LocationSuggestion.fromJson(item)),
      );
    } else {
      return [];
    }
  }


}
// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔥 BASE URL must NOT include /analyze
  static const String baseUrl = "http://192.168.1.33/api/ingredients";
  //home wifi IP 192.168.1.34
  //parth wifi IP 10.221.10.227
  /// Sends OCR extracted ingredients & additives to backend
  static Future<Map<String, dynamic>> analyzeIngredients({
    required List<String> ingredients,
    required List<String> additives,
  }) async {
    // 🔥 Correct endpoint
    final url = Uri.parse("$baseUrl/analyze");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ingredients": ingredients,
          "additives": additives,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Failed to connect to server: $e"
      };
    }
  }
}
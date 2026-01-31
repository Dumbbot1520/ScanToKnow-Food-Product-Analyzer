// lib/core/network/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:async'; // ✅ REQUIRED for TimeoutException
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static Future<dynamic> get(String endpoint) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 8));

      // DEBUG LOGS (keep for now)
      // ignore: avoid_print
      print('GET $uri → ${response.statusCode}');
      // ignore: avoid_print
      print('BODY: ${response.body}');

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    }
    // ⬇️ ORDER MATTERS
    on TimeoutException {
      throw Exception('Request timed out');
    }
    on SocketException {
      throw Exception('No internet / server unreachable');
    }
    catch (e) {
      throw Exception('API error: $e');
    }
  }
}

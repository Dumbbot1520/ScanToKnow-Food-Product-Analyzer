// import 'dart:convert';
// import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:main_project_files/services/api_service.dart';

Future<Map<String, dynamic>?> fetchProduct(String barcode) async {
  try {
    // Replace with your actual backend URL
    final url = Uri.parse('http://10.221.10.139:4000/api/barcode/product/$barcode');
    // 10.112.13.139
    final response = await http.get(
      url,
      headers: {
        'x-api-key': 'Sc@nT0Kn0wSECRET13579', // same key as in your Node.js backend
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null; // product not found
    } else {
      throw Exception('Failed to fetch product: ${response.statusCode}');
    }
  } catch (e) {
    print('Error in fetchProduct: $e');
    throw e;
  }
}

// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
//
// class OCRApiService {
//   static const String _baseUrl =
//       "http://192.168.29.116/v1/ocr/scan"; // emulator
//
//   static Future<Map<String, dynamic>> scanImage(File image) async {
//     final request = http.MultipartRequest(
//       "POST",
//       Uri.parse(_baseUrl),
//     );
//
//     request.files.add(
//       await http.MultipartFile.fromPath("image", image.path),
//     );
//
//     final response = await request.send();
//     final body = await response.stream.bytesToString();
//
//     if (response.statusCode != 200) {
//       throw Exception("OCR request failed");
//     }
//
//     return jsonDecode(body)["data"];
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OCRApiService {
  static const String _baseUrl =
      "http://172.18.128.75:4000/v1/ocr/scan";

  static Future<Map<String, dynamic>> scanImage(File image) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(_baseUrl),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "image", // ✅ MUST MATCH upload.single("image")
        image.path,
      ),
    );


    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("OCR request failed: ${response.statusCode}");
    }

    return jsonDecode(body)["data"];
  }
}


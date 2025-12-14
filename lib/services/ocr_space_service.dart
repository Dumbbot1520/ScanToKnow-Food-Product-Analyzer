import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:main_project_files/services/api_service.dart';


class OCRSpaceService {
  static const String apiKey = "K83335691088957"; // replace

  static Future<String> extractTextFromImage(Uint8List imageBytes) async {
    final uri = Uri.parse("https://api.ocr.space/parse/image");

    final request = http.MultipartRequest("POST", uri)
      ..fields["language"] = "eng"
      ..fields["OCREngine"] = "2"
      ..fields["scale"] = "true"
      ..fields["isTable"] = "false"
      ..headers["apikey"] = apiKey
      ..files.add(
        http.MultipartFile.fromBytes(
          "file",
          imageBytes,
          filename: "scan.jpg",
        ),
      );

    final response = await request.send();
    final respString = await response.stream.bytesToString();

    try {
      final data = jsonDecode(respString);

      if (data["IsErroredOnProcessing"] == true) {
        print("OCR.Space error: ${data["ErrorMessage"]}");
        return "";
      }

      final text = data["ParsedResults"]?[0]?["ParsedText"] ?? "";
      return text.trim();
    } catch (e) {
      print("OCR.Space parse error: $e");
      return "";
    }
  }
}

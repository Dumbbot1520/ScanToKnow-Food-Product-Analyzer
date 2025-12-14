//
// // lib/pages/ocr_scan_page.dart
// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image/image.dart' as img;
// import 'package:path/path.dart' as p;
//
// // Helper files
// import '../utils/ingredient_box_painter.dart';
// import '../utils/ingredient_extractor.dart';
// import '../service/api_service.dart';
//
// // NEW OCR product detail page
// import '../pages/ocr_product_detail_page.dart';
//
// class OCRScanPage extends StatefulWidget {
//   const OCRScanPage({super.key});
//
//   @override
//   State<OCRScanPage> createState() => _OCRScanPageState();
// }
//
// class _OCRScanPageState extends State<OCRScanPage> {
//   CameraController? _cameraController;
//   bool _isCameraInitialized = false;
//   String scannedText = "";
//   late final TextRecognizer _textRecognizer;
//   bool _isProcessing = false;
//
//   // bounding box for cropping
//   final double boxLeftPct = 0.10;
//   final double boxTopPct = 0.25;
//   final double boxWidthPct = 0.80;
//   final double boxHeightPct = 0.40;
//
//   @override
//   void initState() {
//     super.initState();
//     _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//     _initCamera();
//   }
//
//   Future<void> _initCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final camera = cameras.firstWhere(
//             (c) => c.lensDirection == CameraLensDirection.back,
//         orElse: () => cameras.first,
//       );
//
//       _cameraController = CameraController(
//         camera,
//         ResolutionPreset.high,
//         enableAudio: false,
//         imageFormatGroup: ImageFormatGroup.yuv420,
//       );
//
//       await _cameraController!.initialize();
//       if (!mounted) return;
//       setState(() => _isCameraInitialized = true);
//     } catch (e) {
//       debugPrint('Camera init error: $e');
//     }
//   }
//
//   Future<void> _captureAndProcess() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) return;
//     if (_isProcessing) return;
//
//     setState(() => _isProcessing = true);
//
//     try {
//       final XFile file = await _cameraController!.takePicture();
//
//       // 🔥 crop the image to bounding box
//       final File croppedFile = await _cropToBox(File(file.path));
//
//       // 🔥 OCR on cropped image
//       final inputImage = InputImage.fromFilePath(croppedFile.path);
//       final RecognizedText recognizedText =
//       await _textRecognizer.processImage(inputImage);
//
//       if (!mounted) return;
//
//       final rawText = recognizedText.text;
//       setState(() => scannedText = rawText);
//
//       // 🔥 Extract ingredient section from OCR
//       final String ingredientSection =
//       IngredientExtractor.extractIngredientsSection(rawText);
//
//       // If ingredientSection empty, use raw OCR text
//       final String textToSplit =
//       ingredientSection.isNotEmpty ? ingredientSection : rawText;
//
//       // 🔥 Split into items
//       final List<String> items = IngredientExtractor.splitIngredients(textToSplit);
//
//       // 🔥 Classify into ingredients vs additives
//       final Map<String, List<String>> classified =
//       IngredientExtractor.classify(items);
//
//       // 🔥 Call backend API for full details
//       final apiResponse = await ApiService.analyzeIngredients(
//         ingredients: classified['ingredients'] ?? [],
//         additives: classified['additives'] ?? [],
//       );
//
//       if (!mounted) return;
//
//       // 🔥 Navigate to OCR-specific results page
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => OCRProductDetailPage(
//             ingredients: apiResponse["ingredients"] ?? [],
//             additives: apiResponse["additives"] ?? [],
//           ),
//         ),
//       );
//     } catch (e, st) {
//       debugPrint('Capture/process error: $e\n$st');
//     } finally {
//       if (mounted) setState(() => _isProcessing = false);
//     }
//   }
//
//   Future<File> _cropToBox(File originalFile) async {
//     final bytes = await originalFile.readAsBytes();
//     final img.Image? decodedImg = img.decodeImage(bytes);
//
//     if (decodedImg == null) {
//       return originalFile;
//     }
//
//     final int cropLeft = (decodedImg.width * boxLeftPct).round();
//     final int cropTop = (decodedImg.height * boxTopPct).round();
//     final int cropWidth = (decodedImg.width * boxWidthPct).round();
//     final int cropHeight = (decodedImg.height * boxHeightPct).round();
//
//     final int safeLeft = cropLeft.clamp(0, decodedImg.width - 1);
//     final int safeTop = cropTop.clamp(0, decodedImg.height - 1);
//     final int safeWidth = (safeLeft + cropWidth > decodedImg.width)
//         ? decodedImg.width - safeLeft
//         : cropWidth;
//     final int safeHeight = (safeTop + cropHeight > decodedImg.height)
//         ? decodedImg.height - safeTop
//         : cropHeight;
//
//     final img.Image cropped = img.copyCrop(
//       decodedImg,
//       x: safeLeft,
//       y: safeTop,
//       width: safeWidth,
//       height: safeHeight,
//     );
//
//     final String dir = p.dirname(originalFile.path);
//     final String name = p.basenameWithoutExtension(originalFile.path);
//     final String newPath = p.join(dir, '${name}_crop.jpg');
//
//     final File outFile = File(newPath);
//     await outFile.writeAsBytes(img.encodeJpg(cropped, quality: 90));
//     return outFile;
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _textRecognizer.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('OCR Scanner'),
//         backgroundColor: Colors.deepOrange,
//       ),
//       body: _isCameraInitialized && _cameraController != null
//           ? Stack(
//         fit: StackFit.expand,
//         children: [
//           CameraPreview(_cameraController!),
//
//           // Bounding box UI
//           Positioned.fill(
//             child: CustomPaint(
//               painter: IngredientBoxPainter(
//                 leftPct: boxLeftPct,
//                 topPct: boxTopPct,
//                 widthPct: boxWidthPct,
//                 heightPct: boxHeightPct,
//               ),
//             ),
//           ),
//
//           // Instructions
//           Positioned(
//             top: 16,
//             left: 16,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.black45,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Text(
//                 'Align the Ingredients section inside the white box and press the shutter',
//                 style: TextStyle(color: Colors.white),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//
//           // OCR preview text at bottom
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               width: double.infinity,
//               color: Colors.black54,
//               padding:
//               const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               child: Text(
//                 scannedText.isEmpty ? 'No text yet' : scannedText,
//                 style: const TextStyle(color: Colors.white),
//                 maxLines: 6,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),
//
//           // Capture button
//           Positioned(
//             bottom: 90,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   shape: const CircleBorder(),
//                   padding: const EdgeInsets.all(18),
//                   backgroundColor: Colors.white70,
//                 ),
//                 onPressed: _isProcessing ? null : _captureAndProcess,
//                 child: _isProcessing
//                     ? const SizedBox(
//                   height: 24,
//                   width: 24,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 )
//                     : const Icon(Icons.camera,
//                     color: Colors.black87, size: 28),
//               ),
//             ),
//           ),
//         ],
//       )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
// }





// // lib/pages/ocr_scan_page.dart
// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image/image.dart' as img;
// import 'package:path/path.dart' as p;
//
// import '../utils/ingredient_extractor.dart';
// import '../service/api_service.dart';
// import '../pages/ocr_product_detail_page.dart';
//
// class OCRScanPage extends StatefulWidget {
//   const OCRScanPage({super.key});
//
//   @override
//   State<OCRScanPage> createState() => _OCRScanPageState();
// }
//
// class _OCRScanPageState extends State<OCRScanPage> {
//   CameraController? _cameraController;
//   bool _isCameraInitialized = false;
//   bool _isProcessing = false;
//
//   late final TextRecognizer _textRecognizer;
//   String scannedText = "";
//
//   // SIMPLE FIXED CROP BOX (percentages of camera image)
//   final double boxLeftPct = 0.10;
//   final double boxTopPct = 0.30;
//   final double boxWidthPct = 0.80;
//   final double boxHeightPct = 0.35;
//
//   @override
//   void initState() {
//     super.initState();
//     _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//     _initCamera();
//   }
//
//   Future<void> _initCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final cam = cameras.firstWhere(
//             (c) => c.lensDirection == CameraLensDirection.back,
//         orElse: () => cameras.first,
//       );
//
//       _cameraController = CameraController(
//         cam,
//         ResolutionPreset.high,
//         enableAudio: false,
//       );
//
//       await _cameraController!.initialize();
//       if (!mounted) return;
//
//       setState(() => _isCameraInitialized = true);
//     } catch (e) {
//       debugPrint("Camera error: $e");
//     }
//   }
//
//   // ============================
//   // SIMPLE CROP FUNCTION
//   // ============================
//   Future<File> _cropToBox(File originalFile) async {
//     final bytes = await originalFile.readAsBytes();
//     final img.Image? decoded = img.decodeImage(bytes);
//
//     if (decoded == null) return originalFile;
//
//     final left = (decoded.width * boxLeftPct).round();
//     final top = (decoded.height * boxTopPct).round();
//     final width = (decoded.width * boxWidthPct).round();
//     final height = (decoded.height * boxHeightPct).round();
//
//     final cropped = img.copyCrop(
//       decoded,
//       x: left,
//       y: top,
//       width: width,
//       height: height,
//     );
//
//     final newPath = originalFile.path.replaceAll(".jpg", "_crop.jpg");
//     final outFile = File(newPath);
//     await outFile.writeAsBytes(img.encodeJpg(cropped, quality: 95));
//
//     return outFile;
//   }
//
//   // ============================
//   // PROCESS CAPTURE
//   // ============================
//   Future<void> _captureAndProcess() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) return;
//     if (_isProcessing) return;
//
//     setState(() => _isProcessing = true);
//
//     try {
//       final XFile picture = await _cameraController!.takePicture();
//       final File croppedImg = await _cropToBox(File(picture.path));
//
//       final inputImage = InputImage.fromFilePath(croppedImg.path);
//       final RecognizedText result =
//       await _textRecognizer.processImage(inputImage);
//
//       scannedText = result.text;
//
//       // Extract ingredient section
//       final extracted = IngredientExtractor.extractIngredientsSection(scannedText);
//
//       // Split items
//       final items = IngredientExtractor.splitIngredients(
//         extracted.isNotEmpty ? extracted : scannedText,
//       );
//
//       // Classify
//       final classified = IngredientExtractor.classify(items);
//
//       // Log for debugging
//       print("======= OCR DEBUG =======");
//       print("RAW OCR:\n$scannedText");
//       print("------------------------");
//       print("EXTRACTED:\n$extracted");
//       print("------------------------");
//       print("SPLIT ITEMS:\n$items");
//       print("------------------------");
//       print("CLASSIFIED:\n$classified");
//       print("========================");
//
//       // API CALL
//       final apiResponse = await ApiService.analyzeIngredients(
//         ingredients: classified["ingredients"] ?? [],
//         additives: classified["additives"] ?? [],
//       );
//
//       if (!mounted) return;
//
//       // Navigate to result screen
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => OCRProductDetailPage(
//             ingredients: apiResponse["ingredients"] ?? [],
//             additives: apiResponse["additives"] ?? [],
//           ),
//         ),
//       );
//     } catch (e) {
//       debugPrint("OCR ERROR: $e");
//     }
//
//     setState(() => _isProcessing = false);
//   }
//
//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _textRecognizer.close();
//     super.dispose();
//   }
//
//   // ============================
//   // UI
//   // ============================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("OCR Scanner"),
//         backgroundColor: Colors.deepOrange,
//       ),
//       body: !_isCameraInitialized
//           ? const Center(child: CircularProgressIndicator())
//           : Stack(
//         children: [
//           CameraPreview(_cameraController!),
//
//           // SIMPLE WHITE BOX FOR ALIGNMENT
//           Positioned(
//             left: MediaQuery.of(context).size.width * boxLeftPct,
//             top: MediaQuery.of(context).size.height * boxTopPct,
//             child: Container(
//               width: MediaQuery.of(context).size.width * boxWidthPct,
//               height: MediaQuery.of(context).size.height * boxHeightPct,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.white, width: 3),
//               ),
//             ),
//           ),
//
//           Positioned(
//             top: 20,
//             left: 20,
//             right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               color: Colors.black54,
//               child: const Text(
//                 "Place ONLY the ingredients text inside the white box.\nThen press the button.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//
//           // CAPTURE BUTTON
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   shape: const CircleBorder(),
//                   backgroundColor: Colors.white,
//                   padding: const EdgeInsets.all(18),
//                 ),
//                 onPressed: _isProcessing ? null : _captureAndProcess,
//                 child: _isProcessing
//                     ? const CircularProgressIndicator()
//                     : const Icon(Icons.camera_alt, color: Colors.black),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// lib/pages/ocr_scan_page.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:main_project_files/scan/ocr/ingredient_extractor.dart';
import 'package:main_project_files/scan/ocr/text_cleaner.dart';
import 'package:main_project_files/services/ocr_space_service.dart';
import 'package:main_project_files/scan/ocr/ocr_product_detail_page.dart';
import 'package:main_project_files/services/api_service.dart';


class OCRScanPage extends StatefulWidget {
  const OCRScanPage({super.key});

  @override
  State<OCRScanPage> createState() => _OCRScanPageState();
}

class _OCRScanPageState extends State<OCRScanPage> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;

  String scannedText = "";

  // Stationary box (alignment only)
  final double boxLeftPct = 0.10;
  final double boxTopPct = 0.30;
  final double boxWidthPct = 0.80;
  final double boxHeightPct = 0.35;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCam = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCam,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  // --------------------------
  // CROP TO WHITE BOX (RESTORED)
  // --------------------------
  Future<File> _cropToBox(File originalFile) async {
    try {
      final bytes = await originalFile.readAsBytes();
      final img.Image? decoded = img.decodeImage(bytes);

      if (decoded == null) return originalFile;

      final left = (decoded.width * boxLeftPct).round();
      final top = (decoded.height * boxTopPct).round();
      final width = (decoded.width * boxWidthPct).round();
      final height = (decoded.height * boxHeightPct).round();

      final cropped = img.copyCrop(
        decoded,
        x: left,
        y: top,
        width: width,
        height: height,
      );

      final newPath = originalFile.path.replaceAll(".jpg", "_crop.jpg");
      final outFile = File(newPath);
      await outFile.writeAsBytes(img.encodeJpg(cropped, quality: 95));

      return outFile;
    } catch (e) {
      print("Crop error: $e");
      return originalFile;
    }
  }

  // --------------------------
  // PROCESS CAPTURE (Now uses CROPPING)
  // --------------------------
  Future<void> _captureAndProcess() async {
    if (!_isCameraInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      print("📸 Capturing image...");
      final XFile picture = await _cameraController!.takePicture();

      // ⭐ CROP IMAGE TO WHITE BOX REGION
      final File croppedImg = await _cropToBox(File(picture.path));

      // READ ONLY THE CROPPED IMAGE
      Uint8List imgBytes = await croppedImg.readAsBytes();

      print("🔹 Sending cropped image to OCR.Space...");
      scannedText = await OCRSpaceService.extractTextFromImage(imgBytes);

      if (scannedText.trim().isEmpty) {
        print("⚠ OCR returned empty text");
      }

      // Extract ingredient section
      final extracted = IngredientExtractor.extractIngredientsSection(scannedText);

      // Split items
      final items = IngredientExtractor.splitIngredients(
        extracted.isNotEmpty ? extracted : scannedText,
      );

      // Classify
      final classified = IngredientExtractor.classify(items);

      // Debug logs
      print("======= OCR DEBUG =======");
      print("RAW OCR:\n$scannedText");
      print("------------------------");
      print("EXTRACTED:\n$extracted");
      print("------------------------");
      print("SPLIT ITEMS:\n$items");
      print("------------------------");
      print("CLASSIFIED:\n$classified");
      print("========================");

      // Send to backend API
      final apiResponse = await ApiService.analyzeIngredients(
        ingredients: classified["ingredients"] ?? [],
        additives: classified["additives"] ?? [],
      );

      if (!mounted) return;

      // Navigate to result UI
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OCRProductDetailPage(
            ingredients: apiResponse["ingredients"] ?? [],
            additives: apiResponse["additives"] ?? [],
          ),
        ),
      );
    } catch (e) {
      debugPrint("OCR ERROR: $e");
    }

    setState(() => _isProcessing = false);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // --------------------------
  // UI
  // --------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OCR Scanner"),
        backgroundColor: Colors.deepOrange,
      ),
      body: !_isCameraInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          CameraPreview(_cameraController!),

          // White guide box
          Positioned(
            left: MediaQuery.of(context).size.width * boxLeftPct,
            top: MediaQuery.of(context).size.height * boxTopPct,
            child: Container(
              width: MediaQuery.of(context).size.width * boxWidthPct,
              height: MediaQuery.of(context).size.height * boxHeightPct,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
          ),

          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: const Text(
                "Place ONLY the ingredients text inside the white box.\nThen press the button.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(18),
                ),
                onPressed: _isProcessing ? null : _captureAndProcess,
                child: _isProcessing
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.camera_alt, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

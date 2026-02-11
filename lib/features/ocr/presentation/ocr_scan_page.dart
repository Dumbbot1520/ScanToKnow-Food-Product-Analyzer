// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import '../data/ocr_api_service.dart';
// import 'ocr_result_page.dart';
//
// class OCRScanPage extends StatefulWidget {
//   const OCRScanPage({super.key});
//
//   @override
//   State<OCRScanPage> createState() => _OCRScanPageState();
// }
//
// class _OCRScanPageState extends State<OCRScanPage> {
//   CameraController? _camera;
//   bool _loading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }
//
//   Future<void> _initCamera() async {
//     final cameras = await availableCameras();
//     final back = cameras.firstWhere(
//           (c) => c.lensDirection == CameraLensDirection.back,
//     );
//
//     _camera = CameraController(
//       back,
//       ResolutionPreset.high,
//       enableAudio: false,
//     );
//
//     await _camera!.initialize();
//     if (mounted) setState(() {});
//   }
//
//   Future<void> _capture() async {
//     if (_camera == null || _loading) return;
//
//     setState(() => _loading = true);
//
//     try {
//       final image = await _camera!.takePicture();
//       final data =
//       await OCRApiService.scanImage(File(image.path));
//
//       if (!mounted) return;
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => OCRResultPage(data: data),
//         ),
//       );
//     } catch (_) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("OCR failed")),
//       );
//     }
//
//     setState(() => _loading = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_camera == null || !_camera!.value.isInitialized) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Smart Read")),
//       body: Stack(
//         children: [
//           CameraPreview(_camera!),
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: FloatingActionButton(
//                 onPressed: _capture,
//                 child: _loading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Icon(Icons.camera_alt),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import '../data/ocr_api_service.dart';
// import 'ocr_result_page.dart';
//
// class OCRScanPage extends StatefulWidget {
//   const OCRScanPage({super.key});
//
//   @override
//   State<OCRScanPage> createState() => _OCRScanPageState();
// }
//
// class _OCRScanPageState extends State<OCRScanPage> {
//   CameraController? _camera;
//   bool _loading = false;
//   bool _cameraReady = false; // 🔒 prevents early capture
//
//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }
//
//   Future<void> _initCamera() async {
//     final cameras = await availableCameras();
//     final back = cameras.firstWhere(
//           (c) => c.lensDirection == CameraLensDirection.back,
//     );
//
//     _camera = CameraController(
//       back,
//       ResolutionPreset.medium, // ✅ VERY IMPORTANT
//       enableAudio: false,
//     );
//
//     await _camera!.initialize();
//     if (!mounted) return;
//
//     setState(() {
//       _cameraReady = true;
//     });
//   }
//
//   Future<void> _capture() async {
//     // 🔒 HARD LOCK
//     if (!_cameraReady || _camera == null || _loading) return;
//
//     setState(() => _loading = true);
//
//     try {
//       final image = await _camera!.takePicture();
//
//       final data = await OCRApiService.scanImage(
//         File(image.path),
//       );
//
//       if (!mounted) return;
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => OCRResultPage(data: data),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("OCR failed. Please try again."),
//         ),
//       );
//     } finally {
//       // ✅ GUARANTEED RELEASE
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _camera?.dispose(); // ✅ CRITICAL
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_cameraReady || _camera == null) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Smart Read")),
//       body: Stack(
//         children: [
//           CameraPreview(_camera!),
//
//           Positioned(
//             bottom: 40,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: FloatingActionButton(
//                 onPressed: _loading ? null : _capture, // 🔒
//                 backgroundColor: Colors.teal,
//                 child: _loading
//                     ? const SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//                     : const Icon(Icons.camera_alt),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../data/ocr_api_service.dart';
import 'ocr_result_page.dart';

class OCRScanPage extends StatefulWidget {
  const OCRScanPage({super.key});

  @override
  State<OCRScanPage> createState() => _OCRScanPageState();
}

class _OCRScanPageState extends State<OCRScanPage> {
  CameraController? _camera;
  bool _loading = false;
  bool _cameraReady = false;
  bool _captureInProgress = false; // ✅ NEW: hard lock

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
    );

    _camera = CameraController(
      back,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _camera!.initialize();
    if (!mounted) return;

    setState(() {
      _cameraReady = true;
    });
  }

  Future<void> _capture() async {
    // 🔒 ABSOLUTE LOCK
    if (!_cameraReady || _camera == null || _loading || _captureInProgress) {
      return;
    }

    _captureInProgress = true; // 🔐 lock IMMEDIATELY
    setState(() => _loading = true);

    try {
      final image = await _camera!.takePicture();

      final data = await OCRApiService.scanImage(
        File(image.path),
      );

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OCRResultPage(data: data),
        ),
      );

      // 🧘 allow camera buffers to clear
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OCR failed. Please try again."),
        ),
      );
    } finally {
      _captureInProgress = false; // 🔓 unlock
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraReady || _camera == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Smart Read")),
      body: Stack(
        children: [
          CameraPreview(_camera!),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _loading ? null : _capture,
                backgroundColor: Colors.teal,
                child: _loading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// // lib/features/scan/presentation/barcode_scan_page.dart
//
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
//
// import '../../../core/network/api_service.dart';
// import '../../variants/presentation/variant_detail_page.dart';
// import 'scanner_overlay.dart';
//
// class BarcodeScanPage extends StatefulWidget {
//   const BarcodeScanPage({super.key});
//
//   @override
//   State<BarcodeScanPage> createState() => _BarcodeScanPageState();
// }
//
// class _BarcodeScanPageState extends State<BarcodeScanPage>
//     with SingleTickerProviderStateMixin {
//   CameraController? _cameraController;
//   CameraDescription? _cameraDescription;
//   late final BarcodeScanner _barcodeScanner;
//
//   // frame-level processing guard
//   bool _isProcessing = false;
//
//   // scan-level lock: once we've accepted a barcode and are awaiting result/navigation
//   bool _scanningInProgress = false;
//
//   // throttle: at most one process per X ms
//   int _lastProcessTs = 0;
//   static const int _processThrottleMs = 250;
//
//   late AnimationController _laserController;
//   bool _torchOn = false;
//
//   // UI feedback
//   String? _lastRecognizedBarcode;
//   bool _isCallingApi = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
//     _initCamera();
//
//     _laserController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);
//   }
//
//   Future<void> _initCamera() async {
//     try {
//       final cameras = await availableCameras();
//       final backCamera = cameras.firstWhere(
//             (c) => c.lensDirection == CameraLensDirection.back,
//       );
//
//       _cameraDescription = backCamera;
//
//       _cameraController = CameraController(
//         backCamera,
//         ResolutionPreset.medium,
//         enableAudio: false,
//       );
//
//       await _cameraController!.initialize();
//
//       // start stream only after initialization
//       await _cameraController!.startImageStream(_processImage);
//
//       if (mounted) setState(() {});
//     } catch (e) {
//       // initialization failure — surface as snack for debugging
//       // ignore: avoid_print
//       print('Camera init error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Camera initialization failed: $e')),
//         );
//       }
//     }
//   }
//
//   Future<void> _processImage(CameraImage image) async {
//     // throttle
//     final now = DateTime.now().millisecondsSinceEpoch;
//     if (now - _lastProcessTs < _processThrottleMs) return;
//     _lastProcessTs = now;
//
//     if (_isProcessing || _scanningInProgress) return;
//     _isProcessing = true;
//
//     try {
//       final inputImage = _cameraImageToInputImage(image, _cameraDescription);
//       final barcodes = await _barcodeScanner.processImage(inputImage);
//
//       if (barcodes.isNotEmpty) {
//         final code = barcodes.first.rawValue;
//         if (code != null && code.trim().isNotEmpty) {
//           // show quick UI feedback
//           setState(() {
//             _lastRecognizedBarcode = code;
//           });
//
//           // short debounce so user can see recognized value
//           await Future.delayed(const Duration(milliseconds: 80));
//
//           await _handleBarcode(code);
//         }
//       }
//     } catch (e) {
//       // ignore frame-level errors silently but log for debugging
//       // ignore: avoid_print
//       print('Frame processing error: $e');
//     } finally {
//       _isProcessing = false;
//     }
//   }
//
//   Future<void> _handleBarcode(String rawBarcode) async {
//     if (_scanningInProgress) return;
//
//     _scanningInProgress = true;
//     _isCallingApi = true;
//     setState(() {});
//
//     // normalize & remove zero-width characters, trim
//     String barcode = rawBarcode.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '').trim();
//
//     // safe encode for URI
//     final encoded = Uri.encodeComponent(barcode);
//
//     // stop stream (best-effort)
//     try {
//       if (_cameraController != null && _cameraController!.value.isStreamingImages) {
//         await _cameraController?.stopImageStream();
//       }
//     } catch (e) {
//       // some devices throw if not streaming; ignore
//       // ignore: avoid_print
//       print('stopImageStream warning: $e');
//     }
//
//     // show local debug
//     // ignore: avoid_print
//     print('Scanning barcode: raw="$rawBarcode" -> normalized="$barcode" -> encoded="$encoded"');
//
//     try {
//       final res = await ApiService.get('/v1/scan/$encoded');
//
//       if (!mounted) return;
//
//       // expect { status:"ok", data: {...} }
//       if (res is Map && res['data'] != null) {
//         // haptic to indicate success
//         HapticFeedback.mediumImpact();
//
//         // optional short delay to improve UX (let user see flash/haptic)
//         await Future.delayed(const Duration(milliseconds: 120));
//
//         final variantId = res['data']['id']?.toString();
//         if (variantId != null && variantId.isNotEmpty) {
//           // navigate to detail (replace)
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (_) => VariantDetailPage(variantId: variantId),
//             ),
//           );
//           return; // do not restart stream — page was replaced
//         }
//       } else {
//         // not found path
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Product not found')),
//           );
//         }
//       }
//     } catch (e) {
//       // network or API error
//       // show limited message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Scan failed: ${e.toString()}')),
//         );
//       }
//     } finally {
//       // if we are still on this page, restart stream after short delay and unlock
//       _isCallingApi = false;
//       _scanningInProgress = false;
//       if (mounted) {
//         setState(() {});
//         // small backoff to avoid immediate re-triggering
//         await Future.delayed(const Duration(milliseconds: 400));
//         try {
//           if (_cameraController != null && !_cameraController!.value.isStreamingImages) {
//             await _cameraController?.startImageStream(_processImage);
//           }
//         } catch (e) {
//           // ignore restart errors but log
//           // ignore: avoid_print
//           print('startImageStream warning: $e');
//         }
//       }
//     }
//   }
//
//   /// Convert CameraImage -> InputImage for ML Kit.
//   /// Works for typical Android YUV_420_888 (NV21) and iOS BGRA.
//   InputImage _cameraImageToInputImage(CameraImage image, CameraDescription? description) {
//     final allBytes = WriteBuffer();
//
//     // Concatenate plane bytes
//     for (final plane in image.planes) {
//       allBytes.putUint8List(plane.bytes);
//     }
//     final bytes = allBytes.done().buffer.asUint8List();
//
//     // rotation: map sensorOrientation to InputImageRotation
//     final rotation = _rotationIntToImageRotation(description?.sensorOrientation ?? 0);
//
//     // format: choose based on platform
//     final format = Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;
//
//     return InputImage.fromBytes(
//       bytes: bytes,
//       metadata: InputImageMetadata(
//         size: Size(image.width.toDouble(), image.height.toDouble()),
//         rotation: rotation,
//         format: format,
//         bytesPerRow: image.planes.first.bytesPerRow,
//       ),
//     );
//   }
//
//   InputImageRotation _rotationIntToImageRotation(int rotation) {
//     switch (rotation) {
//       case 90:
//         return InputImageRotation.rotation90deg;
//       case 180:
//         return InputImageRotation.rotation180deg;
//       case 270:
//         return InputImageRotation.rotation270deg;
//       case 0:
//       default:
//         return InputImageRotation.rotation0deg;
//     }
//   }
//
//   Future<void> _toggleTorch() async {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) return;
//     try {
//       if (_torchOn) {
//         await _cameraController?.setFlashMode(FlashMode.off);
//       } else {
//         await _cameraController?.setFlashMode(FlashMode.torch);
//       }
//       _torchOn = !_torchOn;
//       if (mounted) setState(() {});
//     } catch (e) {
//       // some devices may not support torch; inform user
//       // ignore: avoid_print
//       print('Torch toggle failed: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Torch not supported on this device')),
//         );
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _laserController.dispose();
//     _cameraController?.dispose();
//     _barcodeScanner.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           CameraPreview(_cameraController!),
//
//           // Scanner UI
//           ScannerOverlay(laserAnimation: _laserController),
//
//           // Close button
//           Positioned(
//             top: 40,
//             left: 20,
//             child: IconButton(
//               icon: const Icon(Icons.close, color: Colors.white, size: 28),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//
//           // Torch button (top-right)
//           Positioned(
//             top: 40,
//             right: 20,
//             child: IconButton(
//               icon: Icon(
//                 _torchOn ? Icons.flash_on : Icons.flash_off,
//                 color: _torchOn ? Colors.amber : Colors.white,
//                 size: 26,
//               ),
//               onPressed: _toggleTorch,
//             ),
//           ),
//
//           // Instruction text (bottom)
//           Positioned(
//             bottom: 110,
//             left: 20,
//             right: 20,
//             child: const Text(
//               'Hold phone with the barcode horizontal inside the frame.\nTurn phone sideways if needed.',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.white70, fontSize: 14),
//             ),
//           ),
//
//           // Small scanning status & preview
//           Positioned(
//             bottom: 60,
//             left: 0,
//             right: 0,
//             child: Center(
//               child: Column(
//                 children: [
//                   if (_isCallingApi)
//                     const Text('Scanning...', style: TextStyle(color: Colors.white70)),
//                   if (!_isCallingApi && _lastRecognizedBarcode != null)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: Colors.black54,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         'Recognized: ${_lastRecognizedBarcode}',
//                         style: const TextStyle(color: Colors.white70),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// lib/features/scan/presentation/barcode_scan_page.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../../core/network/api_service.dart';
import '../../variants/presentation/variant_detail_page.dart';
import 'scanner_overlay.dart';

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  CameraDescription? _cameraDescription;
  late final BarcodeScanner _barcodeScanner;

  bool _isProcessing = false;
  bool _scanLocked = false;

  int _lastProcessTs = 0;
  static const int _throttleMs = 250;

  late AnimationController _laserController;
  bool _torchOn = false;

  String? _lastCode;
  bool _callingApi = false;

  @override
  void initState() {
    super.initState();

    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
      );

      _cameraDescription = back;
      _cameraController = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _cameraController!.startImageStream(_processImage);

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      // camera init failure
    }
  }

  Future<void> _processImage(CameraImage image) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastProcessTs < _throttleMs) {
      return;
    }
    _lastProcessTs = now;

    if (_isProcessing || _scanLocked) {
      return;
    }

    _isProcessing = true;

    try {
      final input =
      _toInputImage(image, _cameraDescription);
      final barcodes =
      await _barcodeScanner.processImage(input);

      if (barcodes.isNotEmpty) {
        final raw = barcodes.first.rawValue;
        if (raw != null && raw.trim().isNotEmpty) {
          if (mounted) {
            setState(() {
              _lastCode = raw;
            });
          }
          await Future.delayed(const Duration(milliseconds: 80));
          await _handleBarcode(raw);
        }
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _handleBarcode(String raw) async {
    if (_scanLocked) {
      return;
    }

    _scanLocked = true;

    if (mounted) {
      setState(() {
        _callingApi = true;
      });
    }

    final cleaned =
    raw.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '').trim();
    final encoded = Uri.encodeComponent(cleaned);

    bool success = false;
    String? variantId;

    try {
      if (_cameraController?.value.isStreamingImages == true) {
        await _cameraController!.stopImageStream();
      }

      final res = await ApiService.get('/v1/scan/$encoded');
      if (res is Map && res['data'] != null) {
        variantId = res['data']['id']?.toString();
        success = variantId != null && variantId.isNotEmpty;

      }
    } catch (_) {
      success = false;
    }

    if (!mounted) {
      return;
    }

    if (success) {
      HapticFeedback.mediumImpact();
      _navigateToVariant(variantId!);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product not found')),
    );

    _callingApi = false;
    _scanLocked = false;

    setState(() {});

    await Future.delayed(const Duration(milliseconds: 400));
    if (_cameraController?.value.isStreamingImages == false) {
      await _cameraController!.startImageStream(_processImage);
    }
  }

  void _navigateToVariant(String id) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VariantDetailPage(variantId: id),
      ),
    );
  }

  InputImage _toInputImage(
      CameraImage image,
      CameraDescription? desc,
      ) {
    final buffer = WriteBuffer();
    for (final p in image.planes) {
      buffer.putUint8List(p.bytes);
    }

    final rotation =
    _rotation(desc?.sensorOrientation ?? 0);

    final format = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;

    return InputImage.fromBytes(
      bytes: buffer.done().buffer.asUint8List(),
      metadata: InputImageMetadata(
        size: Size(
          image.width.toDouble(),
          image.height.toDouble(),
        ),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  InputImageRotation _rotation(int r) {
    switch (r) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> _toggleTorch() async {
    if (_cameraController == null) {
      return;
    }

    try {
      await _cameraController!.setFlashMode(
        _torchOn ? FlashMode.off : FlashMode.torch,
      );
      if (mounted) {
        setState(() {
          _torchOn = !_torchOn;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _laserController.dispose();
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          ScannerOverlay(laserAnimation: _laserController),

          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                _torchOn ? Icons.flash_on : Icons.flash_off,
                color: _torchOn ? Colors.amber : Colors.white,
              ),
              onPressed: _toggleTorch,
            ),
          ),

          const Positioned(
            bottom: 110,
            left: 20,
            right: 20,
            child: Text(
              'Hold phone so the barcode is horizontal.\nRotate phone if needed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),

          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: _callingApi
                  ? const Text(
                'Scanning...',
                style: TextStyle(color: Colors.white70),
              )
                  : (_lastCode != null
                  ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Recognized: $_lastCode',
                  style: const TextStyle(
                      color: Colors.white70),
                ),
              )
                  : const SizedBox.shrink()),
            ),
          ),
        ],
      ),
    );
  }
}

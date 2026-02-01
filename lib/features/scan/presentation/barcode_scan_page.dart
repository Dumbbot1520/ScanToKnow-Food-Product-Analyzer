import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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
  late final BarcodeScanner _barcodeScanner;
  bool _isProcessing = false;

  late AnimationController _laserController;

  @override
  void initState() {
    super.initState();

    _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
    _initCamera();

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    await _cameraController!.startImageStream(_processImage);

    if (mounted) setState(() {});
  }

  Future<void> _processImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _cameraImageToInputImage(image);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final code = barcodes.first.rawValue;
        if (code != null) {
          await _handleBarcode(code);
        }
      }
    } catch (_) {
      // ignore frame errors silently
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _handleBarcode(String barcode) async {
    await _cameraController?.stopImageStream();

    final res = await ApiService.get('/v1/scan/$barcode');

    if (!mounted) return;

    if (res is Map && res['data'] != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VariantDetailPage(variantId: res['data']['id']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product not found')),
      );
      await _cameraController?.startImageStream(_processImage);
    }
  }

  /// ✅ Correct ML Kit conversion
  InputImage _cameraImageToInputImage(CameraImage image) {
    final Uint8List bytes = image.planes.first.bytes;

    final rotation = Platform.isAndroid
        ? InputImageRotation.rotation0deg
        : InputImageRotation.rotation0deg;

    final format = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
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

          // 🔥 Scanner UI
          ScannerOverlay(laserAnimation: _laserController),

          // Close button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close,
                  color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              'Align barcode within the frame',
              textAlign: TextAlign.center,
              style:
              TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

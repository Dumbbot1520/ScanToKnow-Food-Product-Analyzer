// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
//
// class BarcodeScannerPage extends StatefulWidget {
//   const BarcodeScannerPage({super.key});
//
//   @override
//   State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
// }
//
// class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
//   String? scannedBarcode;
//   bool isScanning = true;
//   final MobileScannerController cameraController = MobileScannerController();
//
//   void resetScanner() {
//     setState(() {
//       scannedBarcode = null;
//       isScanning = true;
//     });
//   }
//
//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.orangeAccent,
//         title: const Text(
//           'Barcode Scanner',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.flash_on, color: Colors.white),
//             onPressed: () => cameraController.toggleTorch(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.cameraswitch, color: Colors.white),
//             onPressed: () => cameraController.switchCamera(),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Camera feed fills entire screen
//           MobileScanner(
//             controller: cameraController,
//             onDetect: (capture) {
//               if (!isScanning) return;
//
//               final barcode = capture.barcodes.first;
//               final code = barcode.rawValue;
//
//               if (code == null) return;
//
//               setState(() {
//                 scannedBarcode = code;
//                 isScanning = false;
//               });
//
//               debugPrint('Detected barcode: $code');
//             },
//           ),
//
//           // Center red scanning box
//           Center(
//             child: Container(
//               width: 250,
//               height: 150,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.redAccent, width: 3),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//             ),
//           ),
//
//           // ✅ Top overlay for scanned barcode + Scan Again
//           if (scannedBarcode != null)
//             SafeArea(
//               child: Align(
//                 alignment: Alignment.topCenter,
//                 child: Container(
//                   margin: const EdgeInsets.all(12),
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.7),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text(
//                         'Detected Barcode:\n$scannedBarcode',
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       ElevatedButton.icon(
//                         onPressed: resetScanner,
//                         icon: const Icon(Icons.refresh, color: Colors.white),
//                         label: const Text(
//                           'Scan Again',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orangeAccent,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 8),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:main_project_files/services/fetch_product_service.dart';
import 'package:main_project_files/pages/product_detail_page.dart';

class BarcodeScannerPage extends StatefulWidget {
  final Function(String barcode)? onDetect;

  const BarcodeScannerPage({super.key, this.onDetect});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  String? scannedBarcode;
  bool isScanning = true;
  bool isLoading = false;
  final MobileScannerController cameraController = MobileScannerController();

  void resetScanner() {
    setState(() {
      scannedBarcode = null;
      isScanning = true;
      isLoading = false;
    });
  }

  void handleBarcode(String code) async {
    if (!isScanning) return;

    setState(() {
      scannedBarcode = code;
      isScanning = false;
      isLoading = true;
    });

    print('📦 Detected barcode in scanner: $code');

    try {
      if (widget.onDetect != null) {
        print('⏳ Calling callback to fetch product...');
        await widget.onDetect!(code);
        print('✅ Callback finished');
      }

    } catch (e) {
      print('❌ Error in handleBarcode: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      resetScanner();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        title: const Text(
          'Barcode Scanner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.white),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!isScanning) return;
              final barcode = capture.barcodes.first;
              final code = barcode.rawValue;
              if (code != null) handleBarcode(code);
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.tealAccent.shade400, width: 3),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.teal.shade900.withOpacity(0.85),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      "Fetching product...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (scannedBarcode != null && !isLoading)
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade900.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Detected Barcode:\n$scannedBarcode',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: resetScanner,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: const Text(
                          'Scan Again',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

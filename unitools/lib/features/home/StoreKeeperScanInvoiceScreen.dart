import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'InvoiceDetailsScreen.dart';


class StoreKeeperScanInvoiceScreen extends StatefulWidget {
  const StoreKeeperScanInvoiceScreen({super.key});

  @override
  State<StoreKeeperScanInvoiceScreen> createState() =>
      _StoreKeeperScanInvoiceScreenState();
}

class _StoreKeeperScanInvoiceScreenState
    extends State<StoreKeeperScanInvoiceScreen> {
  bool _isProcessing = false;

  Future<void> handleScan(String scannedData) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final invoiceId = scannedData.trim();

    // 🔍 Check invoice exists
    try {
      final doc = await FirebaseFirestore.instance
          .collection('invoices')
          .doc(invoiceId)
          .get();

      if (doc.exists) {
        // ✔ Navigate to Invoice Details
        Get.to(() => InvoiceDetailsScreen(invoiceId: invoiceId));
      } else {
        Get.snackbar(
          "Invalid QR",
          "No invoice found for this QR code.",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Scan Error",
        "Something went wrong while scanning.",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Invoice QR"),
        backgroundColor: const Color(0xFF6A7FD0),
      ),
      body: Stack(
        children: [
          // 📸 CAMERA FEED
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;

              for (final barcode in barcodes) {
                final String? value = barcode.rawValue;
                if (value != null && !_isProcessing) {
                  handleScan(value);
                }
              }
            },
          ),

          // 🔲 Overlay box to guide scanning
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          // Processing overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

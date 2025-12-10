import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../controllers/Theme_Controller.dart';
import '../../core/app_theme.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      final scaffoldBg = isDark ? Colors.black : const Color(0xFFF1F3F6);
      final cardBg = isDark ? Colors.grey[900]! : Colors.white;
      final mainTextColor = isDark ? Colors.white : Colors.black87;
      final subTextColor = isDark ? Colors.grey[400]! : Colors.black54;
      final shadowColor = isDark
          ? Colors.black.withOpacity(0.7)
          : Colors.black12;

      return Scaffold(
        appBar: AppBar(
          title: const Text("Invoice Details"),
          backgroundColor:
          isDark ? Colors.black : const Color(0xFF6A7FD0),
          iconTheme: const IconThemeData(color: Colors.white),
          foregroundColor: Colors.white,
        ),
        backgroundColor: scaffoldBg,
        body: Container(
          decoration: isDark
              ? const BoxDecoration(color: Colors.black)
              : const BoxDecoration(gradient: AppTheme.background),
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('invoices')
                .doc(invoiceId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data =
              snapshot.data!.data() as Map<String, dynamic>?;

              if (data == null) {
                return Center(
                  child: Text(
                    "Invoice not found",
                    style: TextStyle(color: mainTextColor),
                  ),
                );
              }

              final items =
              List<Map<String, dynamic>>.from(data['items'] ?? []);
              final amount = (data['amount'] is num)
                  ? (data['amount'] as num).toDouble()
                  : 0.0;

              // 💡 Fix: your invoice uses `createdAt`, fallback to `timestamp` if needed
              final tsRaw = data['createdAt'] ?? data['timestamp'];
              String time;
              if (tsRaw is Timestamp) {
                time = tsRaw.toDate().toString(); // or use intl if you want prettier
              } else {
                time = "Unknown";
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // =======================
                    // HEADER CARD
                    // =======================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "INVOICE",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: mainTextColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Invoice ID: $invoiceId",
                            style: TextStyle(
                              fontSize: 14,
                              color: subTextColor,
                            ),
                          ),
                          Text(
                            "Date: $time",
                            style: TextStyle(
                              fontSize: 14,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =======================
                    // ITEM LIST
                    // =======================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Items",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: mainTextColor,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // ----- List of items -----
                          ...items.map((item) {
                            final imageUrl = item['imageUrl'] ?? '';
                            final name = item['name'] ?? 'Item';
                            final qty = item['quantity'] ?? 0;
                            final price = item['price'] ?? 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                      imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) =>
                                          Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                                Icons.image),
                                          ),
                                    )
                                        : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                          Icons.image),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: mainTextColor,
                                          ),
                                        ),
                                        Text(
                                          "Qty: $qty  •  $price OMR",
                                          style: TextStyle(
                                            color: subTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =======================
                    // TOTAL AMOUNT
                    // =======================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: mainTextColor,
                            ),
                          ),
                          Text(
                            "${amount.toStringAsFixed(3)} OMR",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }
}

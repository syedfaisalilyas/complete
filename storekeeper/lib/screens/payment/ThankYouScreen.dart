import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../controllers/Theme_Controller.dart';
import '../../core/app_theme.dart';
import '../../services/notification_service.dart';
import '../home/Home_Screen.dart';
import '../home/InvoiceDetailsScreen.dart';

class ThankYouScreen extends StatelessWidget {
  final String orderId;
  final String invoiceId;
  final double amount;

  const ThankYouScreen({
    super.key,
    required this.orderId,
    required this.invoiceId,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      final scaffoldBg = isDark ? Colors.black : const Color(0xFF6A7FD0);
      final cardBg = isDark ? Colors.grey[900]! : Colors.white;
      final mainTextColor = isDark ? Colors.white : Colors.black;
      final subTextColor = isDark ? Colors.grey[300]! : Colors.black54;
      final borderShadowColor = isDark
          ? Colors.black.withOpacity(0.6)
          : Colors.black12;

      return Scaffold(
        backgroundColor: scaffoldBg,
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: isDark
                ? const BoxDecoration(color: Colors.black)
                : const BoxDecoration(gradient: AppTheme.background),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Uni Tools app",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // WHITE / DARK BOX
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: borderShadowColor,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/payment/payment1.png',
                          height: 100,
                          color: isDark ? Colors.white : null,
                        ),
                        const SizedBox(height: 20),

                        Text(
                          "Thank you",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: mainTextColor,
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          "Your order has been placed successfully.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ==== INVOICE TEXT DETAILS ====
                        Text(
                          "Order ID: $orderId",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: mainTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Invoice No: $invoiceId",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: mainTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Amount Paid: ${amount.toStringAsFixed(2)} OMR",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: mainTextColor,
                          ),
                        ),

                        const SizedBox(height: 25),

                        Text(
                          "Scan to view invoice",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: mainTextColor,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white, // QR always on white for clarity
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: invoiceId, // QR contains invoice ID
                            version: QrVersions.auto,
                            size: 160,
                            backgroundColor: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==============================
                        //    VIEW INVOICE BUTTON
                        // ==============================
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() =>
                                  InvoiceDetailsScreen(invoiceId: invoiceId));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "View Invoice",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==============================
                        //            DONE BUTTON
                        // ==============================
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (user != null) {
                                await InAppNotificationService
                                    .sendNotification(
                                  userId: user.uid,
                                  title: "Payment Successful",
                                  message:
                                  "Your payment of ${amount.toStringAsFixed(2)} OMR is completed.",
                                  type: "payment",
                                );
                              }

                              Get.offAll(() => const HomeScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Done",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

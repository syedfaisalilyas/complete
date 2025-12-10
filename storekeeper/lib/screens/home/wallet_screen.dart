import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/Theme_Controller.dart';
import '../../core/app_styles.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      final bgColor = isDark ? Colors.black : const Color(0xFFF9FAFB);
      final textColor = isDark ? Colors.white : Colors.black;

      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: textColor),
            onPressed: () => Get.back(),
          ),
          title: Text(
            "My Wallet",
            style: AppStyles.medium1.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),

        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("userId", isEqualTo: uid)
              .snapshots(),
          builder: (context, purchaseSnap) {
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("borrow_requests")
                  .where("userId", isEqualTo: uid)
                  .snapshots(),
              builder: (context, borrowSnap) {
                if (!purchaseSnap.hasData || !borrowSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final purchases = purchaseSnap.data!.docs;
                final borrows = borrowSnap.data!.docs;

                double totalSpentPurchases = 0;
                double totalDeposits = 0;

                // ------- PURCHASES SPENT -------
                for (var doc in purchases) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data["status"] == "Confirmed") {
                    totalSpentPurchases += (data["totalAmount"] ?? 0).toDouble();
                  }
                }

                // ------- DEPOSITS SPENT -------
                for (var doc in borrows) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data["status"] == "Approved") {
                    totalDeposits += (data["deposit"] ?? 0).toDouble();
                  }
                }

                double walletTotal = totalSpentPurchases + totalDeposits;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===================== WALLET CARD =====================
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Total Spent",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14.sp,
                                )),
                            SizedBox(height: 6.h),
                            Text(
                              "OMR ${walletTotal.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),

                      // ===================== TRANSACTIONS =====================
                      Text(
                        "Transactions",
                        style: AppStyles.medium1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 15.h),

                      Column(
                        children: [
                          // ---- PURCHASE LIST ----
                          ...purchases.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            if (d["status"] != "Confirmed") return const SizedBox();

                            return _transactionTile(
                              title: "Purchase Order (${d["orderId"]})",
                              date: d["timestamp"].toDate().toString().substring(0, 16),
                              amount: "- ${d["totalAmount"]} OMR",
                              color: Colors.redAccent,
                              isDark: isDark,
                            );
                          }).toList(),

                          // ---- DEPOSIT LIST ----
                          ...borrows.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            if (d["status"] != "Approved") return const SizedBox();

                            return _transactionTile(
                              title: "Borrow Deposit (${d["itemName"]})",
                              date: d["createdAt"].toDate().toString().substring(0, 16),
                              amount: "- ${d["deposit"]} OMR",
                              color: Colors.red,
                              isDark: isDark,
                            );
                          }).toList(),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    });
  }

  // ======================= TRANSACTION TILE =======================
  Widget _transactionTile({
    required String title,
    required String date,
    required String amount,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black)),
              SizedBox(height: 4.h),
              Text(date,
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}

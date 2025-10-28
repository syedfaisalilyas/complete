import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../core/app_styles.dart';
import '../../core/app_theme.dart';
import '../home/home_screen.dart';
import '../../controllers/Theme_Controller.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  String formatPrice(dynamic value) {
    if (value == null) return "0.00";
    try {
      return (num.tryParse(value.toString()) ?? 0).toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final ThemeController themeController = Get.find();

    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      // Dark mode colors
      final scaffoldBg = isDark ? Colors.black : null;
      final containerBg = isDark ? Colors.grey[900] : Colors.white;
      final titleColor = isDark ? Colors.white : AppTheme.primaryColor;
      final textColor = isDark ? Colors.white : Colors.black;
      final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
      final blueText = Colors.blue;
      final greenText = Colors.green;
      final imageColor = isDark ? Colors.white : null;

      return WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: scaffoldBg,
          body: Container(
            width: 1.sw,
            height: 1.sh,
            decoration: isDark
                ? const BoxDecoration(color: Colors.black)
                : const BoxDecoration(gradient: AppTheme.background),
            child: SafeArea(
              child: Column(
                children: [
                  // ===== Top Title =====
                  Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: Text(
                      "app_title".tr,
                      style: AppStyles.large.copyWith(
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ===== Top Image =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Image.asset(
                      "assets/images/opening/opening.png",
                      height: 120.h,
                      fit: BoxFit.contain,
                      color: imageColor,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // ===== White / Dark Container with Orders =====
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: containerBg,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("orders")
                            .where("userId", isEqualTo: userId)
                            .orderBy("orderDate", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                "no_orders".tr,
                                style: TextStyle(color: textColor),
                              ),
                            );
                          }

                          final orders = snapshot.data!.docs;

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "order_summary".tr,
                                      style: AppStyles.medium1.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Image.asset(
                                      "assets/images/order/order.png",
                                      height: 35.h,
                                      width: 35.w,
                                      fit: BoxFit.contain,
                                      color: imageColor,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),

                                // ===== Orders List =====
                                ListView.builder(
                                  itemCount: orders.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final order = orders[index].data() as Map<String, dynamic>;
                                    final List<dynamic> items = order["items"] ?? [];

                                    String orderDate = "";
                                    if (order["orderDate"] != null) {
                                      if (order["orderDate"] is Timestamp) {
                                        DateTime dt = (order["orderDate"] as Timestamp).toDate();
                                        orderDate = DateFormat("dd-MM-yyyy HH:mm").format(dt);
                                      } else if (order["orderDate"] is String) {
                                        orderDate = order["orderDate"];
                                      }
                                    }

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 16.h),
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "products".tr,
                                            style: AppStyles.medium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),

                                          // ===== Items List =====
                                          ...items.map((item) {
                                            final bool isBorrow = item["borrowDate"] != null;
                                            String borrowDateStr = "";
                                            if (item["borrowDate"] != null) {
                                              if (item["borrowDate"] is Timestamp) {
                                                borrowDateStr = DateFormat("dd-MM-yyyy HH:mm")
                                                    .format((item["borrowDate"] as Timestamp).toDate());
                                              } else if (item["borrowDate"] is String) {
                                                borrowDateStr = item["borrowDate"];
                                              }
                                            }

                                            return Container(
                                              margin: EdgeInsets.only(bottom: 8.h),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "- ${item["name"] ?? "Product"} x${item["quantity"] ?? 1}",
                                                    style: AppStyles.small1.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  if (isBorrow)
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "(Borrowed Item)".tr,
                                                          style: TextStyle(
                                                            color: blueText,
                                                            fontSize: 12.sp,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        if (borrowDateStr.isNotEmpty)
                                                          Text(
                                                            "${"borrow_date".tr}: $borrowDateStr",
                                                            style: AppStyles.small1.copyWith(color: textColor),
                                                          ),
                                                        Text(
                                                          "${"duration".tr}: ${item["borrowDurationHours"] ?? 0}h ${item["borrowDurationMinutes"] ?? 0}m",
                                                          style: AppStyles.small1.copyWith(color: textColor),
                                                        ),
                                                        Text(
                                                          "${"calculated_price".tr}: ${formatPrice(item["calculatedPrice"])} OMR",
                                                          style: AppStyles.small1.copyWith(color: textColor),
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    Text(
                                                      "(Buy Item)".tr,
                                                      style: TextStyle(
                                                        color: greenText,
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          }).toList(),

                                          SizedBox(height: 8.h),

                                          Text(
                                            "${"order_id".tr}: ${order["orderId"]}",
                                            style: AppStyles.small1.copyWith(color: textColor),
                                          ),
                                          Text(
                                            "${"order_date".tr}: $orderDate",
                                            style: AppStyles.small1.copyWith(color: textColor),
                                          ),
                                          Text(
                                            "${"payment_method".tr}: ${order["cardNumber"]}",
                                            style: AppStyles.small1.copyWith(color: textColor),
                                          ),
                                          SizedBox(height: 6.h),

                                          Row(
                                            children: [
                                              Text(
                                                "${"order_confirmation".tr}: ",
                                                style: TextStyle(
                                                  color: blueText,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                "pending".tr,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 6.h),

                                          Text(
                                            "${"total_price".tr}: ${formatPrice(order["totalPrice"])} OMR",
                                            style: AppStyles.medium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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

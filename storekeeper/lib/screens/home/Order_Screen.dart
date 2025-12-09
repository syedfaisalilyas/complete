import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/Theme_Controller.dart';
import '../../core/app_styles.dart';
import '../../core/app_theme.dart';
import '../home/home_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  String formatPrice(dynamic value) {
    try {
      return (num.tryParse(value.toString()) ?? 0).toStringAsFixed(2);
    } catch (_) {
      return "0.00";
    }
  }

  // Safe image handler for URL + base64
  Widget buildSafeImage(String? img, {double size = 60}) {
    if (img == null || img.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.image, size: size * 0.6, color: Colors.grey.shade600),
      );
    }

    // BASE64 image
    if (img.startsWith("data:image")) {
      try {
        final base64Str = img.split(",").last;
        final bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child:
          Icon(Icons.image, size: size * 0.6, color: Colors.grey.shade600),
        );
      }
    }

    // Network image
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        img,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child:
          Icon(Icons.image, size: size * 0.6, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      final scaffoldBg = isDark ? Colors.black : null;
      final containerBg = isDark ? Colors.grey[900] : Colors.white;
      final titleColor = isDark ? Colors.white : AppTheme.primaryColor;
      final textColor = isDark ? Colors.white : Colors.black;
      final pillBg = isDark ? Colors.grey[850]! : Colors.grey[200]!;
      final imageTint = isDark ? Colors.white : null;

      return WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
          return false;
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: scaffoldBg,
            body: SafeArea(
              child: Container(
                decoration: isDark
                    ? const BoxDecoration(color: Colors.black)
                    : const BoxDecoration(gradient: AppTheme.background),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Title
                    Text(
                      "Orders",
                      style: AppStyles.large.copyWith(
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Top image
                    Image.asset(
                      "assets/images/order/order.png",
                      height: 90.h,
                      color: imageTint,
                    ),

                    SizedBox(height: 20.h),

                    // White / dark container
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
                        child: Column(
                          children: [
                            // Segmented TabBar (Borrow / Purchase)
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: pillBg,
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              child: TabBar(
                                labelStyle: AppStyles.small1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                unselectedLabelStyle: AppStyles.small1,
                                labelColor: Colors.black,
                                unselectedLabelColor:
                                textColor.withOpacity(0.7),
                                indicator: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(26.r),
                                ),
                                tabs: const [
                                  Tab(text: "Borrow Orders"),
                                  Tab(text: "Purchase Orders"),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Tab content
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _BorrowTab(
                                    userId: userId,
                                    textColor: textColor,
                                    isDark: isDark,
                                    cardImageBuilder: buildSafeImage,
                                  ),
                                  _PurchaseTab(
                                    userId: userId,
                                    textColor: textColor,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// ==============================
/// BORROW TAB
/// ==============================
class _BorrowTab extends StatelessWidget {
  final String userId;
  final Color textColor;
  final bool isDark;
  final Widget Function(String? img, {double size}) cardImageBuilder;

  const _BorrowTab({
    required this.userId,
    required this.textColor,
    required this.isDark,
    required this.cardImageBuilder,
  });

  String formatPrice(dynamic value) {
    try {
      return (num.tryParse(value.toString()) ?? 0).toStringAsFixed(2);
    } catch (_) {
      return "0.00";
    }
  }

  Color statusColor(String? status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? Colors.grey[850]! : Colors.white;
    final shadowColor =
    isDark ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.2);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("borrow_requests")
          .where("userId", isEqualTo: userId)
          .orderBy(FieldPath.documentId, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading borrow requests",
              style: TextStyle(color: textColor),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text(
              "No Borrow Orders yet",
              style: TextStyle(color: textColor),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.only(bottom: 8.h),
          itemCount: docs.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final status = data["status"] ?? "Pending";

            return GestureDetector(
              onTap: () {
                Get.to(
                      () => OrderDetailScreen(
                    data: data,
                    type: "borrow",
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cardImageBuilder(data["image"], size: 60),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["itemName"] ?? "Borrowed Item",
                            style: AppStyles.medium.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Borrow: ${data["borrowDate"] ?? "--"}",
                            style: AppStyles.small1.copyWith(
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            "Return: ${data["returnDate"] ?? "--"}",
                            style: AppStyles.small1.copyWith(
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor(status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  status,
                                  style: AppStyles.small1.copyWith(
                                    color: statusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                "${formatPrice(data["price"])} OMR",
                                style: AppStyles.medium.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ==============================
/// PURCHASE TAB
/// ==============================
class _PurchaseTab extends StatelessWidget {
  final String userId;
  final Color textColor;
  final bool isDark;

  const _PurchaseTab({
    required this.userId,
    required this.textColor,
    required this.isDark,
  });

  String formatPrice(dynamic value) {
    try {
      return (num.tryParse(value.toString()) ?? 0).toStringAsFixed(2);
    } catch (_) {
      return "0.00";
    }
  }

  Color statusColor(String? status) {
    switch (status) {
      case "Confirmed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? Colors.grey[850]! : Colors.white;
    final shadowColor =
    isDark ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.2);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("orders")
          .where("userId", isEqualTo: userId)
          .orderBy(FieldPath.documentId, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading orders",
              style: TextStyle(color: textColor),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Text(
              "No Purchase Orders yet",
              style: TextStyle(color: textColor),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.only(bottom: 8.h),
          itemCount: docs.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final snap = docs[index];
            final data = snap.data() as Map<String, dynamic>;
            final items = (data["items"] ?? []) as List;
            final status = data["status"] ?? "Pending";

            return GestureDetector(
              onTap: () {
                Get.to(
                      () => OrderDetailScreen(
                    data: data,
                    type: "buy",
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Order: ${data["orderId"] ?? snap.id}",
                            style: AppStyles.medium.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            status,
                            style: AppStyles.small1.copyWith(
                              color: statusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // Items
                    ...items.map((item) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Text(
                          "- ${item["name"]} x${item["quantity"]}",
                          style: AppStyles.small1.copyWith(
                            color: textColor.withOpacity(0.9),
                          ),
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 8.h),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: AppStyles.small1.copyWith(
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          "${formatPrice(data["totalAmount"])} OMR",
                          style: AppStyles.medium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ==============================
/// ORDER DETAIL SCREEN (Beautiful)
/// ==============================
class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String type; // "buy" or "borrow"

  const OrderDetailScreen({
    super.key,
    required this.data,
    required this.type,
  });

  String formatPrice(dynamic value) {
    try {
      return (num.tryParse(value.toString()) ?? 0).toStringAsFixed(2);
    } catch (_) {
      return "0.00";
    }
  }

  String formatDate(dynamic value) {
    if (value == null) return "--";
    try {
      if (value is Timestamp) {
        return DateFormat("dd MMM yyyy, hh:mm a").format(value.toDate());
      }
      return value.toString();
    } catch (_) {
      return value.toString();
    }
  }

  Color statusColor(String? status) {
    if (type == "borrow") {
      switch (status) {
        case "Approved":
          return Colors.green;
        case "Rejected":
          return Colors.red;
        default:
          return Colors.orange;
      }
    } else {
      switch (status) {
        case "Confirmed":
          return Colors.green;
        case "Cancelled":
          return Colors.red;
        default:
          return Colors.orange;
      }
    }
  }

  Widget buildSafeImage(String? img) {
    if (img == null || img.isEmpty) {
      return Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Icon(Icons.image, size: 80.sp, color: Colors.grey.shade600),
      );
    }

    if (img.startsWith("data:image")) {
      try {
        final base64Str = img.split(",").last;
        final bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Image.memory(
            bytes,
            height: 200.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        return Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Icon(Icons.image, size: 80.sp, color: Colors.grey.shade600),
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: Image.network(
        img,
        height: 200.h,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Icon(Icons.image, size: 80.sp, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBorrow = type == "borrow";
    final status = data["status"] ?? (isBorrow ? "Pending" : "Pending");
    final items = (data["items"] ?? []) as List;

    return Scaffold(
      appBar: AppBar(
        title: Text(isBorrow ? "Borrow Order Details" : "Purchase Details"),
        backgroundColor: const Color(0xFF6A7FD0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            if (isBorrow)
              buildSafeImage(data["image"])
            else if (items.isNotEmpty)
              buildSafeImage(items[0]["imageUrl"])
            else
              buildSafeImage(null),

            SizedBox(height: 16.h),

            // TITLE + STATUS CHIP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isBorrow
                        ? (data["itemName"] ?? "Borrowed Item")
                        : "Order #${data["orderId"] ?? ""}",
                    style: AppStyles.large
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status,
                    style: AppStyles.small1.copyWith(
                      color: statusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // INFO CARD
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBorrow) ...[
                    _infoRow("Borrow Date", data["borrowDate"]),
                    _infoRow("Return Date", data["returnDate"]),
                    _infoRow(
                        "Deposit", "${formatPrice(data["deposit"])} OMR"),
                    _infoRow("Price", "${formatPrice(data["price"])} OMR"),
                    _infoRow("Item ID", data["itemId"]),
                    _infoRow("User Email", data["userEmail"]),
                  ] else ...[
                    _infoRow("Order ID", data["orderId"]),
                    _infoRow(
                        "Total Amount",
                        "${formatPrice(data["totalAmount"])} OMR"),
                    _infoRow("Payment Method", data["paymentMethod"]),
                    _infoRow("Card Number", data["cardNumber"]),
                    _infoRow("Card Holder", data["cardName"]),
                    _infoRow(
                      "Created At",
                      formatDate(data["timestamp"]),
                    ),
                  ],
                ],
              ),
            ),

            if (!isBorrow) ...[
              SizedBox(height: 20.h),
              Text(
                "Items",
                style:
                AppStyles.medium1.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              ...items.map((item) {
                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["name"] ?? "Item",
                        style: AppStyles.medium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Qty: ${item["quantity"]}",
                        style: AppStyles.small1,
                      ),
                      Text(
                        "Category: ${item["category"]}",
                        style: AppStyles.small1,
                      ),
                      Text(
                        "Subcategory: ${item["subcategory"]}",
                        style: AppStyles.small1,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Price: ${formatPrice(item["price"])} OMR",
                        style: AppStyles.small1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppStyles.small1.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? "--",
              style: AppStyles.small1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

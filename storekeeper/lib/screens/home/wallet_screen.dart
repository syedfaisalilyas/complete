import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/Theme_Controller.dart';
import '../../core/app_styles.dart';
import '../../core/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Wallet Card =====
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6A11CB),
                      const Color(0xFF2575FC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Available Balance",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "OMR 245.75",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _walletButton(Icons.arrow_downward, "Add Funds"),
                        _walletButton(Icons.arrow_upward, "Withdraw"),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // ===== Recent Transactions Header =====
              Text(
                "Recent Transactions",
                style: AppStyles.medium1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 15.h),

              // ===== Dummy Transactions List =====
              Column(
                children: [
                  _transactionTile(
                    title: "Book Purchase",
                    date: "27 Oct 2025",
                    amount: "- 5.750 OMR",
                    color: Colors.redAccent,
                    isDark: isDark,
                  ),
                  _transactionTile(
                    title: "Added via Bank Transfer",
                    date: "25 Oct 2025",
                    amount: "+ 20.000 OMR",
                    color: Colors.green,
                    isDark: isDark,
                  ),
                  _transactionTile(
                    title: "Stationery Purchase",
                    date: "21 Oct 2025",
                    amount: "- 3.200 OMR",
                    color: Colors.redAccent,
                    isDark: isDark,
                  ),
                  _transactionTile(
                    title: "Top-up by Admin",
                    date: "20 Oct 2025",
                    amount: "+ 15.000 OMR",
                    color: Colors.green,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // ===== Wallet Action Buttons =====
  Widget _walletButton(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===== Transaction Item =====
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
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
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
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.sp,
                ),
              ),
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

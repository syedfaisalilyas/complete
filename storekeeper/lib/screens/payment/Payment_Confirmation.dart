import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/app_styles.dart';
import '../../core/app_theme.dart';
import '../home/home_screen.dart';

class PaymentConfirmation extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const PaymentConfirmation({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          width: 1.sw,
          height: 1.sh,
          decoration: const BoxDecoration(
            gradient: AppTheme.background,
          ),
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // ===== Top Title =====
                Text(
                  "app_title".tr,
                  textAlign: TextAlign.center,
                  style: AppStyles.large.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),

                SizedBox(height: 30.h),

                Image.asset(
                  "assets/images/signin/signin.png",
                  height: 120.h,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: 40.h),

                // ===== White Box Container =====
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/confirmation/confirm2.png",
                          height: 100.h,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 25.h),

                        Text(
                          "thank_you".tr,
                          style: AppStyles.large1.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        SizedBox(height: 10.h),

                        Text(
                          "order_success_msg".tr,
                          textAlign: TextAlign.center,
                          style: AppStyles.medium.copyWith(
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // ✅ Show Order Details
                        Text(
                          "${"order_id".tr}: ${orderData["orderId"]}",
                          style: AppStyles.medium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "${"total_price".tr}: ${orderData["totalPrice"]} OMR",
                          style: AppStyles.medium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "${"card_number".tr}: ${orderData["cardNumber"]}",
                          style: AppStyles.medium.copyWith(
                            color: Colors.white70,
                          ),
                        ),

                        SizedBox(height: 40.h),

                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.offAll(() => const HomeScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.button,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "home".tr,
                              style: AppStyles.medium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

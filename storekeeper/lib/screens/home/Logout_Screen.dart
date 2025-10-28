import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storekeeper/controllers/profile_controller.dart';
import 'package:storekeeper/screens/signIn/SignIn_Screen.dart';
import '../../core/app_theme.dart';
import '../../controllers/Theme_Controller.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (Get.isRegistered<ProfileController>()) {
        Get.delete<ProfileController>(force: true);
      }

      Get.offAll(() => const SignInScreen());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("logout_success".tr),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${"logout_failed".tr}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      final bgColor = isDark ? Colors.black : AppTheme.primaryColor;
      final textColor = isDark ? Colors.white : AppTheme.secondaryColor;
      final buttonTextColor = AppTheme.primaryColor;
      final buttonColor = AppTheme.button;
      final imageColor = isDark ? Colors.white : null;

      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ===== Top Title =====
              Padding(
                padding: EdgeInsets.only(top: 40.h),
                child: Text(
                  "app_title".tr,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              // ===== Center Image =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Image.asset(
                  "assets/images/opening/opening.png",
                  height: 300.h,
                  fit: BoxFit.contain,
                  color: imageColor,
                ),
              ),

              // ===== Bottom Logout Button =====
              Padding(
                padding: EdgeInsets.only(bottom: 40.h, left: 30.w, right: 30.w),
                child: SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () => _logout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      "logout".tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: buttonTextColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

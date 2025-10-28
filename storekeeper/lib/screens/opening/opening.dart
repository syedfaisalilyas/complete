import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:storekeeper/screens/signUp/SignUp_Screen.dart';
import '../../core/app_theme.dart';
import '../SignIn/SignIn_Screen.dart';

class OpeningScreen extends StatelessWidget {
  const OpeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1.sw,
        height: 1.sh,
        decoration: const BoxDecoration(
          gradient: AppTheme.background,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              /// ===== Main Content =====
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 70.h), // space under top buttons

                  // ===== Center Image =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Image.asset(
                      "assets/images/opening/opening.png",
                      height: 300.h,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // ===== Welcome Text =====
                  Text(
                    "Welcome to Uni Tools",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // ===== Bottom Buttons (original theme restored) =====
                  Padding(
                    padding:
                    EdgeInsets.only(bottom: 40.h, left: 30.w, right: 30.w),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => const SignUpScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.button,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15.h),
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => SignInScreen());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.button,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// ===== Top Floating Buttons =====
              Positioned(
                top: 20.h,
                left: 20.w,
                right: 20.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _topButton(
                      label: "Store keeper login",
                      onTap: () {
                        Get.to(() => SignInScreen());
                      },
                    ),
                    _topButton(
                      label: "Admin login",
                      onTap: () {
                        Get.to(() => SignInScreen());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== Small Top Black Buttons =====
  Widget _topButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_styles.dart';
import '../SignIn/SignIn_Screen.dart';

class ResetEmailDialogueBox extends StatefulWidget {
  const ResetEmailDialogueBox({super.key});

  @override
  State<ResetEmailDialogueBox> createState() => _ResetEmailDialogueBoxState();
}

class _ResetEmailDialogueBoxState extends State<ResetEmailDialogueBox> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Get.offAll(() => const SignInScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: AppTheme.background,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: AppTheme.button,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Tick Icon
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: AppTheme.button,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  size: 50.sp,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Reset password email has been sent. Click on the link from your email for password reset.",
                textAlign: TextAlign.center,
                style: AppStyles.medium.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}

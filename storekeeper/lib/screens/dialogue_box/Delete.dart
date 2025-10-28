import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/app_theme.dart';
import '../../core/app_styles.dart';
import '../opening/opening.dart';

class DeleteDialogueBox extends StatelessWidget {
  const DeleteDialogueBox({super.key});

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final uid = user.uid;

        // 🔴 Firestore data delete
        await FirebaseFirestore.instance.collection("users").doc(uid).delete();

        // 🔴 Firebase account delete
        await user.delete();

        // ✅ Success → Opening screen + green snackbar
        Get.offAll(() => const OpeningScreen());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // ❌ Failed → red snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account delete failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // blur background
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade100, // inner background
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppTheme.button, // yellow border from theme
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Are you sure you want to delete your account?",
                textAlign: TextAlign.center,
                style: AppStyles.medium.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),

              // ===== Buttons =====
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Delete Button
                  ElevatedButton(
                    onPressed: () => _deleteAccount(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.button,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      "Delete account",
                      style: AppStyles.small1.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 15.w),
                  // Cancel Button
                  ElevatedButton(
                    onPressed: () {
                      Get.back(); // close dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.button,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      "Cancel",
                      style: AppStyles.small1.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

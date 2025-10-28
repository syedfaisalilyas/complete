import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:storekeeper/screens/dialogue_box/Reset_pwd.dart';
import '../../core/app_styles.dart';
import '../../core/app_theme.dart';
import '../profile/Edit_Profile_Screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // ✅ Change password function
  Future<void> changePassword(
      String oldPassword, String newPassword, String confirmPassword) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (newPassword != confirmPassword) {
      Get.snackbar(
        "error".tr,
        "passwords_do_not_match".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (user == null || user.email == null) {
      Get.snackbar(
        "error".tr,
        "user_not_logged_in".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      await FirebaseFirestore.instance.collection("users").doc(user.uid).update({
        "password": newPassword,
      });

      Get.snackbar(
        "success".tr,
        "password_updated_success".tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const ResetPasswordDialogueBox(),
      );
    } on FirebaseAuthException catch (e) {
      String message = "error_fetching_data".tr;

      if (e.code == 'wrong-password') {
        message = "old_password_incorrect".tr;
      } else if (e.code == 'weak-password') {
        message = "new_password_weak".tr;
      } else if (e.code == 'requires-recent-login') {
        message = "recent_login_required".tr;
      }

      Get.snackbar(
        "error".tr,
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    Get.offAll(() => const EditProfileScreen());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: 1.sw,
          height: 1.sh,
          decoration: const BoxDecoration(gradient: AppTheme.background),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.offAll(() => const EditProfileScreen());
                            },
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: AppTheme.primaryColor,
                              size: 20.sp,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "change_password".tr,
                            style: AppStyles.medium1.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 1.sw,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r),
                            topRight: Radius.circular(30.r),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 50.h),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Please enter a new password below".tr,
                                    style: AppStyles.medium1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.secondaryColor,
                                    ),
                                  ),
                                  SizedBox(height: 30.h),
                                  TextFormField(
                                    controller: oldPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: "enter_old_password".tr,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.h),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "enter_old_password".tr;
                                      }
                                      if (value.length < 6) {
                                        return "old_password_invalid".tr;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                  TextFormField(
                                    controller: newPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: "enter_new_password".tr,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.h),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "enter_new_password".tr;
                                      }
                                      if (value.length < 6) {
                                        return "new_password_invalid".tr;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                  TextFormField(
                                    controller: confirmPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      hintText: "confirm_password".tr,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.h),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "confirm_password".tr;
                                      }
                                      if (value != newPasswordController.text) {
                                        return "passwords_do_not_match".tr;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 60.h),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50.h,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.button,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                      ),
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          changePassword(
                                            oldPasswordController.text.trim(),
                                            newPasswordController.text.trim(),
                                            confirmPasswordController.text.trim(),
                                          );
                                        }
                                      },
                                      child: Text(
                                        "reset".tr,
                                        style: AppStyles.medium.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 100.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    "assets/images/extra/e1.png",
                    height: 125.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storekeeper/screens/dialogue_box/Reset_Email.dart';
import '../../core/app_styles.dart';
import '../../core/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  Future<void> _resetPassword() async {
    try {
      final email = emailController.text.trim();

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // ✅ Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const ResetEmailDialogueBox(),
      );
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Something went wrong";

      if (e.code == "invalid-email") {
        errorMsg = "Invalid email format!";
      } else if (e.code == "user-not-found") {
        errorMsg = "No account found with this email!";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: 1.sw,
        height: 1.sh,
        decoration: const BoxDecoration(
          gradient: AppTheme.background,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Back Button + Title =====
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: AppTheme.primaryColor,
                            size: 20.sp,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "Forgot Password",
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

                  // ===== White Container with Rounded Top =====
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 50.h),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // ===== Forgot Image =====
                                Image.asset(
                                  "assets/images/forgotpwd/forgotpwd1.png",
                                  height: 120.h,
                                  fit: BoxFit.contain,
                                ),

                                SizedBox(height: 25.h),

                                // ===== Title Text =====
                                Text(
                                  "Forgot Password?",
                                  style: AppStyles.medium1.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                                SizedBox(height: 15.h),
                                Text(
                                  "No worries, we’ll send you reset instructions.",
                                  style: AppStyles.small1.copyWith(
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 30.h),

                                // ===== Email Label =====
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Enter your email to get a reset link",
                                    style: AppStyles.small1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.secondaryColor,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 12.h),

                                // ===== Email Input =====
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    hintText: "Enter your email",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 15.w,
                                      vertical: 16.h,
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter your email";
                                    }
                                    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$')
                                        .hasMatch(value)) {
                                      return "Enter a valid email";
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 30.h),

                                // ===== Reset Password Button =====
                                SizedBox(
                                  width: double.infinity,
                                  height: 50.h,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.button,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12.r),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        _resetPassword();
                                      }
                                    },
                                    child: Text(
                                      "Reset Password",
                                      style: AppStyles.medium.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 100.h), // space before bottom
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ===== Fixed Bottom Decorative Image =====
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
    );
  }
}

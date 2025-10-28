import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:storekeeper/screens/dialogue_box/Delete.dart';
import 'package:storekeeper/screens/home/Home_Screen.dart';
import 'package:storekeeper/screens/profile/Edit_Profile_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_theme.dart';
import '../../core/app_styles.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
        if (doc.exists) {
          setState(() {
            userData = doc.data();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "user_not_found".tr;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "user_not_logged_in".tr;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "error_fetching_data".tr;
        isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    Get.offAll(() => const HomeScreen());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
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
                // ===== Top Bar =====
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryColor),
                        onPressed: () {
                          Get.offAll(() => const HomeScreen());
                        },
                      ),
                      Expanded(
                        child: Text(
                          "app_title".tr,
                          style: AppStyles.large.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 40.w),
                    ],
                  ),
                ),

                // ===== Profile Avatar =====
                Column(
                  children: [
                    Image.asset(
                      "assets/images/profile/profile.png",
                      height: 90.h,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "${"hi".tr} ${userData?["studentName"] ?? "Student"}",
                      style: AppStyles.medium1.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // ===== White Container =====
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
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== Edit Profile Button =====
                            Align(
                              alignment: Alignment.topRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Get.to(() => const EditProfileScreen());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.button,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  "edit_profile".tr,
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5.h),

                            // ===== Student ID =====
                            _buildLabel("student_id".tr),
                            _buildReadOnlyField(userData?["studentId"] ?? ""),
                            SizedBox(height: 10.h),

                            // ===== Student Name =====
                            _buildLabel("student_name".tr),
                            _buildReadOnlyField(userData?["studentName"] ?? ""),
                            SizedBox(height: 10.h),

                            // ===== Email =====
                            _buildLabel("email".tr),
                            _buildReadOnlyField(userData?["email"] ?? ""),
                            SizedBox(height: 10.h),

                            // ===== Password =====
                            _buildLabel("password".tr),
                            _buildReadOnlyField("**************"),
                            SizedBox(height: 10.h),

                            // ===== Phone Number =====
                            _buildLabel("phone_number".tr),
                            _buildReadOnlyField(userData?["phone"] ?? ""),
                            SizedBox(height: 20.h),

                            // ===== Delete Account Button =====
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const DeleteDialogueBox(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.button,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  "delete_account".tr,
                                  style: AppStyles.medium.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== Helper for Labels =====
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppStyles.small1.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryColor,
      ),
    );
  }

  // ===== ReadOnly Fields =====
  Widget _buildReadOnlyField(String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 15.w,
          vertical: 13.h,
        ),
      ),
    );
  }
}

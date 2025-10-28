import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:storekeeper/screens/profile/Change_Password_Screen.dart';
import 'package:storekeeper/screens/profile/Profile_Screen.dart';
import '../../controllers/profile_controller.dart';
import '../../core/app_theme.dart';
import '../../core/app_styles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final ProfileController profileController;

  // flags for enabling/disabling fields
  bool isNameEditable = false;
  bool isPhoneEditable = false;

  // controllers
  TextEditingController? nameController;
  TextEditingController? phoneController;

  @override
  void initState() {
    super.initState();

    profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    nameController =
        TextEditingController(text: profileController.studentName.value);
    phoneController = TextEditingController(text: profileController.phone.value);

    // Reactive updates
    ever(profileController.studentName, (val) {
      if (nameController != null && nameController!.text != val) {
        nameController!.text = val;
      }
    });

    ever(profileController.phone, (val) {
      if (phoneController != null && phoneController!.text != val) {
        phoneController!.text = val;
      }
    });
  }

  @override
  void dispose() {
    nameController?.dispose();
    phoneController?.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    Get.offAll(() => const ProfileScreen());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          width: 1.sw,
          height: 1.sh,
          decoration: const BoxDecoration(gradient: AppTheme.background),
          child: SafeArea(
            child: Column(
              children: [
                // ===== Top Bar =====
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Get.offAll(() => const ProfileScreen()),
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
                    Obx(
                          () => Text(
                        "${"hi".tr} ${profileController.studentName.value}",
                        style: AppStyles.medium1.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),

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
                            // ===== Student ID =====
                            _buildLabel("student_id".tr),
                            Obx(() => _buildReadOnlyField(profileController.studentId.value)),
                            SizedBox(height: 14.h),

                            // ===== Student Name =====
                            _buildLabel("student_name".tr),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: nameController,
                                    enabled: isNameEditable,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15.w,
                                        vertical: 13.h,
                                      ),
                                    ),
                                    onChanged: (val) =>
                                    profileController.studentName.value = val,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isNameEditable = !isNameEditable;
                                    });
                                  },
                                  icon: Image.asset(
                                    "assets/images/profile/edit.png",
                                    height: 24.h,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),

                            // ===== Email =====
                            _buildLabel("email".tr),
                            Obx(() => _buildReadOnlyField(profileController.email.value)),
                            SizedBox(height: 14.h),

                            // ===== Password =====
                            _buildLabel("password".tr),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: "**************",
                                    readOnly: true,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15.w,
                                        vertical: 13.h,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                ElevatedButton(
                                  onPressed: () => Get.to(() => const ChangePasswordScreen()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.button,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    "change_password".tr,
                                    style: AppStyles.medium.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),

                            // ===== Phone Number =====
                            _buildLabel("phone_number".tr),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: phoneController,
                                    enabled: isPhoneEditable,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 15.w,
                                        vertical: 13.h,
                                      ),
                                    ),
                                    onChanged: (val) =>
                                    profileController.phone.value = val,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPhoneEditable = !isPhoneEditable;
                                    });
                                  },
                                  icon: Image.asset(
                                    "assets/images/profile/edit.png",
                                    height: 24.h,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 40.h),

                            // ===== Save Button =====
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await profileController.updateProfile(
                                    studentName: profileController.studentName.value,
                                    phone: profileController.phone.value,
                                  );

                                  Get.snackbar(
                                    "success".tr,
                                    "profile_updated".tr,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: const EdgeInsets.all(12),
                                    borderRadius: 8,
                                  );

                                  Get.offAll(() => const ProfileScreen());
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.button,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  "save".tr,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppStyles.small1.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return TextFormField(
      key: ValueKey(value),
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 13.h),
      ),
    );
  }
}

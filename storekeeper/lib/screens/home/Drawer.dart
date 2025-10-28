import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:storekeeper/screens/home/wallet_screen.dart';
import '../../controllers/Theme_Controller.dart';
import '../../core/app_styles.dart';
import '../profile/Profile_Screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Obx(() {
      final bgColor = themeController.isDarkMode.value ? Colors.black : const Color(0xFFCCE4EA);
      final textColor = themeController.isDarkMode.value ? Colors.white : Colors.black;
      final iconColor = themeController.isDarkMode.value ? Colors.white : Colors.black;

      return Drawer(
        width: 190.w,
        child: Container(
          color: bgColor,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),

                drawerButton(
                  iconPath: "assets/images/category/c1.png",
                  label: "communication".tr,
                  onTap: () { Get.back(); },
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                drawerButton(
                  iconPath: "assets/images/category/c2.png",
                  label: "student_profile".tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const ProfileScreen());
                  },
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                drawerButton(
                  iconPath: "assets/images/category/c3.png",
                  label: "wallet".tr,
                  onTap: () {
                    Get.back();
                    Get.to(() => const WalletScreen());
                  },
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                drawerButton(
                  iconPath: "assets/images/category/c4.png",
                  label: "notifications".tr,
                  onTap: () { Get.back(); },
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                drawerButton(
                  iconPath: "assets/images/category/c5.png",
                  label: "language".tr,
                  onTap: () {
                    Get.back();
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text('English'.tr),
                              onTap: () {
                                Get.updateLocale(const Locale('en', 'US'));
                                Get.forceAppUpdate();
                                Get.back();
                              },
                            ),
                            ListTile(
                              title: Text('Arabic'.tr),
                              onTap: () {
                                Get.updateLocale(const Locale('ar', 'AR'));
                                Get.forceAppUpdate(); // rebuild all .tr widgets
                                Get.back();
                              },
                            ),
                          ],
                        ),
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  textColor: textColor,
                  iconColor: iconColor,
                ),
                drawerButton(
                  iconPath: "assets/images/category/c6.png",
                  label: "mode_theme".tr,
                  onTap: () {
                    Get.back();
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: themeController.isDarkMode.value ? Colors.grey[900] : Colors.white,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(() {
                              return ListTile(
                                leading: Icon(Icons.dark_mode, color: iconColor),
                                title: Text('Dark', style: TextStyle(color: textColor)),
                                trailing: themeController.isDarkMode.value
                                    ? const Icon(Icons.check, color: Colors.blue)
                                    : null,
                                onTap: () {
                                  themeController.setDarkMode(true);
                                  Get.back();
                                },
                              );
                            }),
                            Obx(() {
                              return ListTile(
                                leading: Icon(Icons.light_mode, color: iconColor),
                                title: Text('Light', style: TextStyle(color: textColor)),
                                trailing: !themeController.isDarkMode.value
                                    ? const Icon(Icons.check, color: Colors.blue)
                                    : null,
                                onTap: () {
                                  themeController.setDarkMode(false);
                                  Get.back();
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  textColor: textColor,
                  iconColor: iconColor,
                ),

                drawerButton(
                  iconPath: "assets/images/category/c7.png",
                  label: "help".tr,
                  onTap: () { Get.back(); },
                  textColor: textColor,
                  iconColor: iconColor,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget drawerButton({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
    required Color textColor,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Image.asset(
        iconPath,
        width: 26.w,
        height: 26.h,
        color: iconColor, // icon color dynamically changes
      ),
      title: Text(
        label,
        style: AppStyles.small1.copyWith(
          fontWeight: FontWeight.w500,
          color: textColor, // text color dynamically changes
        ),
      ),
      onTap: onTap,
    );
  }
}
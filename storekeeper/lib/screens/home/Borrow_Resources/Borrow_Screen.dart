import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:storekeeper/screens/home/Home_Screen.dart';
import '../../../core/app_styles.dart';
import '../../../core/app_theme.dart';
import '../../../controllers/Theme_Controller.dart';
import '../Buy_Resources/product_list_screen.dart';

class BorrowScreen extends StatefulWidget {
  const BorrowScreen({super.key});

  @override
  State<BorrowScreen> createState() => _BorrowScreenState();
}

class _BorrowScreenState extends State<BorrowScreen> {
  final ThemeController themeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      final containerBg = isDark ? (Colors.grey[900]!) : AppTheme.primaryColor;
      final containerText = isDark ? Colors.white : AppTheme.secondaryColor;
      final titleColor = isDark ? Colors.white : AppTheme.primaryColor;
      final scaffoldBg = isDark ? Colors.black : null;

      return WillPopScope(
        onWillPop: () async {
          Get.offAll(() => const HomeScreen());
          return false;
        },
        child: Scaffold(
          backgroundColor: scaffoldBg,
          body: Container(
            width: 1.sw,
            height: 1.sh,
            decoration: isDark
                ? const BoxDecoration(color: Colors.black)
                : const BoxDecoration(gradient: AppTheme.background),
            child: SafeArea(
              child: Column(
                children: [
                  // ===== Back + Title =====
                  Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          "app_title".tr,
                          style: AppStyles.large.copyWith(
                            color: titleColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Get.offAll(() => const HomeScreen()),
                            child: Icon(Icons.arrow_back_ios,
                                color: titleColor, size: 20.sp),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== Image =====
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Image.asset(
                      "assets/images/signin/signin.png",
                      height: 100.h,
                      fit: BoxFit.contain,
                      color: isDark ? Colors.white : null,
                    ),
                  ),

                  // ===== Category Grid =====
                  Expanded(
                    child: Container(
                      width: 1.sw,
                      decoration: BoxDecoration(
                        color: isDark ? (Colors.grey[850]!) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "borrow_resource".tr,
                              style: AppStyles.medium1.copyWith(
                                color: containerText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 30.h),

                            Expanded(
                              child: GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16.w,
                                mainAxisSpacing: 16.h,
                                childAspectRatio: 1.55,
                                children: [
                                  // ✅ Pharmacy
                                  buildGridItem(
                                    "assets/images/buy/buy1.png",
                                    "Pharmacy".tr,
                                        () => Get.to(() => const ProductListScreen(
                                      category: "Borrow",
                                      subCategory: "Pharmacy",
                                    )),
                                    containerBg,
                                    containerText,
                                    isDark,
                                  ),

                                  // ✅ Engineering
                                  buildGridItem(
                                    "assets/images/buy/buy2.png",
                                    "Engineering".tr,
                                        () => Get.to(() => const ProductListScreen(
                                      category: "Borrow",
                                      subCategory: "Engineering",
                                    )),
                                    containerBg,
                                    containerText,
                                    isDark,
                                  ),

                                  // ✅ Fashion Design
                                  buildGridItem(
                                    "assets/images/buy/buy8.png",
                                    "Fashion Design".tr,
                                        () => Get.to(() => const ProductListScreen(
                                      category: "Borrow",
                                      subCategory: "Fashion Design",
                                    )),
                                    containerBg,
                                    containerText,
                                    isDark,
                                  ),

                                  // ✅ Information Technology
                                  buildGridItem(
                                    "assets/images/buy/buy7.png",
                                    "Information Technology".tr,
                                        () => Get.to(() => const ProductListScreen(
                                      category: "Borrow",
                                      subCategory: "Information Technology",
                                    )),
                                    containerBg,
                                    containerText,
                                    isDark,
                                  ),

                                  // ✅ Business Studies
                                  buildGridItem(
                                    "assets/images/buy/buy3.png",
                                    "Business Studies".tr,
                                        () => Get.to(() => const ProductListScreen(
                                      category: "Borrow",
                                      subCategory: "Business Studies",
                                    )),
                                    containerBg,
                                    containerText,
                                    isDark,
                                  ),

                                  // ✅ Applied Sciences
                                  buildGridItem(
                                    "assets/images/buy/buy6.png",
                                    "Applied Sciences".tr,
                                        () => Get.to(() => const ProductListScreen(
                                      category: "Borrow",
                                      subCategory: "Applied Sciences",
                                    )),
                                    containerBg,
                                    containerText,
                                    isDark,
                                  ),

                                  // ✅ Photography
                                  buildGridItem(
                                    "assets/images/buy/buy5.png",
                                    "Photography".tr,
                                        () => Get.to(() => const ProductListScreen(
                                      category: "Borrow",
                                      subCategory: "Photography",
                                    )),
                                    containerBg,
                                    containerText,
                                    isDark,
                                  ),

                                  // ✅ English Language
                                  buildGridItem(
                                    "assets/images/buy/buy4.png",
                                    "English Language".tr,
                                        () => Get.to(() => const ProductListScreen(
                                      category: "Borrow",
                                      subCategory: "English Language",
                                    )),
                                    containerBg,
                                    containerText,
                                    isDark,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    });
  }

  // ✅ Grid Item Widget
  Widget buildGridItem(
      String imagePath,
      String title,
      VoidCallback onTap,
      Color containerBg,
      Color containerText,
      bool isDark,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(16.r),
          color: containerBg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 60.h,
              color: isDark ? Colors.white : null,
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppStyles.small1.copyWith(
                color: containerText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

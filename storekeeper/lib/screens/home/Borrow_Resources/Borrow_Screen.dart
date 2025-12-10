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
  final TextEditingController _searchController = TextEditingController();

  /// Static subcategories for BORROW
  /// key  = translation key (borrow_pharmacy, borrow_engineering, ...)
  /// name = internal English name used in Firestore / ProductListScreen
  final List<Map<String, String>> _categories = const [
    {
      "key": "borrow_pharmacy",
      "name": "Pharmacy",
      "image": "assets/images/buy/buy1.png",
    },
    {
      "key": "borrow_engineering",
      "name": "Engineering",
      "image": "assets/images/buy/buy2.png",
    },
    {
      "key": "borrow_fashion_design",
      "name": "Fashion Design",
      "image": "assets/images/buy/buy8.png",
    },
    {
      "key": "borrow_information_technology",
      "name": "Information Technology",
      "image": "assets/images/buy/buy7.png",
    },
    {
      "key": "borrow_business_studies",
      "name": "Business Studies",
      "image": "assets/images/buy/buy3.png",
    },
    {
      "key": "borrow_applied_sciences",
      "name": "Applied Sciences",
      "image": "assets/images/buy/buy6.png",
    },
    {
      "key": "borrow_photography",
      "name": "Photography",
      "image": "assets/images/buy/buy5.png",
    },
    {
      "key": "borrow_english_language",
      "name": "English Language",
      "image": "assets/images/buy/buy4.png",
    },
  ];

  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filtered {
    if (_searchQuery.trim().isEmpty) return _categories;

    final q = _searchQuery.toLowerCase();

    return _categories.where((c) {
      final key = c["key"] ?? "";
      final internalName = c["name"] ?? "";

      final en = internalName.toLowerCase();   // English
      final translated = key.tr.toLowerCase(); // Arabic/English (current locale)

      return en.contains(q) || translated.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      final containerBg = isDark ? Colors.grey[900]! : AppTheme.primaryColor;
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
                            onTap: () =>
                                Get.offAll(() => const HomeScreen()),
                            child: Icon(Icons.arrow_back_ios,
                                color: titleColor, size: 20.sp),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== Search Bar =====
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: "search_category_hint".tr,
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey,
                        ),
                        prefixIcon:
                        const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: isDark ? Colors.grey[800] : Colors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey : Colors.black12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ===== Top Image (brand) =====
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Image.asset(
                      "assets/images/signin/signin.png",
                      height: 90.h,
                      fit: BoxFit.contain,
                      color: isDark ? Colors.white : null,
                    ),
                  ),

                  // ===== Category Grid =====
                  Expanded(
                    child: Container(
                      width: 1.sw,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850]! : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15.w),
                        child: _filtered.isEmpty
                            ? Center(
                          child: Text(
                            "no_matching_categories".tr,
                            style: AppStyles.small1.copyWith(
                              color: isDark
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                          ),
                        )
                            : GridView.builder(
                          itemCount: _filtered.length,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.55,
                          ),
                          itemBuilder: (context, index) {
                            final item = _filtered[index];
                            final titleKey = item["key"]!;
                            final internalName = item["name"]!;
                            final imagePath = item["image"]!;

                            return _gridItem(
                              imagePath: imagePath,
                              // what user sees (translated)
                              title: titleKey.tr,
                              internalName: internalName,
                              onTap: () => Get.to(
                                    () => ProductListScreen(
                                  category: "Borrow",
                                  subCategory: internalName,
                                ),
                              ),
                              containerBg: containerBg,
                              containerText: containerText,
                              isDark: isDark,
                            );
                          },
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

  Widget _gridItem({
    required String imagePath,
    required String title,        // translated label
    required String internalName, // kept if you need it later
    required VoidCallback onTap,
    required Color containerBg,
    required Color containerText,
    required bool isDark,
  }) {
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

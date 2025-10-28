import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:storekeeper/screens/home/Borrow_Resources/Borrow_Screen.dart';
import 'package:storekeeper/screens/home/Buy_Resources/Buy_Screen.dart';
import 'package:storekeeper/screens/home/Cart_Screen.dart';
import 'package:storekeeper/screens/home/Drawer.dart';
import 'package:storekeeper/screens/home/Logout_Screen.dart';
import 'package:storekeeper/screens/home/Order_Screen.dart';
import '../../core/app_styles.dart';
import '../../core/app_theme.dart';
import '../../controllers/Theme_Controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final ThemeController themeController = Get.find();

  final List<Widget> screens = [
    const HomeContent(),
    const CartScreen(),
    const OrderScreen(),
    const LogoutScreen(),
  ];

  void onItemTapped(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;
      return Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: const CustomDrawer(),
        body: screens[selectedIndex],
        bottomNavigationBar: Padding(
          padding:
          const EdgeInsets.only(bottom: 16.0, left: 15.0, right: 15.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Container(
              height: 60.h,
              decoration: BoxDecoration(
                gradient: isDark ? null : AppTheme.background,
                color: isDark ? Colors.grey[900] : null,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  navItem(Icons.home, "home".tr, 0, isDark),
                  navItem(Icons.shopping_cart, "cart".tr, 1, isDark),
                  navItem(Icons.receipt_long, "order".tr, 2, isDark),
                  navItem(Icons.logout, "logout".tr, 3, isDark),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget navItem(IconData icon, String label, int index, bool isDark) {
    bool isSelected = selectedIndex == index;
    final iconColor = isDark ? Colors.white : AppTheme.primaryColor;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: isSelected
            ? BoxDecoration(
          color: iconColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(50),
        )
            : null,
        child: Row(
          children: [
            Icon(icon, size: 26.sp, color: iconColor),
            if (isSelected) ...[
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(fontSize: 11.sp, color: iconColor),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ThemeController themeController = Get.find();

  String searchQuery = '';

  void _hideKeyboard() {
    if (_focusNode.hasFocus) _focusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      final containerBg = isDark ? Colors.grey[850] : AppTheme.primaryColor;
      final containerText = isDark ? Colors.white : AppTheme.secondaryColor;
      final searchBg = isDark ? Colors.grey[800] : AppTheme.primaryColor;
      final hintTextColor = isDark ? Colors.grey[400] : Colors.grey;

      // filter logic
      final buyTitle = "buy_resource".tr;
      final borrowTitle = "borrow_resource".tr;

      final showBuy = buyTitle.toLowerCase().contains(searchQuery.toLowerCase()) ||
          searchQuery.isEmpty;
      final showBorrow =
          borrowTitle.toLowerCase().contains(searchQuery.toLowerCase()) ||
              searchQuery.isEmpty;

      return Container(
        width: 1.sw,
        height: 1.sh,
        decoration: isDark
            ? const BoxDecoration(color: Colors.black)
            : const BoxDecoration(gradient: AppTheme.background),
        child: SafeArea(
          child: Column(
            children: [
              // Top Row
              Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.menu,
                            color:
                            isDark ? Colors.white : AppTheme.primaryColor),
                        onPressed: () {
                          _hideKeyboard();
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "app_title".tr,
                      style: AppStyles.large.copyWith(
                        color: isDark
                            ? Colors.white
                            : AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),

              // Top Image
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Image.asset(
                  "assets/images/signin/signin.png",
                  height: 100.h,
                  fit: BoxFit.contain,
                  color: isDark ? Colors.white : null,
                ),
              ),

              // Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: "search_hint".tr,
                    hintStyle:
                    TextStyle(fontSize: 14.sp, color: hintTextColor),
                    filled: true,
                    fillColor: searchBg,
                    prefixIcon:
                    const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onChanged: (v) => setState(() => searchQuery = v),
                  onSubmitted: (_) => _hideKeyboard(),
                  onTapOutside: (_) => _hideKeyboard(),
                ),
              ),

              SizedBox(height: 30.h),

              // White container with buttons (unchanged)
              Expanded(
                child: Container(
                  width: 1.sw,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            if (showBuy)
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => const BuyScreen());
                                },
                                child: Container(
                                  width: 140.w,
                                  height: 180.h,
                                  padding: EdgeInsets.all(15.w),
                                  decoration: BoxDecoration(
                                    border:
                                    Border.all(color: Colors.blue),
                                    borderRadius:
                                    BorderRadius.circular(16.r),
                                    color: containerBg,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/images/home/buy.png",
                                          height: 60.h,
                                          color: isDark
                                              ? Colors.white
                                              : null,
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          "buy_resource".tr,
                                          textAlign: TextAlign.center,
                                          style: AppStyles.small1
                                              .copyWith(
                                            color: containerText,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (showBorrow)
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => const BorrowScreen());
                                },
                                child: Container(
                                  width: 140.w,
                                  height: 180.h,
                                  padding: EdgeInsets.all(15.w),
                                  decoration: BoxDecoration(
                                    border:
                                    Border.all(color: Colors.blue),
                                    borderRadius:
                                    BorderRadius.circular(16.r),
                                    color: containerBg,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/images/home/borrow.png",
                                          height: 60.h,
                                          color: isDark
                                              ? Colors.white
                                              : null,
                                        ),
                                        SizedBox(height: 10.h),
                                        Text(
                                          "borrow_resource".tr,
                                          textAlign: TextAlign.center,
                                          style: AppStyles.small1
                                              .copyWith(
                                            color: containerText,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

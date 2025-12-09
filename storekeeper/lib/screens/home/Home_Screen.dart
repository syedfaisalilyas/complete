import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../../services/tracking_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final ThemeController themeController = Get.find();

  final List<Widget> screens = const [
    HomeContent(),
    CartScreen(),
    OrderScreen(),
    LogoutScreen(),
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
    final bool isSelected = selectedIndex == index;
    final Color iconColor = isDark ? Colors.white : AppTheme.primaryColor;

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
            ],
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
      final bool isDark = themeController.isDarkMode.value;

      final containerBg = isDark ? Colors.grey[850] : AppTheme.primaryColor;
      final containerText = isDark ? Colors.white : AppTheme.secondaryColor;
      final searchBg = isDark ? Colors.grey[800] : AppTheme.primaryColor;
      final hintTextColor = isDark ? Colors.grey[400] : Colors.grey;

      // filter logic for Buy / Borrow boxes
      final buyTitle = "buy_resource".tr;
      final borrowTitle = "borrow_resource".tr;

      final showBuy =
          buyTitle.toLowerCase().contains(searchQuery.toLowerCase()) ||
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
              // ---------- Top Row ----------
              Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: Icon(
                          Icons.menu,
                          color:
                          isDark ? Colors.white : AppTheme.primaryColor,
                        ),
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
                        color:
                        isDark ? Colors.white : AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(flex: 2),
                  ],
                ),
              ),

              // ---------- Top Image ----------
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Image.asset(
                  "assets/images/signin/signin.png",
                  height: 100.h,
                  fit: BoxFit.contain,
                  color: isDark ? Colors.white : null,
                ),
              ),

              // ---------- Search Bar ----------
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
                  onChanged: (v) {
                    setState(() => searchQuery = v);
                    TrackingService.trackSearch(v);
                  },
                  onSubmitted: (_) => _hideKeyboard(),
                  onTapOutside: (_) => _hideKeyboard(),
                ),
              ),

              SizedBox(height: 30.h),

              // ---------- White Container (scrollable content: buy/borrow + recommendations) ----------
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BUY / BORROW BUTTONS
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            if (showBuy)
                              _homeButton(
                                title: "buy_resource".tr,
                                image: "assets/images/home/buy.png",
                                isDark: isDark,
                                bgColor: containerBg,
                                textColor: containerText,
                                onTap: () {
                                  Get.to(() => const BuyScreen());
                                },
                              ),
                            if (showBorrow)
                              _homeButton(
                                title: "borrow_resource".tr,
                                image: "assets/images/home/borrow.png",
                                isDark: isDark,
                                bgColor: containerBg,
                                textColor: containerText,
                                onTap: () {
                                  Get.to(() => const BorrowScreen());
                                },
                              ),
                          ],
                        ),

                        SizedBox(height: 25.h),

                        // RECOMMENDATION SECTION
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: getUserRecommendations(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const SizedBox();
                            }

                            final items = snapshot.data!;

                            return Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Recommended for You",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                SizedBox(
                                  height: 200.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final item = items[index];

                                      return GestureDetector(
                                        onTap: () {
                                          TrackingService
                                              .trackUserActivity(
                                            productId: item["id"] ??
                                                item["name"],
                                            category:
                                            item["category"] ?? "",
                                            name: item["name"] ?? "",
                                            viewed: true,
                                          );

                                          Get.toNamed(
                                            "/productDetail",
                                            arguments: item,  // NOW VALID WITH ID
                                          );
                                        },
                                        child:
                                        _recommendedCard(item),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],
                            );
                          },
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

  // ---------- Helper: main home buttons ----------
  Widget _homeButton({
    required String title,
    required String image,
    required bool isDark,
    required Color? bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140.w,
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(16.r),
          color: bgColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: 60.h,
              color: isDark ? Colors.white : null,
            ),
            SizedBox(height: 10.h),

            // FIX: limit title to 1-line or wrap without overflow
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.small1.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ---------- Helper: recommended item card ----------
  Widget _recommendedCard(Map<String, dynamic> item) {
    final imageUrl = (item["image"] ?? "").toString();

    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Image.network(
            imageUrl,
            height: 60.h,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 60),
          ),
          const SizedBox(height: 8),
          Text(
            item["name"] ?? "No Name",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${item['price']} OMR",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// RECOMMENDATIONS HELPER
// =========================
Future<List<Map<String, dynamic>>> getUserRecommendations() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final activityRef = FirebaseFirestore.instance
      .collection("users")
      .doc(user.uid)
      .collection("activity");

  final snapshot = await activityRef.get();
  if (snapshot.docs.isEmpty) return [];

  Map<String, int> categoryScore = {};

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final category = data["category"] ?? "";

    if (category.isEmpty) continue;

    int score = 0;
    if (data["viewed"] == true) score += 1;
    if (data["addedToCart"] == true) score += 3;
    if (data["rated"] == true) score += 5;
    if (data["purchased"] == true) score += 10;

    categoryScore[category] = (categoryScore[category] ?? 0) + score;
  }

  if (categoryScore.isEmpty) return [];

  final topCategory = categoryScore.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;

  final productSnap = await FirebaseFirestore.instance
      .collection("products")
      .where("category", isEqualTo: topCategory)
      .limit(6)
      .get();

  return productSnap.docs.map((doc) {
    return {
      "id": doc.id,
      ...doc.data(),
    };
  }).toList();
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:storekeeper/screens/home/Borrow_Resources/Borrow_Product_Details_Screen.dart';
import 'package:storekeeper/screens/home/Borrow_Resources/Borrow_Screen.dart';
import '../../../core/app_styles.dart';
import '../../../core/app_theme.dart';

class BorrowITProductsScreen extends StatefulWidget {
  const BorrowITProductsScreen({super.key});

  @override
  State<BorrowITProductsScreen> createState() => _BorrowITProductsScreenState();
}

class _BorrowITProductsScreenState extends State<BorrowITProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
    "https://uni-tool-app-default-rtdb.asia-southeast1.firebasedatabase.app/",
  ).ref("borrowProducts");

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

  Future<bool> _onWillPop() async {
    Get.offAll(() => const BorrowScreen());
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
          decoration: const BoxDecoration(
            gradient: AppTheme.background,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ===== Top Bar =====
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Get.offAll(() => const BorrowScreen()),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: AppTheme.primaryColor,
                            size: 20.sp,
                          ),
                        ),
                      ),
                      Text(
                        "borrow_it_resources".tr,
                        style: AppStyles.large.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== Search Bar =====
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: "search_borrow_hint".tr,
                      hintStyle: TextStyle(fontSize: 14.sp),
                      filled: true,
                      fillColor: AppTheme.primaryColor,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _hideKeyboard(),
                    onTapOutside: (_) => _hideKeyboard(),
                  ),
                ),

                SizedBox(height: 20.h),

                // ===== Product List =====
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
                    child: StreamBuilder(
                      stream: _dbRef.onValue,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("${"error".tr}: ${snapshot.error}"));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                          return Center(child: Text("no_borrow_products".tr));
                        }

                        final data = (snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
                        final products = data.entries.toList();

                        return ListView.builder(
                          padding: EdgeInsets.all(15.w),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index].value;
                            final id = products[index].key;
                            return buildProductItem(
                              product["imageUrl"],
                              product["name"],
                              product["price"],
                              id,
                            );
                          },
                        );
                      },
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

  // ===== Product Item Widget =====
  Widget buildProductItem(String image, String name, String price, String id) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.green.shade600),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image
          Image.network(image, height: 60.h, width: 60.w, fit: BoxFit.contain),

          SizedBox(width: 20.w),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppStyles.medium.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  "${"borrow_price".tr}: $price",
                  style: AppStyles.small1.copyWith(
                    color: AppTheme.secondaryColor,
                  ),
                ),
                SizedBox(height: 8.h),

                // Borrow Now Button
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => BorrowProductDetailScreen(productId: id));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.button,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                  ),
                  child: Text(
                    "borrow_now".tr,
                    style: AppStyles.small1.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

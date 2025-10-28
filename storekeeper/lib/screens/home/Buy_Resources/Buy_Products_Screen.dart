import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:storekeeper/screens/home/Buy_Resources/Buy_Screen.dart';
import 'package:storekeeper/screens/home/Buy_Resources/Product_Detail_Screen.dart';
import '../../../core/app_styles.dart';
import '../../../core/app_theme.dart';

class ITProductScreen extends StatefulWidget {
  const ITProductScreen({super.key});

  @override
  State<ITProductScreen> createState() => _ITProductScreenState();
}

class _ITProductScreenState extends State<ITProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final DatabaseReference _dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
    "https://uni-tool-app-default-rtdb.asia-southeast1.firebasedatabase.app/",
  ).ref("products");

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];

  void _hideKeyboard() => FocusScope.of(context).unfocus();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    _dbRef.onValue.listen((event) {
      if (event.snapshot.value == null) {
        setState(() {
          allProducts = [];
          filteredProducts = [];
        });
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final products = data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value);
        val['id'] = e.key;
        return val;
      }).toList();

      setState(() {
        allProducts = products;
        filteredProducts = products;
      });
    });
  }

  void _filterProducts() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() => filteredProducts = allProducts);
      return;
    }

    setState(() {
      filteredProducts = allProducts.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        final type = (product['type'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            type.contains(query) ||
            (query.contains('buy') && name.contains('buy')) ||
            (query.contains('borrow') && name.contains('borrow'));
      }).toList();
    });
  }

  Future<bool> _onWillPop() async {
    Get.offAll(() => const BuyScreen());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: GestureDetector(
              onTap: _hideKeyboard,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppTheme.background,
                ),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ===== Top Bar =====
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.w, vertical: 15.h),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: GestureDetector(
                                          onTap: () =>
                                              Get.offAll(() => const BuyScreen()),
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            color: AppTheme.primaryColor,
                                            size: 22.sp,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "information_technology".tr,
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20.w, vertical: 10.h),
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _focusNode,
                                    decoration: InputDecoration(
                                      hintText:
                                      "Search Buy or Borrow resources...",
                                      hintStyle: TextStyle(fontSize: 14.sp),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: const Icon(Icons.search,
                                          color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(32.r),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    textInputAction: TextInputAction.search,
                                  ),
                                ),

                                // ===== Product Grid =====
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.w, vertical: 10.h),
                                  child: filteredProducts.isEmpty
                                      ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 50.h),
                                      child: Text(
                                        "No matching products found.",
                                        style: AppStyles.medium.copyWith(
                                            color:
                                            AppTheme.secondaryColor),
                                      ),
                                    ),
                                  )
                                      : LayoutBuilder(
                                    builder: (context, constraints) {
                                      int crossAxisCount = 2;
                                      double aspect = 0.8;
                                      if (constraints.maxWidth > 1200) {
                                        crossAxisCount = 4;
                                        aspect = 1.2;
                                      } else if (constraints.maxWidth >
                                          700) {
                                        crossAxisCount = 3;
                                        aspect = 1;
                                      }

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                        const NeverScrollableScrollPhysics(),
                                        itemCount:
                                        filteredProducts.length,
                                        gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 15.w,
                                          mainAxisSpacing: 15.h,
                                          childAspectRatio: aspect,
                                        ),
                                        itemBuilder: (context, index) {
                                          final product =
                                          filteredProducts[index];
                                          return buildProductCard(
                                            product["imageUrl"] ?? "",
                                            product["name"] ??
                                                "Unnamed",
                                            product["price"] ?? "N/A",
                                            product["id"] ?? "",
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ===== Product Card =====
  Widget buildProductCard(
      String image, String name, String price, String id) {
    return InkWell(
      onTap: () => Get.to(() => ITProductDetail(productId: id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
          border: Border.all(color: Colors.blue.shade600),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    image,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (context, _, __) =>
                    const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppStyles.medium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "${"price".tr}: $price",
                      style: AppStyles.small1.copyWith(
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    SizedBox(
                      height: 32.h,
                      child: ElevatedButton(
                        onPressed: () =>
                            Get.to(() => ITProductDetail(productId: id)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.button,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: FittedBox(
                          child: Text(
                            "shop_now".tr,
                            style: AppStyles.small1.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

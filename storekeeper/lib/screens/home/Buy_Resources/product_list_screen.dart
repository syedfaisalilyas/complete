import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_theme.dart';
import '../../../controllers/Theme_Controller.dart';
import '../Borrow_Resources/BorrowApplyScreen.dart';
import '../Buy_Resources/product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String category;
  final String subCategory;

  const ProductListScreen({
    super.key,
    required this.category,
    required this.subCategory,
  });

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      final query = FirebaseFirestore.instance.collection('products');

      final scaffoldBg = isDark ? Colors.black : null;
      final topDecoration = isDark
          ? const BoxDecoration(color: Colors.black)
          : const BoxDecoration(gradient: AppTheme.background);

      final listBg = isDark ? Colors.grey[900]! : Colors.white;
      final cardBg = isDark ? Colors.grey[850]! : Colors.white;
      final mainTextColor = isDark ? Colors.white : Colors.black87;
      final subTextColor = isDark ? Colors.grey[400]! : Colors.black54;
      final searchFill = isDark ? Colors.grey[800]! : Colors.white;

      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Container(
          decoration: topDecoration,
          child: SafeArea(
            child: Column(
              children: [
                // ------------------ HEADER ---------------------
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child:
                        const Icon(Icons.arrow_back_ios, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.subCategory,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ------------------ SEARCH ---------------------
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Search resources...",
                      hintStyle: TextStyle(
                          color:
                          isDark ? Colors.grey[400] : Colors.grey[600]),
                      filled: true,
                      fillColor: searchFill,
                      prefixIcon: Icon(Icons.search,
                          color: isDark ? Colors.white70 : Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // ------------------ LIST ---------------------
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: listBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: query.snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "No products found",
                              style: TextStyle(color: subTextColor),
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs.where((doc) {
                          final data =
                          doc.data() as Map<String, dynamic>;

                          final String? singleCategory =
                          (data['category'] ?? data['Category'])
                          as String?;
                          final String? singleSubCategory =
                          (data['subcategory'] ?? data['Subcategory'])
                          as String?;

                          final List<String> categoryList =
                          (data['categories'] is List)
                              ? List<String>.from(
                              data['categories'])
                              : <String>[];

                          final List<String> subCategoryList =
                          (data['subcategories'] is List)
                              ? List<String>.from(
                              data['subcategories'])
                              : <String>[];

                          final bool matchCategory =
                              singleCategory == widget.category ||
                                  categoryList
                                      .contains(widget.category);

                          final bool matchSubCategory =
                              singleSubCategory == widget.subCategory ||
                                  subCategoryList
                                      .contains(widget.subCategory);

                          final name = (data['name'] ?? '')
                              .toString()
                              .toLowerCase();
                          final bool matchSearch = _searchQuery.isEmpty ||
                              name.contains(_searchQuery);

                          return matchCategory &&
                              matchSubCategory &&
                              matchSearch;
                        }).toList();

                        if (docs.isEmpty) {
                          return Center(
                            child: Text(
                              "No products found",
                              style: TextStyle(color: subTextColor),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: docs.length,
                          itemBuilder: (context, i) {
                            final data =
                            docs[i].data() as Map<String, dynamic>;
                            final name =
                                data['name'] ?? 'Unnamed Product';
                            final price = data['price']?.toString() ?? '0';
                            final image = data['image'] ?? '';

                            final isBorrow =
                                widget.category == 'Borrow';

                            return Card(
                              color: cardBg,
                              elevation: isDark ? 1 : 3,
                              shadowColor: isDark
                                  ? Colors.black.withOpacity(0.6)
                                  : Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      child: Image.network(
                                        image,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: mainTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Price: $price OMR",
                                            style: TextStyle(
                                              color: subTextColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 36,
                                            width: 130,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                if (isBorrow) {
                                                  Get.to(
                                                        () =>
                                                        BorrowApplyScreen(
                                                          productData: data,
                                                        ),
                                                  );
                                                } else {
                                                  Get.to(
                                                        () =>
                                                        ProductDetailScreen(
                                                          productData: data,
                                                        ),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton
                                                  .styleFrom(
                                                backgroundColor:
                                                const Color(
                                                    0xFFFF9800),
                                                shape:
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(10),
                                                ),
                                              ),
                                              child: const Text(
                                                "Details",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                  FontWeight.bold,
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
      );
    });
  }
}

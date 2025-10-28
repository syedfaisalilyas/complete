import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:storekeeper/screens/home/Buy_Resources/Buy_Products_Screen.dart';
import '../../../core/app_styles.dart';
import '../../../core/app_theme.dart';

class ITProductDetail extends StatefulWidget {
  final String productId;
  const ITProductDetail({super.key, required this.productId});

  @override
  State<ITProductDetail> createState() => _ITProductDetailState();
}

class _ITProductDetailState extends State<ITProductDetail> {
  final DatabaseReference dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
    "https://uni-tool-app-default-rtdb.asia-southeast1.firebasedatabase.app/",
  ).ref();

  Map<String, dynamic>? product;
  Map<String, dynamic>? productDetail;

  String? selectedCapacity;
  String? selectedColor;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProductData();
  }

  Future<void> fetchProductData() async {
    try {
      debugPrint("🔄 Fetching data for productId: ${widget.productId}");

      final productSnap =
      await dbRef.child("products/${widget.productId}").get();
      debugPrint("📦 Product Snapshot: ${productSnap.value}");

      if (!productSnap.exists || productSnap.value == null) {
        debugPrint("❌ Product not found at path: products/${widget.productId}");
        setState(() => isLoading = false);
        return;
      }

      final productData =
      Map<String, dynamic>.from(productSnap.value as Map<dynamic, dynamic>);

      final detailSnap =
      await dbRef.child("productDetails/${widget.productId}").get();
      debugPrint("📦 Details Snapshot: ${detailSnap.value}");

      Map<String, dynamic>? detailData;
      if (detailSnap.exists && detailSnap.value != null) {
        detailData =
        Map<String, dynamic>.from(detailSnap.value as Map<dynamic, dynamic>);
      }

      setState(() {
        product = productData;
        productDetail = detailData;

        if (detailData != null) {
          if (detailData["capacity"] != null &&
              (detailData["capacity"] as List).isNotEmpty) {
            selectedCapacity = detailData["capacity"][0].toString();
          }
          if (detailData["color"] != null &&
              (detailData["color"] as List).isNotEmpty) {
            selectedColor = detailData["color"][0].toString();
          }
        }

        isLoading = false;
      });

      debugPrint("✅ Product Loaded: $product");
      debugPrint("✅ ProductDetails Loaded: $productDetail");
    } catch (e) {
      debugPrint("❌ Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  void selectCapacity(String capacity) {
    setState(() => selectedCapacity = capacity);
    debugPrint("🔄 Capacity Selected: $capacity");
  }

  void selectColor(String color) {
    setState(() => selectedColor = color);
    debugPrint("🎨 Color Selected: $color");
  }

  // ✅ Always pick image from productDetails only
  String getValidImageUrl() {
    final img = (productDetail?["imageUrl"] ?? "").toString().trim();
    if (img.isEmpty) {
      return "https://via.placeholder.com/150"; // fallback
    }
    return img;
  }

  // ✅ Firestore Add to Cart
  Future<void> addToCart() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final cartRef = FirebaseFirestore.instance
          .collection("cart")
          .doc(userId)
          .collection("items");
      await cartRef.doc(widget.productId).set({
        "productId": widget.productId,
        "name": product?["name"] ?? "No Name",
        "price": product?["price"] ?? "0",
        "imageUrl": getValidImageUrl(),
        "capacity": selectedCapacity,
        "color": selectedColor,
        "quantity": 1,
        "createdAt": FieldValue.serverTimestamp(),
      });

      debugPrint("🛒 Product added to Firestore cart!");
      Get.snackbar("Success", "Product added to cart",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint("❌ Error adding to cart: $e");
      Get.snackbar("Error", "Failed to add to cart",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (product == null) {
      return Scaffold(
        body: Center(
          child: Text("❌ Product not found",
              style: AppStyles.Boldtext.copyWith(color: Colors.red)),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const ITProductScreen());
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.background,
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppTheme.primaryColor),
                    onPressed: () {
                      Get.offAll(() => const ITProductScreen());
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: Image.network(
                            getValidImageUrl(),
                            height: 180,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight:
                            MediaQuery.of(context).size.height * 0.68,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product?["name"] ?? "No Name",
                                style: AppStyles.medium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Icon(Icons.star,
                                      color: AppTheme.button, size: 18),
                                  Icon(Icons.star,
                                      color: AppTheme.button, size: 18),
                                  Icon(Icons.star,
                                      color: AppTheme.button, size: 18),
                                  Icon(Icons.star,
                                      color: AppTheme.button, size: 18),
                                  Icon(Icons.star_half,
                                      color: AppTheme.button, size: 18),
                                  SizedBox(width: 6),
                                  Text("30 reviews",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                productDetail?["description"] ??
                                    product?["description"] ??
                                    "No description available",
                                style: const TextStyle(
                                    color: AppTheme.secondaryColor),
                              ),
                              const SizedBox(height: 20),
                              if (productDetail?["capacity"] != null) ...[
                                Text("Capacity:",
                                    style: AppStyles.Boldtext.copyWith(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 10,
                                  children:
                                  (productDetail!["capacity"] as List)
                                      .map<Widget>((cap) {
                                    return buildCapacityButton(
                                      cap.toString(),
                                      selectedCapacity == cap.toString(),
                                          () => selectCapacity(cap.toString()),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                              ],
                              if (productDetail?["color"] != null) ...[
                                Text("Color:",
                                    style: AppStyles.Boldtext.copyWith(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 10,
                                  children: (productDetail!["color"] as List)
                                      .map<Widget>((clr) {
                                    return buildColorButton(
                                      clr.toString(),
                                      selectedColor == clr.toString(),
                                          () => selectColor(clr.toString()),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                              ],
                              Text(
                                "Price: ${product?["price"] ?? "N/A"}",
                                style: AppStyles.medium
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.button,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  onPressed: addToCart,
                                  child: const Text(
                                    "Add to cart",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
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

  Widget buildCapacityButton(
      String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey,
          ),
        ),
        child: Text(
          text,
          style: AppStyles.Regulartext,
        ),
      ),
    );
  }

  Widget buildColorButton(String imageUrl, bool selected, VoidCallback onTap) {
    final validUrl = imageUrl.trim().isNotEmpty
        ? imageUrl
        : "https://via.placeholder.com/50";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.network(
          validUrl,
          height: 50,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.color_lens, size: 30),
        ),
      ),
    );
  }
}

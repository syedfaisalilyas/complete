import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Rx;
import 'package:rxdart/rxdart.dart' as rxdart;

import 'package:storekeeper/screens/payment/Payment_Screen.dart';
import '../../controllers/Cart_Controller.dart';
import '../../core/app_styles.dart';
import '../../core/app_theme.dart';
import '../../controllers/Theme_Controller.dart';
import '../home/home_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ThemeController themeController = Get.find();
  final CartController cartController = Get.put(CartController());
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  Future<void> deleteCartItem(String productId, {bool isBorrow = false}) async {
    final collection = isBorrow ? 'borrowCart' : 'cart';
    await FirebaseFirestore.instance
        .collection(collection)
        .doc(userId)
        .collection('items')
        .doc(productId)
        .delete();
  }

  Future<void> updateQuantity(String productId, int newQty,
      {bool isBorrow = false}) async {
    final collection = isBorrow ? 'borrowCart' : 'cart';
    final docRef = FirebaseFirestore.instance
        .collection(collection)
        .doc(userId)
        .collection('items')
        .doc(productId);

    if (newQty <= 0) {
      await docRef.delete();
    } else {
      await docRef.update({"quantity": newQty});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      // Dark mode colors
      final scaffoldBg = isDark ? Colors.black : null;
      final containerBg = isDark ? Colors.grey[900]! : Colors.white;
      final borderColor = isDark ? Colors.grey[700]! : Colors.grey.shade300;
      final textColor = isDark ? Colors.white : Colors.black;
      final secondaryTextColor = isDark ? Colors.grey[300]! : Colors.black87;

      return WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
          );
          return false;
        },
        child: Scaffold(
          backgroundColor: scaffoldBg,
          body: Container(
            width: 1.sw,
            height: 1.sh,
            decoration: isDark
                ? BoxDecoration(color: Colors.black)
                : const BoxDecoration(gradient: AppTheme.background),
            child: SafeArea(
              child: Column(
                children: [
                  // ===== Top Title =====
                  Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: Text(
                      "app_title".tr,
                      style: AppStyles.large.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ===== Center Image =====
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Image.asset(
                      "assets/images/opening/opening.png",
                      height: 120.h,
                      fit: BoxFit.contain,
                      color: isDark ? Colors.white : null,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // ===== White Container Start =====
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: containerBg,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                      ),
                      child: StreamBuilder<List<QuerySnapshot>>(
                        stream: CombineCartStream(userId).stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              (snapshot.data![0].docs.isEmpty &&
                                  snapshot.data![1].docs.isEmpty)) {
                            return Center(
                              child: Text("cart_empty".tr, style: TextStyle(color: textColor)),
                            );
                          }

                          final buyItems = snapshot.data![0].docs;
                          final borrowItems = snapshot.data![1].docs;

                          final allItems = [
                            ...buyItems.map((doc) => {'doc': doc, 'isBorrow': false}).toList(),
                            ...borrowItems.map((doc) => {'doc': doc, 'isBorrow': true}).toList(),
                          ];

                          double subTotal = 0;
                          for (var entry in allItems) {
                            final doc = entry['doc'] as QueryDocumentSnapshot;
                            final data = doc.data() as Map<String, dynamic>;
                            final isBorrow = entry['isBorrow'] as bool;

                            double price = 0;
                            if (isBorrow) {
                              final calc = data['calculatedPrice'];
                              if (calc is int) price = calc.toDouble();
                              else if (calc is double) price = calc;
                              else if (calc is String) {
                                price = double.tryParse(calc.replaceAll(RegExp(r'[^0-9.]'), "")) ?? 0;
                              }
                            } else {
                              final priceRaw = data['price'] ?? "0";
                              if (priceRaw is int) price = priceRaw.toDouble();
                              else if (priceRaw is double) price = priceRaw;
                              else if (priceRaw is String) {
                                price = double.tryParse(priceRaw.replaceAll(RegExp(r'[^0-9.]'), "")) ?? 0;
                              }
                            }

                            final qtyRaw = data['quantity'] ?? 1;
                            int qty = 1;
                            if (qtyRaw is int) qty = qtyRaw;
                            else if (qtyRaw is String) qty = int.tryParse(qtyRaw) ?? 1;

                            subTotal += price * qty;
                          }

                          double vat = subTotal * 0.05;
                          double totalPrice = subTotal + vat;

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "order_details".tr,
                                  style: AppStyles.medium1.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                SizedBox(height: 10.h),

                                Column(
                                  children: allItems.map((entry) {
                                    final doc = entry['doc'] as QueryDocumentSnapshot;
                                    final isBorrow = entry['isBorrow'] as bool;
                                    final data = doc.data() as Map<String, dynamic>;
                                    final name = data['name'] ?? "No Name";

                                    double price = 0;
                                    if (isBorrow) {
                                      final calc = data['calculatedPrice'];
                                      if (calc is int) price = calc.toDouble();
                                      else if (calc is double) price = calc;
                                      else if (calc is String) {
                                        price = double.tryParse(calc.replaceAll(RegExp(r'[^0-9.]'), "")) ?? 0;
                                      }
                                    } else {
                                      final priceRaw = data['price'] ?? "0";
                                      if (priceRaw is int) price = priceRaw.toDouble();
                                      else if (priceRaw is double) price = priceRaw;
                                      else if (priceRaw is String) {
                                        price = double.tryParse(priceRaw.replaceAll(RegExp(r'[^0-9.]'), "")) ?? 0;
                                      }
                                    }

                                    final image = data['imageUrl'] ?? "https://via.placeholder.com/150";

                                    final qtyRaw = data['quantity'] ?? 1;
                                    int quantity = 1;
                                    if (qtyRaw is int) quantity = qtyRaw;
                                    else if (qtyRaw is String) quantity = int.tryParse(qtyRaw) ?? 1;

                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12.h),
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8.r),
                                            child: Image.network(
                                              image,
                                              width: 80.w,
                                              height: 80.w,
                                              fit: BoxFit.cover,
                                              color: isDark ? Colors.white : null,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(name,
                                                    style: AppStyles.small1.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: textColor,
                                                    )),
                                                SizedBox(height: 4.h),
                                                Text("${"price".tr}: ${price.toStringAsFixed(3)} OMR",
                                                    style: AppStyles.small1.copyWith(color: secondaryTextColor)),
                                                if (isBorrow)
                                                  Text(
                                                    "borrowed_item".tr,
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 12.sp,
                                                    ),
                                                  ),
                                                SizedBox(height: 8.h),
                                                Row(
                                                  children: [
                                                    Text("quantity".tr,
                                                        style: AppStyles.small1.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          color: textColor,
                                                        )),
                                                    SizedBox(width: 10.w),
                                                    IconButton(
                                                      onPressed: () =>
                                                          updateQuantity(doc.id, quantity - 1, isBorrow: isBorrow),
                                                      icon: Icon(Icons.remove_circle, color: Colors.red),
                                                    ),
                                                    Text("$quantity",
                                                        style: AppStyles.medium.copyWith(color: textColor)),
                                                    IconButton(
                                                      onPressed: () =>
                                                          updateQuantity(doc.id, quantity + 1, isBorrow: isBorrow),
                                                      icon: Icon(Icons.add_circle, color: Colors.green),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          IconButton(
                                            onPressed: () => deleteCartItem(doc.id, isBorrow: isBorrow),
                                            icon: Icon(Icons.delete, color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),

                                SizedBox(height: 20.h),

                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: borderColor),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("cart_total".tr,
                                          style: AppStyles.medium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          )),
                                      SizedBox(height: 8.h),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${allItems.length} ${"items".tr}:", style: AppStyles.small1.copyWith(color: secondaryTextColor)),
                                          Text("${subTotal.toStringAsFixed(3)} OMR",
                                              style: AppStyles.small1.copyWith(color: secondaryTextColor)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("vat".tr, style: AppStyles.small1.copyWith(color: secondaryTextColor)),
                                          Text("${vat.toStringAsFixed(3)} OMR",
                                              style: AppStyles.small1.copyWith(color: secondaryTextColor)),
                                        ],
                                      ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("total_price".tr,
                                              style: AppStyles.medium.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                              )),
                                          Text("${totalPrice.toStringAsFixed(3)} OMR",
                                              style: AppStyles.medium.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.black,
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 50.h),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.button,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 14.h),
                                    ),
                                    onPressed: () {
                                      try {
                                        final orderData = cartController.toOrderMap();
                                        Get.to(() => PaymentScreen(orderData: orderData));
                                      } catch (e) {
                                        Get.snackbar("error".tr, e.toString());
                                      }
                                    },
                                    child: Text(
                                      "checkout".tr,
                                      style: AppStyles.medium.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
    });
  }
}

/// ✅ helper class to combine buy + borrow streams
class CombineCartStream {
  final String userId;
  CombineCartStream(this.userId);

  Stream<List<QuerySnapshot>> get stream {
    final buyStream = FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items')
        .snapshots();

    final borrowStream = FirebaseFirestore.instance
        .collection('borrowCart')
        .doc(userId)
        .collection('items')
        .snapshots();

    return rxdart.CombineLatestStream.combine2<QuerySnapshot, QuerySnapshot, List<QuerySnapshot>>(
      buyStream,
      borrowStream,
          (a, b) => [a, b],
    );
  }
}

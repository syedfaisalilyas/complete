import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/Theme_Controller.dart';
import '../../core/app_theme.dart';
import '../../services/tracking_service.dart';
import '../payment/PaymentScreen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please sign in to view your cart.")),
      );
    }

    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      final scaffoldBg = isDark ? Colors.black : null;
      final cardBg = isDark ? Colors.grey[850]! : Colors.white;
      final textColor = isDark ? Colors.white : Colors.black;
      final subTextColor =
      isDark ? Colors.grey[400]! : Colors.black.withOpacity(0.7);

      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          title: const Text(
            "My Cart",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor:
          isDark ? Colors.black : const Color(0xFF6A7FD0),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: isDark
              ? const BoxDecoration(color: Colors.black)
              : const BoxDecoration(gradient: AppTheme.background),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('cart')
                .doc(user.uid)
                .collection('items')
                .orderBy('addedAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "Your cart is empty.",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }

              final docs = snapshot.data!.docs;
              double total = 0;

              for (var d in docs) {
                final data = d.data() as Map<String, dynamic>;
                final price = (data['price'] is num)
                    ? (data['price'] as num).toDouble()
                    : double.tryParse(data['price'].toString()) ?? 0;
                final qty = (data['quantity'] ?? 1) as int;
                total += price * qty;
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data =
                        docs[index].data() as Map<String, dynamic>;
                        final productId = docs[index].id;

                        final name = data['name'] ?? "Unnamed";
                        final imageUrl = data['imageUrl'] ?? '';
                        final qty = (data['quantity'] ?? 1) as int;
                        final price = (data['price'] is num)
                            ? (data['price'] as num).toDouble()
                            : double.tryParse(
                            data['price'].toString()) ??
                            0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                    imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Icon(Icons.image,
                                            size: 50,
                                            color: subTextColor),
                                  )
                                      : Icon(Icons.image,
                                      size: 70, color: subTextColor),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Price: ${price.toStringAsFixed(3)} OMR",
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              if (qty > 1) {
                                                await FirebaseFirestore.instance
                                                    .collection('cart')
                                                    .doc(user.uid)
                                                    .collection('items')
                                                    .doc(productId)
                                                    .update({
                                                  'quantity': qty - 1,
                                                });
                                              } else {
                                                await FirebaseFirestore.instance
                                                    .collection('cart')
                                                    .doc(user.uid)
                                                    .collection('items')
                                                    .doc(productId)
                                                    .delete();
                                              }
                                            },
                                          ),
                                          Text(
                                            "$qty",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle,
                                              color: Colors.green,
                                            ),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('cart')
                                                  .doc(user.uid)
                                                  .collection('items')
                                                  .doc(productId)
                                                  .update({
                                                'quantity': qty + 1,
                                              });

                                              TrackingService
                                                  .trackUserActivity(
                                                productId: productId,
                                                category:
                                                data['category'] ?? "",
                                                name: data['name'] ?? "",
                                                addedToCart: true,
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('cart')
                                        .doc(user.uid)
                                        .collection('items')
                                        .doc(productId)
                                        .delete();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ===== Total + Checkout =====
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[900]
                          : const Color(0xFF6A7FD0),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Total: ${total.toStringAsFixed(3)} OMR",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Get.to(
                                    () => PaymentScreen(totalAmount: total),
                              );
                            },
                            child: const Text(
                              "Checkout",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}

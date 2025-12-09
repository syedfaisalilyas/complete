import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../../services/notification_service.dart';
import '../../../services/tracking_service.dart';
import '../../signUp/notification_widget.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetailScreen({super.key, required this.productData});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  String selectedCapacity = '32GB';
  String selectedColor = 'Red';

  // ---------- Rating + Feedback ----------
  double userRating = 0;
  bool _loadingUserRating = false;
  final TextEditingController feedbackCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = widget.productData;
    final productId =
        data['id']?.toString() ?? data['name']?.toString() ?? '';
    TrackingService.trackUserActivity(
      productId: productId,
      category: data["category"] ?? "",
      name: data["name"] ?? "",
      viewed: true,
    );

    if (productId.isNotEmpty) {
      _loadUserRating(productId);
    }
  }

  Future<void> _loadUserRating(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _loadingUserRating = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .collection("ratings")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final ratingVal = (doc.data()?['rating'] ?? 0) as num;
        setState(() {
          userRating = ratingVal.toDouble();
        });
      }
    } finally {
      if (mounted) setState(() => _loadingUserRating = false);
    }
  }

  Future<void> _submitRating(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        "Login required",
        "Please login to rate this product.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (userRating <= 0) {
      Get.snackbar(
        "Rating required",
        "Please select a rating.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("products")
        .doc(productId)
        .collection("ratings")
        .doc(user.uid)
        .set({
      "userId": user.uid,
      "rating": userRating,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    Get.snackbar(
      "Rating saved",
      "Your rating has been updated.",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> _submitFeedback(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        "Login required",
        "Please login to give feedback.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final text = feedbackCtrl.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        "Feedback required",
        "Please write something.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection("products")
        .doc(productId)
        .collection("feedbacks")
        .add({
      "userId": user.uid,
      "feedback": text,
      "timestamp": FieldValue.serverTimestamp(),
    });

    feedbackCtrl.clear();

    Get.snackbar(
      "Feedback submitted",
      "Thank you for your feedback!",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Average rating from ratings subcollection
  Widget _averageRatingWidget(String productId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .collection("ratings")
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return const Text(
            "No ratings yet",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          );
        }

        double total = 0;
        for (var doc in snap.data!.docs) {
          total += (doc['rating'] as num).toDouble();
        }
        final avg = total / snap.data!.docs.length;

        return Row(
          children: [
            ...List.generate(
              5,
                  (i) => Icon(
                i < avg ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              avg.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "(${snap.data!.docs.length} reviews)",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        );
      },
    );
  }

  // Feedback list
  Widget _feedbackList(String productId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .collection("feedbacks")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Text(
            "No feedback yet.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final fb = docs[index];
            final text = fb['feedback'] ?? '';
            final ts = fb['timestamp'];
            String timeLabel = "Just now";
            if (ts != null) {
              final dt = ts.toDate();
              timeLabel = dt.toString().substring(0, 16); // yyyy-mm-dd hh:mm
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.productData;

    // IMPORTANT: use id if exists, else fallback to name
    final productId =
        data['id']?.toString() ?? data['name']?.toString() ?? '';

    final imageUrl = data['image']?.toString().trim() ?? '';
    final name = data['name'] ?? 'Unnamed Product';
    final price = data['price']?.toString() ?? '0.0';
    final description = data['description'] ?? 'No description available.';
    final condition = data['condition'] ?? '';
    final stock = data['stock']?.toString() ?? '0';
    final category = data['category'] ?? '';
    final subcategory = data['subcategory'] ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ===== Top Image Section =====
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: const Color(0xFF6A7FD0),
                  child: Column(
                    children: [
                      // Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          height: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/order/order.png',
                              height: 180,
                              fit: BoxFit.contain,
                            );
                          },
                        )
                            : Image.asset(
                          'assets/images/order/order.png',
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),

            // ===== Bottom White Container =====
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Title
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // ⭐ Average rating (dynamic)
                      if (productId.isNotEmpty) _averageRatingWidget(productId),

                      const SizedBox(height: 10),

                      // Description
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 15),

                      if (condition.isNotEmpty || category.isNotEmpty)
                        Text(
                          "Condition: $condition | Category: $category | Sub: $subcategory",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Price
                      Text(
                        "Price: $price OMR",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Available Stock: $stock",
                        style:
                        const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Quantity Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _qtyButton(Icons.remove, () {
                            if (quantity > 1) {
                              setState(() => quantity--);
                            }
                          }),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _qtyButton(Icons.add, () {
                            int stockQty = int.tryParse(stock) ?? 0;
                            if (quantity < stockQty) {
                              setState(() => quantity++);
                            } else {
                              Get.snackbar(
                                "Stock Limit",
                                "Only $stockQty items available in stock.",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          }),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Add to Cart Button (now with dialog on success)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              Get.snackbar(
                                "Not Logged In",
                                "Please sign in first to add items to cart.",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            final userId = user.uid;
                            final stockQty = int.tryParse(stock) ?? 0;

                            if (stockQty <= 0) {
                              Get.snackbar(
                                "Out of Stock",
                                "This item is currently unavailable.",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            if (quantity > stockQty) {
                              Get.snackbar(
                                "Stock Limit",
                                "Only $stockQty items available in stock.",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            final cartRef = FirebaseFirestore.instance
                                .collection('cart')
                                .doc(userId)
                                .collection('items')
                                .doc(productId.isNotEmpty ? productId : name);

                            final doc = await cartRef.get();

                            // UPDATE quantity if exists
                            if (doc.exists) {
                              final currentQty = doc['quantity'] ?? 1;
                              final newQty = currentQty + quantity;

                              if (newQty > stockQty) {
                                Get.snackbar(
                                  "Stock Limit",
                                  "You can only have $stockQty of this item in your cart.",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              await cartRef.update({
                                'quantity': newQty,
                                'updatedAt': FieldValue.serverTimestamp(),
                              });
                            } else {
                              // ADD new item
                              await cartRef.set({
                                'name': name,
                                'price': price,
                                'imageUrl': imageUrl,
                                'quantity': quantity,
                                'category': category,
                                'subcategory': subcategory,
                                'selectedCapacity': selectedCapacity,
                                'selectedColor': selectedColor,
                                'addedAt': FieldValue.serverTimestamp(),
                              });
                            }
                            TrackingService.trackUserActivity(
                              productId: productId,
                              category: category,
                              name: name,
                              addedToCart: true,
                            );

                            // ================================
                            // 🔔 SEND IN-APP NOTIFICATION HERE
                            // ================================
                            showOverlayNotification(
                                  (context) => buildSuccessNotification("Added to cart", "$name added successfully!"),
                              duration: Duration(seconds: 3),
                            );


                            // Show success dialog
                            if (!mounted) return;
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    "Added to Cart",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  content: Text("$name has been added to your cart."),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Add to cart",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --------- Rating Section (ONE rating per user) ---------
                      if (productId.isNotEmpty) ...[
                        const Divider(),
                        const Text(
                          "Your Rating",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_loadingUserRating)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: LinearProgressIndicator(),
                          )
                        else
                          Row(
                            children: List.generate(
                              5,
                                  (index) => IconButton(
                                onPressed: () {
                                  setState(() {
                                    userRating = (index + 1).toDouble();
                                  });
                                },
                                icon: Icon(
                                  index < userRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                ),
                              ),
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () => _submitRating(productId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: const Text(
                              "Save Rating",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --------- Feedback (MULTIPLE per user) ---------
                        const Text(
                          "Write Feedback",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: feedbackCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: "Write your feedback about this product...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () => _submitFeedback(productId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: const Text(
                              "Submit Feedback",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Students' Feedback",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _feedbackList(productId),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== Quantity Button Widget =====
  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.black),
      ),
    );
  }
}

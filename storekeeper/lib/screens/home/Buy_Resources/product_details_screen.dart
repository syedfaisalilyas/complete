import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  @override
  Widget build(BuildContext context) {
    final data = widget.productData;

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
                              child: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
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
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(40)),
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

                      // Ratings + Reviews
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.amber, size: 18),
                          const Icon(Icons.star,
                              color: Colors.amber, size: 18),
                          const Icon(Icons.star,
                              color: Colors.amber, size: 18),
                          const Icon(Icons.star,
                              color: Colors.amber, size: 18),
                          const Icon(Icons.star_border,
                              color: Colors.amber, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            "${data['numberOfReviews'] ?? 0} reviews",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
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

                      // Capacity (if applicable)

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
                            if (quantity > 1) setState(() => quantity--);
                          }),
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _qtyButton(Icons.add, () {
                            setState(() => quantity++);
                          }),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Add to Cart Button
                      // Add to Cart Button
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
                            final cartRef = FirebaseFirestore.instance
                                .collection('cart')
                                .doc(userId)
                                .collection('items')
                                .doc(data['id'] ?? name); // product id or fallback

                            final doc = await cartRef.get();

                            if (doc.exists) {
                              // If already in cart, just increase quantity
                              final currentQty = doc['quantity'] ?? 1;
                              await cartRef.update({
                                'quantity': currentQty + quantity,
                                'updatedAt': FieldValue.serverTimestamp(),
                              });
                            } else {
                              // New item
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

                            // ✅ Success Feedback
                            Get.snackbar(
                              "Added to Cart",
                              "$name added successfully!",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
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

  // ===== Reusable Color Option Widget =====
  Widget _colorOption(String imagePath, String color) {
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(
          imagePath,
          width: 50,
          height: 50,
          color: isSelected ? null : Colors.grey.shade400,
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

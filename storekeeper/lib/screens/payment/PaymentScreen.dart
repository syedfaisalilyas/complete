import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ThankYouScreen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final user = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController cardNumberCtrl = TextEditingController();
  final TextEditingController expiryCtrl = TextEditingController();
  final TextEditingController cvvCtrl = TextEditingController();

  bool isProcessing = false;

  /// ======================
  /// BACK BUTTON POPUP
  /// ======================
  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Cancel Payment?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
            "Are you sure you want to cancel this payment? Your cart will be cleared."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Continue"),
          ),
          TextButton(
            onPressed: () async {
              if (user != null) {
                var cartItems = await FirebaseFirestore.instance
                    .collection('cart')
                    .doc(user!.uid)
                    .collection('items')
                    .get();

                for (var item in cartItems.docs) {
                  await item.reference.delete();
                }
              }

              Navigator.pop(context, true); // Exit PaymentScreen
            },
            child: const Text("Cancel Payment",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
  }

  /// ======================
  /// PICK EXPIRY DATE
  /// ======================
  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 15),
    );

    if (picked != null) {
      expiryCtrl.text =
      "${picked.month.toString().padLeft(2, '0')}/${(picked.year % 100).toString().padLeft(2, '0')}";
    }
  }

  /// ======================
  /// HANDLE PAYMENT
  /// ======================
  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (user == null) return;

    setState(() => isProcessing = true);

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('items');

      final cartItems = await cartRef.get();

      if (cartItems.docs.isEmpty) {
        Get.snackbar("Cart Empty", "No items to process.",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final ordersCollection =
      FirebaseFirestore.instance.collection('orders');

      final orderDocRef = ordersCollection.doc(); // Auto ID
      final orderId = orderDocRef.id;

      // Order Data
      final orderData = {
        'orderId': orderId,
        'userId': user!.uid,
        'totalAmount': widget.totalAmount,
        'paymentMethod': 'Card',
        'cardName': nameCtrl.text.trim(),
        'cardNumber': cardNumberCtrl.text.trim(),
        'expiry': expiryCtrl.text.trim(),
        'status': 'Confirmed',
        'timestamp': FieldValue.serverTimestamp(),
        'items': cartItems.docs.map((doc) => doc.data()).toList(),
      };

      await orderDocRef.set(orderData);

      // Create Invoice
      final invoiceId = "INV-${DateTime.now().millisecondsSinceEpoch}";
      await FirebaseFirestore.instance
          .collection('invoices')
          .doc(invoiceId)
          .set({
        'invoiceId': invoiceId,
        'orderId': orderId,
        'userId': user!.uid,
        'amount': widget.totalAmount,
        'createdAt': FieldValue.serverTimestamp(),
        'items': cartItems.docs.map((doc) => doc.data()).toList(),
      });

      // Clear Cart
      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }

      // Go to Thank You Screen
      Get.off(() => ThankYouScreen(
        orderId: orderId,
        invoiceId: invoiceId,
        amount: widget.totalAmount,
      ));
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isProcessing = false);
    }
  }

  /// ======================
  /// UI
  /// ======================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // <<< IMPORTANT
      child: Scaffold(
        backgroundColor: const Color(0xFF6A7FD0),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ===== Back Button =====
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => _onWillPop(),
                        ),
                        const Spacer(),
                        const Text(
                          "Uni Tools App",
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Image.asset("assets/images/payment/payment1.png",
                        height: 120),

                    const SizedBox(height: 20),

                    // ===== White Card Container =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Payment",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),

                            const SizedBox(height: 20),

                            TextFormField(
                              controller: cardNumberCtrl,
                              keyboardType: TextInputType.number,
                              maxLength: 16,
                              decoration: const InputDecoration(
                                labelText: "Card Number",
                                counterText: "",
                              ),
                              validator: (v) {
                                if (v == null || v.length != 16) {
                                  return "Enter valid 16-digit card number";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 10),

                            TextFormField(
                              controller: nameCtrl,
                              decoration: const InputDecoration(
                                labelText: "Card Holder Name",
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? "Enter cardholder name"
                                  : null,
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: expiryCtrl,
                                    readOnly: true,
                                    onTap: _pickExpiryDate,
                                    decoration: const InputDecoration(
                                      labelText: "Expiry Date",
                                      hintText: "MM/YY",
                                    ),
                                    validator: (v) =>
                                    v == null || v.isEmpty
                                        ? "Select expiry date"
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: cvvCtrl,
                                    obscureText: true,
                                    keyboardType: TextInputType.number,
                                    maxLength: 3,
                                    decoration: const InputDecoration(
                                      labelText: "CVV",
                                      counterText: "",
                                    ),
                                    validator: (v) =>
                                    v == null || v.length != 3
                                        ? "Enter 3-digit CVV"
                                        : null,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "Total: ${widget.totalAmount.toStringAsFixed(2)} OMR",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: isProcessing ? null : _handlePayment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: isProcessing
                                    ? const CircularProgressIndicator(
                                    color: Colors.white)
                                    : const Text(
                                  "Pay Now",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== Loading Overlay =====
              if (isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

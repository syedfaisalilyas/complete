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
        Get.snackbar("Cart Empty", "No items to process.");
        return;
      }

      // ✅ Prepare order data
      final orderData = {
        'userId': user!.uid,
        'totalAmount': widget.totalAmount,
        'paymentMethod': 'Dummy Card',
        'cardName': nameCtrl.text.trim(),
        'cardNumber': cardNumberCtrl.text.trim(),
        'expiry': expiryCtrl.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'items': cartItems.docs.map((doc) => doc.data()).toList(),
      };

      // ✅ Save to Firestore
      await FirebaseFirestore.instance.collection('orders').add(orderData);

      // ✅ Clear the cart
      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }

      // ✅ Navigate to Thank You Screen
      Get.off(() => const ThankYouScreen());
    } catch (e) {
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A7FD0),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // App Header
                  const Text(
                    "Uni Tools app",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Payment Card Image
                  Image.asset(
                    'assets/images/payment_card.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 25),

                  // White Form Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: cardNumberCtrl,
                                keyboardType: TextInputType.number,
                                maxLength: 16,
                                decoration: const InputDecoration(
                                  labelText: "Card Number",
                                  hintText: "Enter your card number",
                                  counterText: "",
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return "Enter card number";
                                  if (v.length != 16) return "Must be 16 digits";
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: nameCtrl,
                                decoration: const InputDecoration(
                                  labelText: "Card Holder Name",
                                  hintText: "Enter card holder name",
                                ),
                                validator: (v) =>
                                v == null || v.trim().isEmpty ? "Enter cardholder name" : null,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: expiryCtrl,
                                      keyboardType: TextInputType.datetime,
                                      maxLength: 5,
                                      decoration: const InputDecoration(
                                        labelText: "Exp Date",
                                        hintText: "MM/YY",
                                        counterText: "",
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return "Enter expiry";
                                        final regex = RegExp(r"^(0[1-9]|1[0-2])\/\d{2}$");
                                        if (!regex.hasMatch(v)) return "Format MM/YY";
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: cvvCtrl,
                                      obscureText: true,
                                      keyboardType: TextInputType.number,
                                      maxLength: 3,
                                      decoration: const InputDecoration(
                                        labelText: "CVV",
                                        hintText: "Enter your CVV",
                                        counterText: "",
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return "Enter CVV";
                                        if (v.length != 3) return "3 digits only";
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Total Price: ${widget.totalAmount.toStringAsFixed(2)} OMR",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: isProcessing
                                      ? const CircularProgressIndicator(color: Colors.white)
                                      : const Text(
                                    "Pay Now",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

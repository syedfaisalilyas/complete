import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Theme_Controller.dart';
import '../../core/app_theme.dart';
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
  String generatedOtp = "";

  final ThemeController themeController = Get.find<ThemeController>();

  // ===========================
  // BACK BUTTON CONFIRMATION
  // ===========================
  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Payment?"),
        content: const Text("Are you sure? Cart will be cleared."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Continue"),
          ),
          TextButton(
            onPressed: () async {
              if (user != null) {
                var cart = await FirebaseFirestore.instance
                    .collection("cart")
                    .doc(user!.uid)
                    .collection("items")
                    .get();
                for (var doc in cart.docs) {
                  await doc.reference.delete();
                }
              }
              Navigator.pop(context, true);
            },
            child: const Text("Cancel Payment",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ??
        false;
  }

  // ===========================
  // PICK EXPIRY DATE
  // ===========================
  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );

    if (picked != null) {
      expiryCtrl.text =
      "${picked.month.toString().padLeft(2, "0")}/${(picked.year % 100).toString().padLeft(2, "0")}";
    }
  }

  // ===========================
  // GENERATE & SHOW OTP DIALOG
  // ===========================
  Future<bool> _showOtpDialog() async {
    TextEditingController otpController = TextEditingController();

    generatedOtp = (Random().nextInt(900000) + 100000).toString();
    print("DEBUG OTP: $generatedOtp");

    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Enter OTP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("An OTP has been sent to your phone/email."),
            const SizedBox(height: 15),
            Text("OTP: $generatedOtp",
                style: const TextStyle(
                    fontSize: 18,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                  hintText: "Enter 6-digit OTP"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (otpController.text.trim() == generatedOtp) {
                Navigator.pop(context, true);
              } else {
                Get.snackbar("Invalid OTP", "Please try again.",
                    colorText: Colors.white,
                    backgroundColor: Colors.red);
              }
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    ) ??
        false;
  }

  // ===========================
  // SEND EMAIL RECEIPT (via Firestore queue)
  // ===========================
  Future<void> _queueEmailReceipt({
    required String orderId,
    required String invoiceId,
    required double amount,
  }) async {
    await FirebaseFirestore.instance.collection("email_queue").add({
      "to": user!.email,
      "subject": "Your Payment Receipt - $orderId",
      "body":
      "Thank you for your purchase!\n\nOrder ID: $orderId\nInvoice: $invoiceId\nAmount Paid: ${amount.toStringAsFixed(2)} OMR\n\nRegards,\nUni Tools App",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  // ===========================
  // PROCESS PAYMENT
  // ===========================
  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;
    if (user == null) return;

    // OTP CHECK
    bool otpVerified = await _showOtpDialog();
    if (!otpVerified) return;

    setState(() => isProcessing = true);

    try {
      final cartRef = FirebaseFirestore.instance
          .collection("cart")
          .doc(user!.uid)
          .collection("items");

      final cartItems = await cartRef.get();

      if (cartItems.docs.isEmpty) {
        Get.snackbar("Cart Empty", "Add items before paying.");
        return;
      }

      final orders = FirebaseFirestore.instance.collection("orders");
      final orderDoc = orders.doc();
      final orderId = orderDoc.id;

      final invoiceId = "INV-${DateTime.now().millisecondsSinceEpoch}";

      final orderData = {
        "orderId": orderId,
        "userId": user!.uid,
        "totalAmount": widget.totalAmount,
        "cardHolder": nameCtrl.text.trim(),
        "cardNumber": cardNumberCtrl.text.trim(),
        "expiry": expiryCtrl.text.trim(),
        "status": "Paid",
        "timestamp": FieldValue.serverTimestamp(),
        "items": cartItems.docs.map((e) => e.data()).toList(),
      };

      // SAVE ORDER
      await orderDoc.set(orderData);

      // SAVE INVOICE
      await FirebaseFirestore.instance
          .collection("invoices")
          .doc(invoiceId)
          .set({
        "invoiceId": invoiceId,
        "orderId": orderId,
        "amount": widget.totalAmount,
        "createdAt": FieldValue.serverTimestamp(),
        "items": cartItems.docs.map((e) => e.data()).toList(),
      });

      // SEND EMAIL RECEIPT
      await _queueEmailReceipt(
        orderId: orderId,
        invoiceId: invoiceId,
        amount: widget.totalAmount,
      );

      // CLEAR CART
      for (var doc in cartItems.docs) {
        await doc.reference.delete();
      }

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

  // ===========================
  // UI
  // ===========================
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      final scaffoldBg = isDark ? Colors.black : const Color(0xFF6A7FD0);
      final cardBg = isDark ? Colors.grey[900]! : Colors.white;
      final textColor = isDark ? Colors.white : Colors.black;
      final subColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;

      InputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: c),
      );

      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: scaffoldBg,
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // HEADER ROW
                      Row(
                        children: [
                          IconButton(
                            icon:
                            const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: _onWillPop,
                          ),
                          const Spacer(),
                          const Text(
                            "Uni Tools",
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
                          height: 120, color: isDark ? Colors.white : null),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Payment",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor)),
                              const SizedBox(height: 20),

                              // CARD NUMBER
                              TextFormField(
                                controller: cardNumberCtrl,
                                maxLength: 16,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Card Number",
                                  counterText: "",
                                  labelStyle: TextStyle(color: subColor),
                                  enabledBorder: border(subColor),
                                  focusedBorder: border(Colors.orange),
                                ),
                                validator: (v) =>
                                v!.length == 16 ? null : "Enter valid card",
                                style: TextStyle(color: textColor),
                              ),

                              const SizedBox(height: 10),

                              // CARD HOLDER NAME
                              TextFormField(
                                controller: nameCtrl,
                                decoration: InputDecoration(
                                  labelText: "Card Holder Name",
                                  labelStyle: TextStyle(color: subColor),
                                  enabledBorder: border(subColor),
                                  focusedBorder: border(Colors.orange),
                                ),
                                validator: (v) =>
                                v!.trim().isEmpty ? "Enter name" : null,
                                style: TextStyle(color: textColor),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: expiryCtrl,
                                      readOnly: true,
                                      onTap: _pickExpiryDate,
                                      decoration: InputDecoration(
                                        labelText: "Expiry",
                                        hintText: "MM/YY",
                                        labelStyle: TextStyle(color: subColor),
                                        enabledBorder: border(subColor),
                                        focusedBorder: border(Colors.orange),
                                      ),
                                      validator: (v) =>
                                      v!.isEmpty ? "Select expiry" : null,
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: cvvCtrl,
                                      maxLength: 3,
                                      obscureText: true,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "CVV",
                                        counterText: "",
                                        labelStyle: TextStyle(color: subColor),
                                        enabledBorder: border(subColor),
                                        focusedBorder: border(Colors.orange),
                                      ),
                                      validator: (v) =>
                                      v!.length == 3 ? null : "Invalid CVV",
                                      style: TextStyle(color: textColor),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Text(
                                "Total: ${widget.totalAmount.toStringAsFixed(2)} OMR",
                                style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed:
                                  isProcessing ? null : _handlePayment,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange),
                                  child: isProcessing
                                      ? const CircularProgressIndicator(
                                      color: Colors.white)
                                      : const Text("Pay Now",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'borrow_status_screen.dart';

class BorrowApplyScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  const BorrowApplyScreen({super.key, required this.productData});

  @override
  State<BorrowApplyScreen> createState() => _BorrowApplyScreenState();
}

class _BorrowApplyScreenState extends State<BorrowApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _borrowDate = TextEditingController();
  final TextEditingController _returnDate = TextEditingController();

  bool _submitting = false;

  User? get user => FirebaseAuth.instance.currentUser;

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
      initialDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6A7FD0),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('dd MMM yyyy').format(picked);
      setState(() {});
    }
  }

  DateTime? _parse(String s) {
    try {
      return DateFormat('dd MMM yyyy').parse(s);
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitRequest() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (user == null) {
      Get.snackbar("Login required", "Please login first");
      return;
    }

    final borrow = _parse(_borrowDate.text);
    final ret = _parse(_returnDate.text);

    if (borrow == null || ret == null) {
      Get.snackbar("Invalid dates", "Please select valid dates");
      return;
    }

    if (!ret.isAfter(borrow)) {
      Get.snackbar("Invalid return date", "Return date must be after borrow date");
      return;
    }

    setState(() => _submitting = true);

    try {
      final uid = user!.uid;
      final product = widget.productData;
      final itemId = product['id'];

      final col = FirebaseFirestore.instance.collection('borrow_requests');

      // 🔒 PREVENT DUPLICATE ACTIVE REQUESTS
      final existing = await col
          .where('userId', isEqualTo: uid)
          .where('itemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final status = (doc['status'] ?? "PENDING").toString();

        if (status != "COMPLETED" && status != "REJECTED") {
          // redirect to existing request
          Get.off(() => UserBorrowStatusScreen(requestId: doc.id));
          return;
        }
      }

      // ✅ CREATE NEW REQUEST
      final docRef = await col.add({
        "userId": uid,
        "userEmail": user!.email ?? "",
        "itemId": itemId,
        "itemName": product['name'] ?? "",
        "image": product['image'] ?? "",
        "price": product['price'] ?? 0,
        "condition": product['condition'] ??
            (product['isUsed'] == true ? "Used" : "New"),

        "borrowDate": _borrowDate.text,
        "returnDate": _returnDate.text,

        // admin-only
        "securityDeposit": 0,
        "depositFinalized": false,

        "status": "PENDING",

        "createdAt": FieldValue.serverTimestamp(),
      });

      Get.off(() => UserBorrowStatusScreen(requestId: docRef.id));

      Get.snackbar(
        "Request submitted",
        "Waiting for admin approval",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('error is $e');
      Get.snackbar("Error", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = user;
    if (u == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to borrow items")),
      );
    }

    final p = widget.productData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Borrow Item"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A7FD0), Color(0xFF879AF2)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= PRODUCT CARD =================
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        p['image'] ?? '',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,

                        // ✅ while loading
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 90,
                            height: 90,
                            color: Colors.grey.shade200,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(strokeWidth: 2),
                          );
                        },

                        // ✅ if image URL is invalid / 404 / empty
                        errorBuilder: (_, __, ___) {
                          return Image.asset(
                            'assets/images/placeholder.png',
                            height: 180,
                            fit: BoxFit.contain,
                          );
                        },

                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['name'] ?? "",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text("Condition: ${p['condition'] ?? "N/A"}"),
                          const SizedBox(height: 6),
                          Text(
                            "Rent: ${p['price']} OMR",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Security deposit will be set by admin",
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ================= FORM =================
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _borrowDate,
                        readOnly: true,
                        onTap: () => _pickDate(_borrowDate),
                        decoration: const InputDecoration(
                          labelText: "Borrow Date",
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        (v == null || v.isEmpty) ? "Select borrow date" : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _returnDate,
                        readOnly: true,
                        onTap: () => _pickDate(_returnDate),
                        decoration: const InputDecoration(
                          labelText: "Return Date",
                          prefixIcon: Icon(Icons.event_repeat_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        (v == null || v.isEmpty) ? "Select return date" : null,
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _submitting ? null : _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A7FD0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _submitting
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Submit Borrow Request",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
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
}

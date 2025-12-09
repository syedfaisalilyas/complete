import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../services/tracking_service.dart';
import 'BorrowFeedbackScreen.dart';
import 'borrow_status_screen.dart';

class BorrowApplyScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  const BorrowApplyScreen({super.key, required this.productData});

  @override
  State<BorrowApplyScreen> createState() => _BorrowApplyScreenState();
}

class _BorrowApplyScreenState extends State<BorrowApplyScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _borrowDate = TextEditingController();
  final TextEditingController _returnDate = TextEditingController();
  final TextEditingController _deposit = TextEditingController();

  Future<void> _pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
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
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (user == null) {
      Get.snackbar("Not Logged In", "Please sign in first.");
      return;
    }

    final product = widget.productData;
    final request = {
      "userId": user!.uid,
      "userEmail": user!.email,
      "itemId": product['id'] ?? "",
      "itemName": product['name'] ?? "",
      "price": product['price'] ?? 0,
      "image": product['image'] ?? "",
      "borrowDate": _borrowDate.text,
      "returnDate": _returnDate.text,
      "deposit": double.tryParse(_deposit.text) ?? 0,
      "status": "Pending",
      "createdAt": FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('borrow_requests').add(request);
    TrackingService.trackUserActivity(
      productId: product['id'],
      category: product['category'] ?? "",
      name: product['name'],
      borrowed: true,
    );

    Get.snackbar("✅ Request Sent", "Your borrow request is pending approval.",
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
          body: Center(child: Text("Please login to borrow items.")));
    }

    final data = widget.productData;
    final uid = user!.uid;
    final itemId = data['id'];

    // ✅ StreamBuilder: live updates for this user + product
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('borrow_requests')
          .where('userId', isEqualTo: uid)
          .where('itemId', isEqualTo: itemId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // If user already applied → show live status screen
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final doc = snapshot.data!.docs.first;
          final requestData = doc.data() as Map<String, dynamic>;
          requestData['id'] = doc.id; // attach id for reference
          return BorrowStatusScreen(requestData: requestData);
        }

        // Otherwise show Apply Form
        return Scaffold(
          appBar: AppBar(
            title: const Text("Borrow Request"),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A7FD0), Color(0xFF879AF2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            centerTitle: true,
            elevation: 2,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'] ?? "",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Price: ${data['price']} OMR",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Divider(height: 30),

                      // Borrow Date
                      TextFormField(
                        controller: _borrowDate,
                        readOnly: true,
                        onTap: () => _pickDate(_borrowDate),
                        decoration: const InputDecoration(
                          labelText: "Borrow Date",
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? "Enter borrow date"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Return Date
                      TextFormField(
                        controller: _returnDate,
                        readOnly: true,
                        onTap: () => _pickDate(_returnDate),
                        decoration: const InputDecoration(
                          labelText: "Return Date",
                          prefixIcon: Icon(Icons.event_repeat_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? "Enter return date"
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // DEPOSIT
                      TextFormField(
                        controller: _deposit,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Security Deposit (OMR)",
                          prefixIcon: Icon(Icons.monetization_on_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? "Enter deposit amount"
                            : null,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _submitRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A7FD0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Submit Request",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'borrow_constants.dart';

class AdminBorrowPaidPickupScreen extends StatelessWidget {
  const AdminBorrowPaidPickupScreen({super.key});

  Future<void> _markCollected(DocumentReference ref, String orderNo, String location, String time) async {
    if (orderNo.trim().isEmpty || location.trim().isEmpty || time.trim().isEmpty) {
      Get.snackbar("Missing info", "Order number, location and pickup time are required.");
      return;
    }

    await ref.update({
      "orderNumber": orderNo.trim(),
      "pickupLocation": location.trim(),
      "pickupTime": time.trim(),
      "status": BorrowStatuses.collected,
    });

    Get.snackbar("Updated", "Marked as collected", backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('borrow_requests')
        .where('status', isEqualTo: BorrowStatuses.paid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text("Paid Orders → Pickup")),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text("No paid orders."));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              final d = doc.data() as Map<String, dynamic>;

              final orderCtrl = TextEditingController(text: d['orderNumber']?.toString() ?? "");
              final locCtrl = TextEditingController(text: d['pickupLocation']?.toString() ?? "");
              final timeCtrl = TextEditingController(text: d['pickupTime']?.toString() ?? "");

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['itemName'] ?? "", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("User: ${d['userEmail'] ?? ""}"),
                      const SizedBox(height: 10),
                      TextField(
                        controller: orderCtrl,
                        decoration: const InputDecoration(labelText: "Order Number", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: locCtrl,
                        decoration: const InputDecoration(labelText: "Pickup Location", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: timeCtrl,
                        decoration: const InputDecoration(labelText: "Pickup Time", border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => _markCollected(doc.reference, orderCtrl.text, locCtrl.text, timeCtrl.text),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                          child: const Text("Mark as Collected"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

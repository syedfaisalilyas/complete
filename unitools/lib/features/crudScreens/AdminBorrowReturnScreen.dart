import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'borrow_constants.dart';

class AdminBorrowCollectedReturnScreen extends StatelessWidget {
  const AdminBorrowCollectedReturnScreen({super.key});

  Future<void> _complete(DocumentReference ref, num deposit, String deductedText) async {
    final deducted = double.tryParse(deductedText) ?? 0;
    if (deducted < 0) {
      Get.snackbar("Invalid amount", "Deducted amount cannot be negative.");
      return;
    }
    if (deducted > deposit) {
      Get.snackbar("Invalid amount", "Deducted cannot be greater than deposit ($deposit).");
      return;
    }

    final refund = (deposit - deducted);

    await ref.update({
      "deductedAmount": deducted,
      "refundAmount": refund,
      "refundStatus": "DONE",
      "status": BorrowStatuses.completed,
    });

    Get.snackbar("Completed", "Order completed. Refund: $refund OMR",
        backgroundColor: Colors.teal, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('borrow_requests')
        .where('status', isEqualTo: BorrowStatuses.collected)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text("Collected → Return & Refund")),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text("No collected items."));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              final d = doc.data() as Map<String, dynamic>;
              final deposit = (d['securityDeposit'] ?? 0) as num;

              final deductedCtrl = TextEditingController(text: "0");

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
                      const SizedBox(height: 6),
                      Text("Deposit: $deposit OMR"),
                      const SizedBox(height: 10),
                      TextField(
                        controller: deductedCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Damage Deduction (OMR)",
                          helperText: "Enter 0 for no damage, or amount to deduct",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => _complete(doc.reference, deposit, deductedCtrl.text),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                          child: const Text("Complete & Refund"),
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

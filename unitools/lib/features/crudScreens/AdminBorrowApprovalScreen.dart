import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'borrow_constants.dart';

class AdminBorrowPendingScreen extends StatelessWidget {
  const AdminBorrowPendingScreen({super.key});

  Future<void> _approve(BuildContext context, DocumentReference ref, String depositText) async {
    final dep = double.tryParse(depositText);
    if (dep == null || dep <= 0) {
      Get.snackbar("Invalid deposit", "Enter a valid security deposit amount.");
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Approve request?"),
        content: Text("Security deposit will be set to $dep OMR.\nContinue?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Approve")),
        ],
      ),
    );

    if (ok != true) return;

    await ref.update({
      "securityDeposit": dep,
      "depositFinalized": true,
      "status": BorrowStatuses.approved,
    });

    Get.snackbar("Approved", "Request approved successfully",
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Future<void> _reject(BuildContext context, DocumentReference ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject request?"),
        content: const Text("User will be notified via status update."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Reject"),
          ),
        ],
      ),
    );
    if (ok != true) return;

    await ref.update({"status": BorrowStatuses.rejected});
    Get.snackbar("Rejected", "Request rejected", backgroundColor: Colors.red, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('borrow_requests')
        .where('status', isEqualTo: BorrowStatuses.pending)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text("Pending Borrow Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text("No pending requests."));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              final d = doc.data() as Map<String, dynamic>;
              final depCtrl = TextEditingController(text: "5"); // default suggestion

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
                      const SizedBox(height: 4),
                      Text("User: ${d['userEmail'] ?? ""}"),
                      Text("Borrow: ${d['borrowDate'] ?? "N/A"}"),
                      Text("Return: ${d['returnDate'] ?? "N/A"}"),
                      const SizedBox(height: 10),
                      TextField(
                        controller: depCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Security Deposit (OMR)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _approve(context, doc.reference, depCtrl.text),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text("Approve"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _reject(context, doc.reference),
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text("Reject"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            ),
                          ),
                        ],
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

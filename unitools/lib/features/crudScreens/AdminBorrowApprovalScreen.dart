import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminBorrowApprovalScreen extends StatelessWidget {
  const AdminBorrowApprovalScreen({super.key});

  Future<void> _updateStatus(String id, String status) async {
    await FirebaseFirestore.instance
        .collection('borrow_requests')
        .doc(id)
        .update({'status': status});
    Get.snackbar(
      "Updated",
      "Borrow request $status successfully",
      backgroundColor: status == 'Approved' ? Colors.green : Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return "N/A";
    try {
      return DateFormat('dd MMM yyyy').format(DateFormat('dd MMM yyyy').parse(value.toString()));
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Borrow Requests"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A7FD0), Color(0xFF879AF2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrow_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
                child: Text("No borrow requests yet.",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w500)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;

              final status = data['status'] ?? 'Pending';
              final color = status == 'Approved'
                  ? Colors.green
                  : status == 'Rejected'
                  ? Colors.redAccent
                  : Colors.orange;

              return Card(
                elevation: 5,
                shadowColor: color.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(data['itemName'] ?? '',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(status,
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("User: ${data['userEmail'] ?? ''}",
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text("Borrow Date: ${_formatDate(data['borrowDate'])}"),
                      Text("Return Date: ${_formatDate(data['returnDate'])}"),
                      Text("Deposit: ${data['deposit']} OMR"),
                      const SizedBox(height: 12),
                      if (status == 'Pending')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateStatus(id, "Approved"),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text("Approve"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateStatus(id, "Rejected"),
                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text("Reject"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            status == "Approved"
                                ? "✅ Approved"
                                : "❌ Rejected",
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
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

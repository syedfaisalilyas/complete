import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'UserBorrowPaymentScreen.dart';
import 'borrow_constants.dart';
import 'BorrowFeedbackScreen.dart';

class UserBorrowStatusScreen extends StatelessWidget {
  final String requestId;
  const UserBorrowStatusScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('borrow_requests').doc(requestId);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ref.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(body: Center(child: Text("Request not found.")));
        }

        final data = snap.data!.data()!;
        final status = (data['status'] ?? BorrowStatuses.pending).toString();
        final color = BorrowStatuses.color(status);

        final rent = (data['price'] ?? 0).toString();
        final dep = (data['securityDeposit'] ?? 0).toString();

        return Scaffold(
          backgroundColor: const Color(0xFF6A7FD0),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text("Borrow Status",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      // Item card
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: (data['image'] != null && (data['image'] as String).isNotEmpty)
                                    ? Image.network(data['image'], width: 80, height: 80, fit: BoxFit.cover)
                                    : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported_outlined),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['itemName'] ?? "",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text("Rent: $rent OMR"),
                                    Text("Deposit: $dep OMR"),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            BorrowStatuses.label(status),
                                            style: TextStyle(color: color, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Dates
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            children: [
                              _row("Borrow Date", (data['borrowDate'] ?? "N/A").toString()),
                              const SizedBox(height: 6),
                              _row("Return Date", (data['returnDate'] ?? "N/A").toString()),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Status message / pickup / refund
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Updates", style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              if (status == BorrowStatuses.pending)
                                const Text("Your request is pending. Admin will review it soon."),
                              if (status == BorrowStatuses.rejected)
                                Text("Your request was rejected.", style: TextStyle(color: Colors.red.shade700)),
                              if (status == BorrowStatuses.approved)
                                const Text("Approved! Please proceed with payment to get pickup details."),
                              if (status == BorrowStatuses.paid) ...[
                                const Text("Payment received. Pickup details are below:"),
                                const SizedBox(height: 10),
                                _row("Order Number", (data['orderNumber'] ?? "Will be assigned").toString()),
                                _row("Pickup Location", (data['pickupLocation'] ?? "Will be shared").toString()),
                                _row("Pickup Time", (data['pickupTime'] ?? "Will be shared").toString()),
                              ],
                              if (status == BorrowStatuses.collected)
                                const Text("Item collected. Please return it on time."),
                              if (status == BorrowStatuses.completed) ...[
                                const Text("Completed. Refund summary:"),
                                const SizedBox(height: 10),
                                _row("Deducted", "${data['deductedAmount'] ?? 0} OMR"),
                                _row("Refunded", "${data['refundAmount'] ?? 0} OMR"),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ACTIONS
                      if (status == BorrowStatuses.approved)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => UserBorrowPaymentScreen(
                                requestRef: ref,
                                requestData: data,
                              ));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A7FD0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "Proceed to Payment",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                      if (status == BorrowStatuses.completed) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => BorrowFeedbackScreen(requestId: requestId));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              "Give Feedback",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(String a, String b) {
    return Row(
      children: [
        Expanded(child: Text(a, style: const TextStyle(color: Colors.black54))),
        Text(b, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

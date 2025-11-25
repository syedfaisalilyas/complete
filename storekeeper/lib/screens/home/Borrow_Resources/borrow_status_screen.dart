import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'BorrowFeedbackScreen.dart';

class BorrowStatusScreen extends StatelessWidget {
  final Map<String, dynamic> requestData;
  const BorrowStatusScreen({super.key, required this.requestData});

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final status = requestData['status'] ?? "Pending";
    final color = status == "Approved"
        ? Colors.green
        : status == "Rejected"
        ? Colors.red
        : Colors.orange;

    return Scaffold(
      backgroundColor: const Color(0xFF6A7FD0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Uni Tools app",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ---------- ORDER DETAILS ----------
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Order Details",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey.shade800,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (requestData['image'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  requestData['image'],
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const Icon(Icons.shopping_bag_outlined,
                                  size: 60, color: Colors.grey),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(requestData['itemName'] ?? "",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    "Price: ${requestData['price']} OMR",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text("Status: $status",
                                      style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            if (status == "Approved")
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 26)
                            else if (status == "Rejected")
                              const Icon(Icons.cancel,
                                  color: Colors.red, size: 26)
                            else
                              const Icon(Icons.hourglass_bottom,
                                  color: Colors.orange, size: 26),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Divider(color: Colors.grey.shade300),
                        Text(
                            "Borrow Duration: ${formatDate(requestData['borrowDate'])}",
                            style: const TextStyle(fontSize: 13)),
                        Text(
                            "Return Due: ${formatDate(requestData['returnDate'])}",
                            style: const TextStyle(fontSize: 13)),
                        if (requestData['condition'] != null)
                          Text("Item Condition: ${requestData['condition']}",
                              style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---------- WALLET / DEPOSIT ----------
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status == "Approved"
                              ? "Wallet Summary"
                              : "Deposit Information",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.blueGrey.shade800,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        if (status == "Approved") ...[
                          Text("Current Balance: OMR 6.500",
                              style: const TextStyle(fontSize: 14)),
                          Text(
                              "Deposit Held for This Order: OMR ${requestData['deposit']}",
                              style: const TextStyle(fontSize: 14)),
                          const Text("Available Balance: OMR 4.300",
                              style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A7FD0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              minimumSize: const Size(double.infinity, 45),
                            ),
                            child: const Text("Checkout",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ] else ...[
                          Text("1 - Security Deposit: OMR ${requestData['deposit']}",
                              style: const TextStyle(fontSize: 14)),
                          const Text("2 - Refund Condition:",
                              style: TextStyle(fontSize: 14)),
                          const Text(
                              "   This amount will be refunded after successful return in good condition.",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                          const SizedBox(height: 5),
                          Text("3 - Refund Status: Pending",
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ⭐⭐⭐ GIVE FEEDBACK BUTTON (NEW)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => BorrowFeedbackScreen(
                          requestId: requestData["id"],
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Give Feedback",
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
    );
  }
}

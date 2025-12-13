import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentBorrowPaymentScreen extends StatelessWidget {
  final String requestId;
  const StudentBorrowPaymentScreen({super.key, required this.requestId});

  static const primary = Color(0xFF6A7FD0);
  static const secondary = Color(0xFF879AF2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Payment"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [primary, secondary]),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('borrow_requests')
            .doc(requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Request not found"));
          }

          final d = snapshot.data!.data() as Map<String, dynamic>;

          final status =
          (d['status'] ?? '').toString().toUpperCase();
          bool depositFinalized = d['depositFinalized'] == true ;

          // ✅ BLOCK PAYMENT IF NOT READY
          if (status != "APPROVED") {
            return const _InfoState(
              message: "Waiting for admin approval",
              icon: Icons.hourglass_empty,
            );
          }
print('depositFinalized----------->$depositFinalized');
          if (!depositFinalized) {
            return const _InfoState(
              message: "Waiting for admin to finalize security deposit",
              icon: Icons.lock_clock,
            );
          }

          if (status == "PAID") {
            return const _InfoState(
              message: "Payment already completed",
              icon: Icons.check_circle,
            );
          }

          // ✅ SAFE NUMBERS (FIXES DOUBLE / INT CRASH)
          final num price = (d['price'] ?? 0);
          final num deposit = (d['securityDeposit'] ?? 0);
          final num total = price + deposit;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SummaryCard(
                  itemName: d['itemName'] ?? '',
                  image: d['image'] ?? '',
                  price: price,
                  deposit: deposit,
                  total: total,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _payNow(context, d),
                    child: const Text(
                      "Pay Now",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _payNow(
      BuildContext context,
      Map<String, dynamic> d,
      ) async {
    final num price = (d['price'] ?? 0);
    final num deposit = (d['securityDeposit'] ?? 0);
    final num total = price + deposit;

    // 🔐 Prevent double payment
    final doc =
    await FirebaseFirestore.instance
        .collection('borrow_requests')
        .doc(requestId)
        .get();

    if (doc.exists && doc['status'] == "PAID") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment already completed")),
      );
      return;
    }

    // ✅ CREATE PAYMENT RECORD
    await FirebaseFirestore.instance
        .collection('payments')
        .add({
      "requestId": requestId,
      "userId": d['userId'],
      "amount": total.toDouble(),
      "rent": price.toDouble(),
      "securityDeposit": deposit.toDouble(),
      "status": "PAID",
      "method": "demo",
      "createdAt": FieldValue.serverTimestamp(),
    });

    // ✅ UPDATE BORROW REQUEST
    await FirebaseFirestore.instance
        .collection('borrow_requests')
        .doc(requestId)
        .update({
      "status": "PAID",
      "paidAt": FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }
}

class _SummaryCard extends StatelessWidget {
  final String itemName;
  final String image;
  final num price;
  final num deposit;
  final num total;

  const _SummaryCard({
    required this.itemName,
    required this.image,
    required this.price,
    required this.deposit,
    required this.total,
  });

  String _fmt(num v) => v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _row("Rent", "${_fmt(price)} OMR"),
            _row("Security Deposit", "${_fmt(deposit)} OMR"),
            const Divider(),
            _row(
              "Total Payable",
              "${_fmt(total)} OMR",
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
          ),
        ],
      ),
    );
  }
}
class _InfoState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _InfoState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

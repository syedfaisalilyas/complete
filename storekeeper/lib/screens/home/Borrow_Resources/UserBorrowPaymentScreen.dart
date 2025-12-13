import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'borrow_constants.dart';

class UserBorrowPaymentScreen extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> requestRef;
  final Map<String, dynamic> requestData;

  const UserBorrowPaymentScreen({
    super.key,
    required this.requestRef,
    required this.requestData,
  });

  @override
  State<UserBorrowPaymentScreen> createState() => _UserBorrowPaymentScreenState();
}

class _UserBorrowPaymentScreenState extends State<UserBorrowPaymentScreen> {
  bool _agree = false;
  bool _loading = false;

  num get rent => (widget.requestData['price'] ?? 0);
  num get deposit => (widget.requestData['securityDeposit'] ?? 0);
  num get total => rent + deposit;

  Future<void> _confirmPayment() async {
    if (!_agree) {
      Get.snackbar("Confirm required", "Please accept the payment terms first.");
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(widget.requestRef);
        final data = snap.data() as Map<String, dynamic>?;

        if (data == null) throw "Request not found";
        final status = (data['status'] ?? BorrowStatuses.pending).toString();

        if (status != BorrowStatuses.approved) {
          throw "Payment is allowed only after approval.";
        }

        // ✅ mark paid
        tx.update(widget.requestRef, {
          "status": BorrowStatuses.paid,
          "paidAt": FieldValue.serverTimestamp(),
          "paymentMethod": "MOCK",
          "transactionId": "TX-${DateTime.now().millisecondsSinceEpoch}",
          // Admin will fill pickup details later (or you can auto-fill)
        });
      });

      Get.back();
      Get.snackbar("✅ Payment successful", "Now wait for pickup details.",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Payment failed", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text("Order Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _row("Rent", "$rent OMR"),
                _row("Security Deposit", "$deposit OMR"),
                const Divider(height: 24),
                _row("Total", "$total OMR", bold: true),
                const SizedBox(height: 16),

                CheckboxListTile(
                  value: _agree,
                  onChanged: (v) => setState(() => _agree = v ?? false),
                  title: const Text("I understand deposit will be refunded after return (damage may be deducted)."),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _confirmPayment,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Confirm Payment"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String a, String b, {bool bold = false}) {
    return Row(
      children: [
        Expanded(child: Text(a, style: TextStyle(color: Colors.black54, fontWeight: bold ? FontWeight.bold : FontWeight.normal))),
        Text(b, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }
}

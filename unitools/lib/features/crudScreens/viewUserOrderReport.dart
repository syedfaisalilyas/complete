import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewUserOrderReportScreen extends StatefulWidget {
  const ViewUserOrderReportScreen({Key? key}) : super(key: key);

  @override
  State<ViewUserOrderReportScreen> createState() =>
      _ViewUserOrderReportScreenState();
}

class _ViewUserOrderReportScreenState extends State<ViewUserOrderReportScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final List<AnimationController> _cardControllers = [];

  String _selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _ensureCardControllers(int count) {
    if (_cardControllers.length == count) return;
    for (var c in _cardControllers) {
      c.dispose();
    }
    _cardControllers.clear();
    for (int i = 0; i < count; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500 + i * 60),
      );
      _cardControllers.add(controller);
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) controller.forward();
      });
    }
  }

  Color _statusColor(String s) {
    final st = s.toLowerCase();
    if (st.contains('complete') || st.contains('paid')) return Colors.green;
    if (st.contains('pending') || st.contains('wait')) return Colors.orange;
    if (st.contains('ship')) return Colors.blue;
    if (st.contains('cancel')) return Colors.red;
    return Colors.grey;
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _filterChip("all", Icons.list_alt, Colors.deepPurple),
              _filterChip("pending", Icons.schedule, Colors.orange),
              _filterChip("confirmed", Icons.check_circle_outline, Colors.blue),
              _filterChip("completed", Icons.done_all, Colors.green),
              _filterChip("cancelled", Icons.cancel, Colors.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String value, IconData icon, Color color) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = value);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              value[0].toUpperCase() + value.substring(1),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final h = mq.size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.04, vertical: w * 0.03),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text("User Orders Report",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: _openFilterDialog,
                    ),
                  ],
                ),
              ),

              // Orders List
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orders')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No orders found"));
                        }

                        var docs = snapshot.data!.docs;

                        // Filter by status
                        if (_selectedFilter != "all") {
                          docs = docs.where((d) {
                            final status = (d['status'] ??
                                d['orderStatus'] ??
                                d['OrderConfimation'] ??
                                "")
                                .toString()
                                .toLowerCase();
                            return status.contains(_selectedFilter);
                          }).toList();
                        }

                        _ensureCardControllers(docs.length);

                        return ListView.builder(
                          padding: EdgeInsets.all(w * 0.05),
                          itemCount: docs.length,
                          itemBuilder: (context, i) {
                            final doc = docs[i];
                            final data =
                            Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
                            final total = (data['totalAmount'] ??
                                data['totalPrice'] ??
                                data['total'] ??
                                0)
                                .toDouble();
                            final status = (data['status'] ??
                                data['orderStatus'] ??
                                "pending")
                                .toString();
                            final items = data['items'] ?? [];
                            final firstItemName = items is List && items.isNotEmpty
                                ? (items[0]['name'] ?? 'Item')
                                : 'Item';
                            final ts = data['timestamp'];
                            final dateStr = ts is Timestamp
                                ? DateFormat('MMM dd, yyyy').format(ts.toDate())
                                : "-";

                            final controller = _cardControllers[i];
                            final slideAnim = Tween<Offset>(
                                begin: const Offset(1, 0), end: Offset.zero)
                                .animate(CurvedAnimation(
                                parent: controller, curve: Curves.elasticOut));

                            return SlideTransition(
                              position: slideAnim,
                              child: FadeTransition(
                                opacity: controller,
                                child: _buildOrderCard(
                                  orderId: doc.id,
                                  firstItem: firstItemName,
                                  total: total,
                                  status: status,
                                  date: dateStr,
                                  w: w,
                                  data: data,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required String firstItem,
    required double total,
    required String status,
    required String date,
    required double w,
    required Map<String, dynamic> data,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(w * 0.04),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo,
          child: Text(firstItem[0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(firstItem, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order ID: $orderId", style: const TextStyle(fontSize: 12)),
            Text("Date: $date", style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${total.toStringAsFixed(2)} OMR",
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(status,
                style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12)),
          ],
        ),
        onTap: () => _showOrderDetails(data),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> data) {
    final items = (data['items'] ?? []) as List;
    final cardName = data['cardName'] ?? '-';
    final paymentMethod = data['paymentMethod'] ?? '-';
    final totalAmount =
    (data['totalAmount'] ?? data['totalPrice'] ?? data['total'] ?? 0).toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape:
      const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)))),
              const Text("Order Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              ...items.map((item) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: item['imageUrl'] != null
                      ? Image.network(item['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.shopping_bag_outlined),
                  title: Text(item['name'] ?? "Item"),
                  subtitle: Text(
                      "Qty: ${item['quantity'] ?? 1} • Price: ${item['price']} OMR"),
                );
              }),
              const Divider(),
              Text("Card: $cardName"),
              Text("Payment: $paymentMethod"),
              const SizedBox(height: 8),
              Text("Total: ${totalAmount.toStringAsFixed(2)} OMR",
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

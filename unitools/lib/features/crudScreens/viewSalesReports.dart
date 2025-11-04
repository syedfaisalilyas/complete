import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MasterSalesReportScreen extends StatefulWidget {
  const MasterSalesReportScreen({super.key});

  @override
  State<MasterSalesReportScreen> createState() =>
      _MasterSalesReportScreenState();
}

class _MasterSalesReportScreenState extends State<MasterSalesReportScreen> {
  bool _loading = true;

  List<Map<String, dynamic>> borrowRequests = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> users = [];

  double totalOrderRevenue = 0;
  double totalBorrowDeposit = 0;
  double totalRevenue = 0;

  Map<String, double> dailyRevenue = {};
  int totalApprovedBorrows = 0;
  int totalRejectedBorrows = 0;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      final borrowSnap =
      await FirebaseFirestore.instance.collection('borrow_requests').get();
      final orderSnap =
      await FirebaseFirestore.instance.collection('orders').get();
      final productSnap =
      await FirebaseFirestore.instance.collection('products').get();
      final userSnap =
      await FirebaseFirestore.instance.collection('users').get();

      borrowRequests =
          borrowSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
      orders =
          orderSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
      products =
          productSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
      users =
          userSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList();

      // ======= CALCULATE TOTALS =======
      totalOrderRevenue = orders.fold(
          0.0, (sum, e) => sum + (e['totalAmount'] ?? 0).toDouble());

      totalBorrowDeposit = borrowRequests.fold(
          0.0, (sum, e) => sum + (e['deposit'] ?? 0).toDouble());

      totalRevenue = totalOrderRevenue + totalBorrowDeposit;

      totalApprovedBorrows = borrowRequests
          .where((e) => (e['status'] ?? '') == 'Approved')
          .length;
      totalRejectedBorrows = borrowRequests
          .where((e) => (e['status'] ?? '') == 'Rejected')
          .length;

      // ======= CHART DATA =======
      for (var order in orders) {
        final ts = order['timestamp'];
        if (ts is Timestamp) {
          final date = ts.toDate();
          final key = DateFormat('MMM dd').format(date);
          final val = (order['totalAmount'] ?? 0).toDouble();
          dailyRevenue[key] = (dailyRevenue[key] ?? 0) + val;
        }
      }

      for (var borrow in borrowRequests) {
        final ts = borrow['createdAt'];
        if (ts is Timestamp) {
          final date = ts.toDate();
          final key = DateFormat('MMM dd').format(date);
          final val = (borrow['deposit'] ?? 0).toDouble();
          dailyRevenue[key] = (dailyRevenue[key] ?? 0) + val;
        }
      }

      setState(() => _loading = false);
    } catch (e) {
      print('❌ Error fetching data: $e');
    }
  }

  // Summary Box
  Widget _summaryCard(
      String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  // Line Chart Widget
  Widget _buildChart() {
    final keys = dailyRevenue.keys.toList();
    final spots = [
      for (int i = 0; i < keys.length; i++)
        FlSpot(i.toDouble(), dailyRevenue[keys[i]] ?? 0)
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    if (value.toInt() >= keys.length) return const SizedBox();
                    return Text(keys[value.toInt()],
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black54));
                  })),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (val, _) => Text(
                    val.toInt().toString(),
                    style: const TextStyle(
                        fontSize: 10, color: Colors.black54),
                  ))),
          rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF6A7FD0),
            barWidth: 4,
            belowBarData: BarAreaData(
                show: true, color: const Color(0xFF6A7FD0).withOpacity(0.2)),
            dotData: const FlDotData(show: false),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A7FD0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Full Business Report",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Summary Row 1
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _summaryCard("Total Revenue",
                      "${totalRevenue.toStringAsFixed(2)} OMR",
                      Colors.teal,
                      Icons.attach_money_rounded),
                  _summaryCard("Orders", orders.length.toString(),
                      Colors.indigo, Icons.shopping_cart),
                  _summaryCard("Borrows", borrowRequests.length.toString(),
                      Colors.orange, Icons.handshake),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Summary Row 2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _summaryCard("Approved Borrows",
                      totalApprovedBorrows.toString(), Colors.green,
                      Icons.check_circle),
                  _summaryCard("Rejected Borrows",
                      totalRejectedBorrows.toString(), Colors.red,
                      Icons.cancel),
                  _summaryCard("Users", users.length.toString(),
                      Colors.purple, Icons.people_alt_rounded),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Chart
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              height: 250,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Revenue Overview",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Expanded(child: _buildChart()),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Top Products
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Products Summary",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  ...products.take(5).map((p) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                        NetworkImage(p['image'] ?? ''),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      title: Text(p['name'] ?? 'Unknown'),
                      subtitle: Text(
                          "${p['category']} • ${p['price']} OMR • Stock: ${p['stock']}"),
                      trailing: Text(p['approvalStatus'] ?? '',
                          style: TextStyle(
                              color: (p['approvalStatus'] == 'Pending')
                                  ? Colors.orange
                                  : Colors.green)),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Borrow Records
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Recent Borrow Requests",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Divider(),
                  ...borrowRequests.take(5).map((b) {
                    DateTime? date;
                    if (b['createdAt'] is Timestamp) {
                      date = (b['createdAt'] as Timestamp).toDate();
                    }
                    return ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.handshake,
                              color: Colors.white)),
                      title: Text(b['itemName'] ?? 'Unknown Item'),
                      subtitle: Text(
                          "${b['status']} • ${b['userEmail']} • ${date != null ? DateFormat('MMM dd').format(date) : ''}"),
                      trailing: Text(
                          "${b['deposit'] ?? 0} OMR",
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

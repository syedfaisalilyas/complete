import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:storekeeper/screens/home/Borrow_Resources/Borrow_Products_Screen.dart';
import '../../../core/app_styles.dart';
import '../../../core/app_theme.dart';
import '../../../services/tracking_service.dart';

class BorrowProductDetailScreen extends StatefulWidget {
  final String productId;
  const BorrowProductDetailScreen({super.key, required this.productId});

  @override
  State<BorrowProductDetailScreen> createState() =>
      _BorrowProductDetailScreenState();
}

class _BorrowProductDetailScreenState extends State<BorrowProductDetailScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
    "https://uni-tool-app-default-rtdb.asia-southeast1.firebasedatabase.app/",
  ).ref();

  Map<String, dynamic>? product;
  Map<String, dynamic>? productDetail;

  String? selectedCapacity;
  String? selectedColor;

  bool isLoading = true;

  // -------- NEW: Borrow duration state --------
  DateTime? _selectedDate;                // Calendar date
  int _selectedHour24 = 14;               // 1..24 (default 14 => 2 PM)
  int _durHours = 1;                      // Duration hours
  int _durMinutes = 0;                    // Duration minutes (0..59)
  double _computedPrice = 0.0;            // Calculated price based on duration
  // --------------------------------------------

  @override
  void initState() {
    super.initState();
    fetchProductData();
  }

  Future<void> fetchProductData() async {
    try {
      debugPrint("🔄 Fetching Borrow Product for productId: ${widget.productId}");

      final productSnap =
      await dbRef.child("borrowProducts/${widget.productId}").get();
      debugPrint("📦 Borrow Product Snapshot: ${productSnap.value}");

      if (!productSnap.exists || productSnap.value == null) {
        debugPrint(
            "❌ Borrow Product not found at path: borrowProducts/${widget.productId}");
        setState(() => isLoading = false);
        return;
      }

      final productData =
      Map<String, dynamic>.from(productSnap.value as Map<dynamic, dynamic>);

      final detailSnap =
      await dbRef.child("borrowProductDetails/${widget.productId}").get();
      debugPrint("📦 Borrow Product Details Snapshot: ${detailSnap.value}");

      Map<String, dynamic>? detailData;
      if (detailSnap.exists && detailSnap.value != null) {
        detailData = Map<String, dynamic>.from(
            detailSnap.value as Map<dynamic, dynamic>);
      }

      setState(() {
        product = productData;
        TrackingService.trackUserActivity(
          productId: widget.productId,
          category: product?["category"] ?? "",
          name: product?["name"] ?? "",
          viewed: true,
        );

        productDetail = detailData;

        if (detailData != null) {
          if (detailData["capacity"] != null &&
              (detailData["capacity"] as List).isNotEmpty) {
            selectedCapacity = detailData["capacity"][0].toString();
          }
          if (detailData["color"] != null &&
              (detailData["color"] as List).isNotEmpty) {
            selectedColor = detailData["color"][0].toString();
          }
        }

        // defaults for borrow section
        _selectedDate = DateTime.now();
        _recomputePrice();

        isLoading = false;
      });

      debugPrint("✅ Borrow Product Loaded: $product");
      debugPrint("✅ Borrow ProductDetails Loaded: $productDetail");
    } catch (e) {
      debugPrint("❌ Error fetching borrow product data: $e");
      setState(() => isLoading = false);
    }
  }

  void selectCapacity(String capacity) {
    setState(() => selectedCapacity = capacity);
    debugPrint("🔄 Capacity Selected: $capacity");
  }

  void selectColor(String color) {
    setState(() => selectedColor = color);
    debugPrint("🎨 Color Selected: $color");
  }

  // ✅ Always pick image from productDetails only
  String getValidImageUrl() {
    final img = (productDetail?["imageUrl"] ?? "").toString().trim();
    if (img.isEmpty) {
      return "https://via.placeholder.com/150"; // fallback
    }
    return img;
  }

  // ---------- PRICE HELPERS ----------
  double _parseHourlyPrice() {
    // product["price"] could be like "1.29 OMR" or "1.29"
    final raw = (product?["price"] ?? "0").toString();
    final numeric = RegExp(r'(\d+(\.\d+)?)').firstMatch(raw)?.group(1) ?? "0";
    return double.tryParse(numeric) ?? 0.0;
  }

  void _recomputePrice() {
    final perHour = _parseHourlyPrice();
    final totalHours = _durHours + (_durMinutes / 60.0);
    setState(() {
      _computedPrice = (perHour * totalHours);
    });
  }
  // -----------------------------------

  // ✅ Firestore Add to Cart
  Future<void> addToCart() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final cartRef = FirebaseFirestore.instance
          .collection("borrowCart") // separate collection for borrow
          .doc(userId)
          .collection("items");

      await cartRef.doc(widget.productId).set({
        "productId": widget.productId,
        "name": product?["name"] ?? "No Name",
        "pricePerHour": _parseHourlyPrice(),
        "calculatedPrice": _computedPrice,
        "imageUrl": getValidImageUrl(),
        "capacity": selectedCapacity,
        "color": selectedColor,
        "quantity": 1,
        "borrowDate": _selectedDate,
        "borrowStartHour24": _selectedHour24,
        "borrowDurationHours": _durHours,
        "borrowDurationMinutes": _durMinutes,
        "createdAt": FieldValue.serverTimestamp(),
      });

      TrackingService.trackUserActivity(
        productId: widget.productId,
        category: product?["category"] ?? "",
        name: product?["name"] ?? "",
        borrowed: true,
        addedToCart: true,
      );


      debugPrint("🛒 Borrow Product added to Firestore cart!");
      Get.snackbar("Success", "Borrow Product added to cart",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      debugPrint("❌ Error adding borrow product to cart: $e");
      Get.snackbar("Error", "Failed to add borrow product to cart",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ---------- PICKERS ----------
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.button,
              onPrimary: Colors.white,
              onSurface: AppTheme.secondaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showHourPicker() {
    int tempHour = _selectedHour24;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return _cupertinoSheet(
          title: "Select Time",
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: CupertinoPicker(
              scrollController:
              FixedExtentScrollController(initialItem: _selectedHour24 - 1),
              itemExtent: 36,
              onSelectedItemChanged: (i) => tempHour = i + 1,
              children: List.generate(24, (i) => Center(child: Text("${i + 1}"))),
            ),
          ),
          onOk: () {
            setState(() => _selectedHour24 = tempHour);
            Navigator.of(ctx).pop();
          },
        );
      },
    );
  }


  void _showDurationPicker() {
    int tempH = _durHours;
    int tempM = _durMinutes;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return _cupertinoSheet(
          title: "Select Duration",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: _durHours),
                  itemExtent: 36,
                  onSelectedItemChanged: (i) => tempH = i,
                  children: List.generate(25, (i) => Center(child: Text("$i h"))),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.35,
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: _durMinutes),
                  itemExtent: 36,
                  onSelectedItemChanged: (i) => tempM = i,
                  children: List.generate(60, (i) => Center(child: Text("$i m"))),
                ),
              ),
            ],
          ),
          onOk: () {
            setState(() {
              _durHours = tempH;
              _durMinutes = tempM;
            });
            _recomputePrice();
            Navigator.of(ctx).pop();
          },
        );
      },
    );
  }


  Widget _cupertinoSheet({
    required String title,
    required Widget child,
    required VoidCallback onOk,
  }) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
          ),
          Divider(height: 1),

          // Picker Area
          Expanded(child: child),

          // Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: onOk,
                child: Text("OK"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -----------------------------------

  String _formatDate(DateTime? d) {
    if (d == null) return "Select date";
    // Example: May 15, 2025
    return "${_monthName(d.month)} ${d.day}, ${d.year}";
    // Optionally show weekday too.
  }

  String _monthName(int m) {
    const months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    return months[m - 1];
  }

  String _formatHourAmPm(int h24) {
    // 1..24 -> 0..23 map
    final hour0_23 = (h24 % 24);
    final isNoonMidnightEdge = hour0_23 == 0 || hour0_23 == 12;
    final hour12 = isNoonMidnightEdge ? 12 : hour0_23 % 12;
    final period = hour0_23 < 12 ? "AM" : "PM";
    return "$hour12$period";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (product == null) {
      return Scaffold(
        body: Center(
          child: Text("❌ Borrow Product not found",
              style: AppStyles.Boldtext.copyWith(color: Colors.red)),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const BorrowITProductsScreen());
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.background,
          ),
          child: SafeArea(
            child: Column(
              children: [
                AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppTheme.primaryColor),
                    onPressed: () {
                      Get.offAll(() => const BorrowITProductsScreen());
                    },
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Center(
                          child: Image.network(
                            getValidImageUrl(),
                            height: 180,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight:
                            MediaQuery.of(context).size.height * 0.68,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product?["name"] ?? "No Name",
                                style: AppStyles.medium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Icon(Icons.star,
                                      color: AppTheme.button, size: 18),
                                  Icon(Icons.star,
                                      color: AppTheme.button, size: 18),
                                  Icon(Icons.star,
                                      color: AppTheme.button, size: 18),
                                  Icon(Icons.star,
                                      color: AppTheme.button, size: 18),
                                  Icon(Icons.star_half,
                                      color: AppTheme.button, size: 18),
                                  SizedBox(width: 6),
                                  Text("30 reviews",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                productDetail?["description"] ??
                                    product?["description"] ??
                                    "No description available",
                                style: const TextStyle(
                                    color: AppTheme.secondaryColor),
                              ),

                              const SizedBox(height: 20),
                              if (productDetail?["capacity"] != null) ...[
                                Text("Capacity:",
                                    style: AppStyles.Boldtext.copyWith(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 10,
                                  children:
                                  (productDetail!["capacity"] as List)
                                      .map<Widget>((cap) {
                                    return buildCapacityButton(
                                      cap.toString(),
                                      selectedCapacity == cap.toString(),
                                          () => selectCapacity(cap.toString()),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                              ],
                              if (productDetail?["color"] != null) ...[
                                Text("Color:",
                                    style: AppStyles.Boldtext.copyWith(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 10,
                                  children: (productDetail!["color"] as List)
                                      .map<Widget>((clr) {
                                    return buildColorButton(
                                      clr.toString(),
                                      selectedColor == clr.toString(),
                                          () => selectColor(clr.toString()),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 20),
                              ],

                              // ------------------- PRICE -------------------
                              Text(
                                "Price: ${product?["price"] ?? "N/A"}",
                                style: AppStyles.medium
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              // ------------------- BORROW DURATION SECTION -------------------
                              Text(
                                "Borrow Duration:",
                                style: AppStyles.Boldtext
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),

                              // Date Row
                              _tileRow(
                                label: "Date:",
                                value: _formatDate(_selectedDate),
                                icon: Icons.calendar_today_rounded,
                                onTap: _pickDate,
                              ),
                              const SizedBox(height: 10),

                              // Time Row
                              _tileRow(
                                label: "Time:",
                                value: _formatHourAmPm(_selectedHour24),
                                icon: Icons.access_time_rounded,
                                onTap: _showHourPicker,
                              ),
                              const SizedBox(height: 10),

                              // Duration Row
                              _tileRow(
                                label: "Duration:",
                                value:
                                "${_durHours}h ${_durMinutes}m",
                                icon: Icons.hourglass_bottom_rounded,
                                onTap: _showDurationPicker,
                              ),
                              const SizedBox(height: 12),

                              // Price based on duration
                              Text(
                                "Price based on duration : ${_computedPrice.toStringAsFixed(3)} OMR for "
                                    "${_durHours > 0 ? "${_durHours}h " : ""}"
                                    "${_durMinutes > 0 ? "${_durMinutes}m" : _durHours == 0 ? "0m" : ""}",
                                style: const TextStyle(
                                  color: AppTheme.secondaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.button,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  onPressed: addToCart,
                                  child: const Text(
                                    "Add to cart",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- SMALL UI HELPERS ----------
  Widget _tileRow({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Text(label, style: AppStyles.Boldtext.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(color: AppTheme.secondaryColor),
                    ),
                  ),
                  Icon(icon, size: 18, color: AppTheme.secondaryColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  // --------------------------------------

  Widget buildCapacityButton(
      String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade100 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey,
          ),
        ),
        child: Text(
          text,
          style: AppStyles.Regulartext,
        ),
      ),
    );
  }

  Widget buildColorButton(String imageUrl, bool selected, VoidCallback onTap) {
    final validUrl =
    imageUrl.trim().isNotEmpty ? imageUrl : "https://via.placeholder.com/50";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.network(
          validUrl,
          height: 50,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.color_lens, size: 30),
        ),
      ),
    );
  }
}

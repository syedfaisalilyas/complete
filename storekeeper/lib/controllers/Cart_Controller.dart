import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:math';

class CartController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get userId => _auth.currentUser!.uid;

  var cartItems = <Map<String, dynamic>>[].obs;
  var borrowCartItems = <Map<String, dynamic>>[].obs;

  var subTotal = 0.0.obs;
  var vat = 0.0.obs;
  var totalPrice = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    // ✅ Normal cart listener
    _firestore
        .collection('cart')
        .doc(userId)
        .collection('items')
        .snapshots()
        .listen((snapshot) {
      cartItems.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _calculateTotals();
    });

    // ✅ Borrow cart listener
    _firestore
        .collection('borrowCart')
        .doc(userId)
        .collection('items')
        .snapshots()
        .listen((snapshot) {
      borrowCartItems.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _calculateTotals();
    });
  }

  void _calculateTotals() {
    double subtotal = 0;

    // ✅ Normal cart subtotal
    for (var data in cartItems) {
      subtotal += _calculateItemPrice(data);
    }

    // ✅ Borrow cart subtotal
    for (var data in borrowCartItems) {
      subtotal += _calculateItemPrice(data);
    }

    subTotal.value = subtotal;
    vat.value = subtotal * 0.05;
    totalPrice.value = subtotal + vat.value;
  }

  double _calculateItemPrice(Map<String, dynamic> data) {
    // ✅ Borrow item (calculatedPrice use karega)
    if (data.containsKey("calculatedPrice")) {
      final borrowPriceRaw = data["calculatedPrice"];
      double borrowPrice = 0;

      if (borrowPriceRaw is int) {
        borrowPrice = borrowPriceRaw.toDouble();
      } else if (borrowPriceRaw is double) {
        borrowPrice = borrowPriceRaw;
      } else if (borrowPriceRaw is String) {
        borrowPrice = double.tryParse(borrowPriceRaw) ?? 0;
      }

      final qtyRaw = data['quantity'] ?? 1;
      int qty = (qtyRaw is int) ? qtyRaw : int.tryParse(qtyRaw.toString()) ?? 1;

      return borrowPrice * qty;
    }

    // ✅ Buy item (normal price)
    final priceRaw = data['price'] ?? "0";
    double price = 0;

    if (priceRaw is int) {
      price = priceRaw.toDouble();
    } else if (priceRaw is double) {
      price = priceRaw;
    } else if (priceRaw is String) {
      price = double.tryParse(
        priceRaw.replaceAll(RegExp(r'[^0-9.]'), ""),
      ) ?? 0;
    }

    final qtyRaw = data['quantity'] ?? 1;
    int qty = (qtyRaw is int) ? qtyRaw : int.tryParse(qtyRaw.toString()) ?? 1;

    return price * qty;
  }

  Future<void> clearCart() async {
    // ✅ clear normal cart
    final cartRef = _firestore.collection('cart').doc(userId).collection('items');
    final snapshot = await cartRef.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    // ✅ clear borrow cart
    final borrowCartRef =
    _firestore.collection('borrowCart').doc(userId).collection('items');
    final borrowSnapshot = await borrowCartRef.get();
    for (var doc in borrowSnapshot.docs) {
      await doc.reference.delete();
    }

    cartItems.clear();
    borrowCartItems.clear();
    _calculateTotals();
  }

  String _generateOrderId() {
    final rand = Random();
    return "ORD-${rand.nextInt(999999)}";
  }

  Map<String, dynamic> toOrderMap() {
    return {
      "orderId": _generateOrderId(),
      "userId": userId,
      "items": [
        ...cartItems.map((item) => Map<String, dynamic>.from(item)).toList(),
        ...borrowCartItems.map((item) => Map<String, dynamic>.from(item)).toList(),
      ],
      "subTotal": subTotal.value,
      "vat": vat.value,
      "totalPrice": totalPrice.value,
      "orderDate": FieldValue.serverTimestamp(),
      "cardNumber": "",
    };
  }

  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    await _firestore
        .collection("orders")
        .doc(orderData["orderId"])
        .set(orderData);

    await clearCart();
  }
}

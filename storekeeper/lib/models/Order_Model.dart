class OrderModel {
  final String orderId;
  final String userId;
  final List<Map<String, dynamic>> items;
  final double subTotal;
  final double vat;
  final double totalPrice;
  final String orderDate;
  final String cardNumber;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.subTotal,
    required this.vat,
    required this.totalPrice,
    required this.orderDate,
    required this.cardNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      "orderId": orderId,
      "userId": userId,
      "items": items,
      "subTotal": subTotal,
      "vat": vat,
      "totalPrice": totalPrice,
      "orderDate": orderDate,
      "cardNumber": cardNumber,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map["orderId"] ?? "",
      userId: map["userId"] ?? "",
      items: List<Map<String, dynamic>>.from(map["items"] ?? []),
      subTotal: (map["subTotal"] ?? 0).toDouble(),
      vat: (map["vat"] ?? 0).toDouble(),
      totalPrice: (map["totalPrice"] ?? 0).toDouble(),
      orderDate: map["orderDate"] ?? "",
      cardNumber: map["cardNumber"] ?? "",
    );
  }
}

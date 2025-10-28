import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PaymentController extends GetxController {
  final TextEditingController cardNumberController = TextEditingController();

  // ✅ Get masked card number
  String get maskedCard {
    final cardNumber = cardNumberController.text.trim();
    if (cardNumber.isEmpty) return "";

    return cardNumber.length >= 8
        ? "${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(cardNumber.length - 4)}"
        : cardNumber;
  }

  @override
  void onClose() {
    cardNumberController.dispose();
    super.onClose();
  }
}

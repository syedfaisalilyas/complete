// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:storekeeper/screens/payment/Payment_Confirmation.dart';
// import '../../controllers/Cart_Controller.dart';
// import '../../core/app_styles.dart';
// import '../../core/app_theme.dart';
// import '../../services/tracking_service.dart';
//
// class PaymentScreen extends StatefulWidget {
//   final Map<String, dynamic> orderData;
//
//   const PaymentScreen({super.key, required this.orderData});
//
//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController cardNumberController = TextEditingController();
//   final TextEditingController cardHolderController = TextEditingController();
//   final TextEditingController expDateController = TextEditingController();
//   final TextEditingController cvvController = TextEditingController();
//   final TextEditingController pinController = TextEditingController();
//
//   final CartController cartController = Get.find<CartController>();
//
//   bool _isLoading = false; // ✅ Loading flag
//
//   // ===== Date Picker =====
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() {
//         expDateController.text = DateFormat("MM/yy").format(picked);
//       });
//     }
//   }
//
//   // ===== Payment + Firestore Save =====
//   Future<void> _makePayment() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true; // show loading
//       });
//
//       try {
//         // Simulate 5 seconds loading
//         await Future.delayed(const Duration(seconds: 5));
//
//         // Card number mask logic
//         final cardNumber = cardNumberController.text.trim();
//         final maskedCard = cardNumber.length >= 8
//             ? "${cardNumber.substring(0, 4)} **** **** ${cardNumber.substring(cardNumber.length - 4)}"
//             : cardNumber;
//
//         // ===== Final Payment Data =====
//         final paymentData = {
//           "orderId": DateTime.now().millisecondsSinceEpoch.toString(),
//           "orderDate": DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.now()),
//           "cardNumber": maskedCard,
//           "cardHolder": cardHolderController.text.trim(),
//           "expDate": expDateController.text.trim(),
//           "cvv": cvvController.text.trim(),
//           "pin": pinController.text.trim(),
//           ...widget.orderData, // include any previous orderData like totalPrice
//         };
//
//         // ✅ Save all input fields in Firestore collection 'payment'
//         await FirebaseFirestore.instance
//             .collection("payment")
//             .doc(paymentData["orderId"])
//             .set(paymentData);
//
//         // ✅ Save original order in 'orders' collection
//         await FirebaseFirestore.instance
//             .collection("orders")
//             .doc(paymentData["orderId"])
//             .set(paymentData);
//
//         for (var item in widget.orderData['items']) {
//           TrackingService.trackUserActivity(
//             productId: item["id"],
//             category: item["category"],
//             name: item["name"],
//             purchased: true,
//           );
//         }
//
//
//
//         // ✅ Clear Cart
//         cartController.clearCart();
//
//         // ✅ Navigate to Confirmation Screen
//         Get.off(() => PaymentConfirmation(orderData: paymentData));
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("payment_failed".tr + ": $e")),
//         );
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double totalPrice = (widget.orderData['totalPrice'] ?? 0).toDouble();
//     final String formattedPrice = totalPrice.toStringAsFixed(2);
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             width: 1.sw,
//             height: 1.sh,
//             decoration: const BoxDecoration(
//               gradient: AppTheme.background,
//             ),
//             child: SafeArea(
//               child: Column(
//                 children: [
//                   SizedBox(height: 10.h),
//                   // ===== Top AppBar =====
//                   Row(
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.arrow_back, color: Colors.white),
//                         onPressed: () => Get.back(),
//                       ),
//                       Expanded(
//                         child: Text(
//                           "app_title".tr,
//                           textAlign: TextAlign.center,
//                           style: AppStyles.large.copyWith(
//                             fontSize: 22.sp,
//                             color: AppTheme.primaryColor,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 48),
//                     ],
//                   ),
//
//                   // ===== Top Image =====
//                   Column(
//                     children: [
//                       SizedBox(height: 20.h),
//                       Image.asset(
//                         "assets/images/signin/signin.png",
//                         height: 100.h,
//                         fit: BoxFit.contain,
//                       ),
//                       SizedBox(height: 30.h),
//                     ],
//                   ),
//
//                   // ===== White Container =====
//                   Expanded(
//                     child: Container(
//                       width: 1.sw,
//                       decoration: BoxDecoration(
//                         color: AppTheme.primaryColor,
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(30.r),
//                           topRight: Radius.circular(30.r),
//                         ),
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.all(20.w),
//                         child: Form(
//                           key: _formKey,
//                           child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // ===== Payment Row =====
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       "payment".tr,
//                                       style: AppStyles.medium1.copyWith(
//                                         color: AppTheme.secondaryColor,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Image.asset(
//                                       "assets/images/payment/payment1.png",
//                                       height: 60.h,
//                                       fit: BoxFit.contain,
//                                     ),
//                                   ],
//                                 ),
//
//                                 _buildLabel("card_number".tr),
//                                 _buildTextField(
//                                   controller: cardNumberController,
//                                   hint: "enter_card_number".tr,
//                                   keyboardType: TextInputType.number,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return "enter_card_number".tr;
//                                     }
//                                     if (value.length < 16) {
//                                       return "card_number_invalid".tr;
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(height: 10.h),
//
//                                 _buildLabel("card_holder_name".tr),
//                                 _buildTextField(
//                                   controller: cardHolderController,
//                                   hint: "enter_card_holder_name".tr,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return "enter_card_holder_name".tr;
//                                     }
//                                     if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
//                                       return "card_holder_invalid".tr;
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(height: 10.h),
//
//                                 _buildLabel("exp_date".tr),
//                                 TextFormField(
//                                   controller: expDateController,
//                                   readOnly: true,
//                                   onTap: () => _selectDate(context),
//                                   decoration: InputDecoration(
//                                     hintText: "mm/yy",
//                                     suffixIcon: const Icon(
//                                       Icons.calendar_today,
//                                       color: AppTheme.button,
//                                     ),
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(12.r),
//                                     ),
//                                     contentPadding: EdgeInsets.symmetric(
//                                       horizontal: 15.w,
//                                       vertical: 14.h,
//                                     ),
//                                   ),
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return "select_expiry_date".tr;
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(height: 10.h),
//
//                                 _buildLabel("cvv".tr),
//                                 _buildTextField(
//                                   controller: cvvController,
//                                   hint: "enter_cvv".tr,
//                                   keyboardType: TextInputType.number,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return "enter_cvv".tr;
//                                     }
//                                     if (value.length > 4) {
//                                       return "cvv_invalid".tr;
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(height: 10.h),
//
//                                 _buildLabel("pin".tr),
//                                 _buildTextField(
//                                   controller: pinController,
//                                   hint: "enter_pin".tr,
//                                   keyboardType: TextInputType.number,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return "enter_pin".tr;
//                                     }
//                                     if (value.length != 4) {
//                                       return "pin_invalid".tr;
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 SizedBox(height: 10.h),
//
//                                 const Divider(),
//                                 SizedBox(height: 10.h),
//
//                                 Text(
//                                   "total_price".tr + ":  $formattedPrice OMR",
//                                   style: AppStyles.medium.copyWith(
//                                     fontSize: 16.sp,
//                                     color: AppTheme.secondaryColor,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 SizedBox(height: 10.h),
//
//                                 SizedBox(
//                                   width: double.infinity,
//                                   height: 50.h,
//                                   child: ElevatedButton(
//                                     onPressed: _makePayment,
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: AppTheme.button,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(8.r),
//                                       ),
//                                     ),
//                                     child: Text(
//                                       "pay_now".tr,
//                                       style: AppStyles.medium1.copyWith(
//                                         color: AppTheme.primaryColor,
//                                         fontSize: 16.sp,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // ===== Loading overlay =====
//           if (_isLoading)
//             Container(
//               width: 1.sw,
//               height: 1.sh,
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ===== Helpers =====
//   Widget _buildLabel(String text) {
//     return Text(
//       text,
//       style: AppStyles.medium.copyWith(
//         color: AppTheme.secondaryColor,
//         fontWeight: FontWeight.bold,
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     String? Function(String?)? validator,
//     TextInputType? keyboardType,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         hintText: hint,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: 15.w,
//           vertical: 15.h,
//         ),
//       ),
//       keyboardType: keyboardType,
//       validator: validator,
//     );
//   }
// }

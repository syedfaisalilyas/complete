import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:unitools/common/buttons/primary_button.dart';
import 'package:unitools/common/customShapes/containers/custom_cliper.dart';
import 'package:unitools/common/widgets/decorations/input_decoration.dart';
import 'package:unitools/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:unitools/utils/constants/colors.dart';
import 'package:unitools/utils/constants/sizes.dart';
import 'package:unitools/utils/constants/text_strings.dart';
import 'package:unitools/utils/constants/image_strings.dart';
import 'package:unitools/utils/validators/validation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shopkeeper/HomeScreenShopkeeper.dart';

// ✅ This screen handles both Admin & Storekeeper login.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() => isPasswordHidden = !isPasswordHidden);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      // ✅ Sign in with Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final uid = userCredential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        Get.snackbar("Error", "User data not found in Firestore",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }

      final role = (doc.data()?['role'] ?? '').toString().toLowerCase();

      // ✅ Route user based on role
      if (role == 'storekeeper') {
        Get.offAll(() => const HomeScreenShopkeeper());
      } else if (role == 'admin') {
        // TODO: Replace with your actual Admin screen widget
        Get.snackbar("Admin Login", "Redirecting to admin dashboard...",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Access Denied", "Unknown role: $role",
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login failed.";
      if (e.code == 'user-not-found') {
        message = "No user found for this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address.";
      }
      Get.snackbar("Error", message,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== Top Logo Section =====
            CustomClipperWidget(
              child: Stack(
                children: [
                  Image.asset(
                    TImages.logo,
                    width: screenWidth,
                    height: screenHeight * 0.37,
                    fit: BoxFit.fitWidth,
                  ),
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    child: const Center(
                      child: Text(
                        "Uni Tools App",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(1, 5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: -3,
                    left: 20,
                    child: Text(
                      "Admin / Storekeeper Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== Form Section =====
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  TSizes.defaultSpace, 0, TSizes.defaultSpace, TSizes.defaultSpace),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    TextFormField(
                      controller: _email,
                      validator: TValidator.validateEmail,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: TColors.black,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: TInputDecoration.inputDecoration(
                        context,
                        TTexts.email,
                        Iconsax.direct_right,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    const Text(
                      "Password",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    TextFormField(
                      controller: _password,
                      validator: TValidator.validatePassword,
                      obscureText: isPasswordHidden,
                      cursorColor: TColors.black,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: TInputDecoration.inputDecoration(
                        context,
                        TTexts.password,
                        Iconsax.password_check,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordHidden ? Iconsax.eye_slash : Iconsax.eye,
                            color: Colors.grey,
                          ),
                          onPressed: togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    // ===== Login Button =====
                    isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6366F1),
                      ),
                    )
                        : PrimaryButton(
                      text: TTexts.signIn,
                      onPressed: _login,
                    ),
                  ],
                ),
              ),
            ),

            // ===== Footer (Forgot Password) =====
            GestureDetector(
              onTap: () => Get.to(() => ForgetPassword()),
              child: Image.asset(
                TImages.loginFooterImage,
                height: screenHeight * 0.1,
              ),
            ),
            const SizedBox(height: 3),
            GestureDetector(
              onTap: () => Get.to(() => ForgetPassword()),
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

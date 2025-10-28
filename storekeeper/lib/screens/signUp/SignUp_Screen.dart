import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../../core/app_styles.dart';
import '../SignIn/SignIn_Screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;

  // ================= VALIDATIONS =================
  String? _validateStudentId(String? value) {
    final pattern = RegExp(r'^\d{2}[JS]{1}\d+$');
    if (value == null || value.isEmpty) return 'Please enter your Student ID';
    if (!pattern.hasMatch(value)) return 'Student ID must be like 16J19011 or 16S19011';
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'Name can only contain letters';
    return null;
  }

  String? _validateCustomEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^\d{2}[JS]\d*@utas\.edu\.om$').hasMatch(value)) return 'Email must be like 16J19011@utas.edu.om';
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^[7-9]\d{7}$').hasMatch(value)) return 'Phone number must be 8 digits starting with 7 or 9';
    if (RegExp(r'^(.)\1*$').hasMatch(value.substring(1))) return 'Phone number cannot be all the same digits after the first';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length != 8) return 'Password must be exactly 8 characters long';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  // ================= SIGN UP =================
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "studentId": studentIdController.text.trim(),
        "studentName": studentNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Get.to(() => const SignInScreen());
    } on FirebaseAuthException catch (e) {
      String message = e.code == 'email-already-in-use'
          ? 'This email is already registered'
          : 'Signup failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= TEXT FIELD BUILDER =================
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 14.h),
        suffixIcon: suffixIcon,
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1.sw,
        height: 1.sh,
        decoration: const BoxDecoration(
          gradient: AppTheme.background,
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Text(
                "Uni Tools App",
                style: AppStyles.large.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              Expanded(
                child: Container(
                  width: 1.sw,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Student ID"),
                            _buildTextField(
                                controller: studentIdController,
                                hint: "Enter your student id",
                                validator: _validateStudentId),
                            SizedBox(height: 20.h),

                            _buildLabel("Student Name"),
                            _buildTextField(
                                controller: studentNameController,
                                hint: "Enter your name",
                                validator: _validateName),
                            SizedBox(height: 20.h),

                            _buildLabel("Email address"),
                            _buildTextField(
                                controller: emailController,
                                hint: "Enter your email",
                                keyboardType: TextInputType.emailAddress,
                                validator: _validateCustomEmail),
                            SizedBox(height: 20.h),

                            _buildLabel("Phone Number"),
                            _buildTextField(
                                controller: phoneController,
                                hint: "Enter your phone number",
                                keyboardType: TextInputType.phone,
                                validator: _validatePhoneNumber),
                            SizedBox(height: 20.h),

                            _buildLabel("Password"),
                            _buildTextField(
                              controller: passwordController,
                              hint: "Enter your password",
                              obscureText: _obscurePassword,
                              validator: _validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            SizedBox(height: 20.h),

                            _buildLabel("Confirm Password"),
                            _buildTextField(
                              controller: confirmPasswordController,
                              hint: "Confirm your password",
                              obscureText: _obscureConfirmPassword,
                              validator: _validateConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                },
                              ),
                            ),
                            SizedBox(height: 30.h),

                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.button,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),

                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Have an account? "),
                                  GestureDetector(
                                    onTap: () => Get.to(() => const SignInScreen()),
                                    child: Text(
                                      "Sign In",
                                      style: AppStyles.small1.copyWith(
                                        color: AppTheme.button,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppStyles.small1.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryColor,
      ),
    );
  }
}

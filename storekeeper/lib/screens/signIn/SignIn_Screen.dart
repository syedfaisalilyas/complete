import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storekeeper/screens/forgotpwd/Forgot_Screen.dart';
import 'package:storekeeper/screens/home/Home_Screen.dart';
import 'package:storekeeper/screens/signUp/SignUp_Screen.dart';
import '../../core/app_theme.dart';
import '../../core/app_styles.dart';
import 'package:storekeeper/controllers/profile_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // ✅ SignIn
        if (Get.isRegistered<ProfileController>()) {
          Get.delete<ProfileController>();
        }
        Get.put(ProfileController());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Successful"),
            backgroundColor: Colors.green,
          ),
        );

        Get.offAll(() => HomeScreen()); // حذف const
      } on FirebaseAuthException catch (e) {
        String message = "Enter Correct Email & Password";

        if (e.code == 'user-not-found') {
          message = "Email not found";
        } else if (e.code == 'invalid-email') {
          message = "Invalid email";
        } else if (e.code == 'wrong-password') {
          message = "Wrong password";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something went wrong")),
        );
      }
    }
  }

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
              // ===== App Title =====
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text(
                  "Uni Tools App",
                  style: AppStyles.large.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // ===== Top Image and Greeting =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 80.h),
                        Text(
                          "Hi Student",
                          style: AppStyles.medium1.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          "Sign in to continue",
                          style: AppStyles.medium.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Image.asset(
                      "assets/images/signin/signin.png",
                      height: 90.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),

              // ===== White Container =====
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
                            // Email
                            Text(
                              "Email Address",
                              style: AppStyles.small1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: "Enter your email",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 14.h,
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your email";
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 20.h),

                            // Password
                            Text(
                              "Password",
                              style: AppStyles.small1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                hintText: "Enter your password",
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 14.h,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your password";
                                }
                                if (value.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: 25.h),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: _signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.button,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Password image
                            Center(
                              child: Image.asset(
                                "assets/images/signin/forgotpwd.png",
                                height: 80.h,
                              ),
                            ),

                            // Forgot Password
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Get.to(() => ForgotPasswordScreen());
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: AppStyles.medium.copyWith(
                                    color: AppTheme.secondaryColor,
                                  ),
                                ),
                              ),
                            ),

                            // Bottom text
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don’t have an account? ",
                                    style: AppStyles.small1.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => SignUpScreen());
                                    },
                                    child: Text(
                                      "Sign Up",
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
}

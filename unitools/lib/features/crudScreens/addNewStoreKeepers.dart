import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unitools/common/buttons/primary_button.dart';
import 'package:unitools/common/widgets/decorations/input_decoration.dart';
import 'package:unitools/utils/constants/text_strings.dart';
import 'package:unitools/utils/validators/validation.dart';

class AddNewStoreKeepersScreen extends StatefulWidget {
  const AddNewStoreKeepersScreen({super.key});

  @override
  State<AddNewStoreKeepersScreen> createState() =>
      _AddNewStoreKeepersScreenState();
}

class _AddNewStoreKeepersScreenState extends State<AddNewStoreKeepersScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool isPasswordHidden = true;
  bool isConfirmHidden = true;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() => isPasswordHidden = !isPasswordHidden);
  }

  void toggleConfirmVisibility() {
    setState(() => isConfirmHidden = !isConfirmHidden);
  }

  Future<void> _createStorekeeper() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // ✅ Save user data in Firestore
      await _firestore.collection("users").doc(userCredential.user!.uid).set({
        "uid": userCredential.user!.uid,
        "name": nameController.text.trim(),
        "age": int.tryParse(ageController.text.trim()) ?? 0,
        "email": emailController.text.trim(),
        "role": "storekeeper", // ✅ this must stay
        "createdAt": DateTime.now().toIso8601String(),
      });


      _showSuccessModal();
    } on FirebaseAuthException catch (e) {
      String message = "An unknown error occurred.";
      if (e.code == 'email-already-in-use') {
        message = "This email is already in use by another account.";
      } else if (e.code == 'weak-password') {
        message = "The password provided is too weak.";
      } else if (e.code == 'invalid-email') {
        message = "The email address is not valid.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSuccessModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 12),
                const Text(
                  "Storekeeper Created Successfully!",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  "The new storekeeper account has been created and saved in Firestore.",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Back to previous screen",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== AppBar =====
              Container(
                padding: EdgeInsets.all(w * 0.04),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SizedBox(width: w * 0.03),
                    const Expanded(
                      child: Text(
                        "Add Storekeeper",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== Form =====
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: h * 0.02),
                  padding: EdgeInsets.all(w * 0.04),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Name",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: h * 0.008),
                          // Inside your Form widget
                          TextFormField(
                            controller: nameController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return "Enter name";
                              if (v.trim().length < 3) return "Name must be at least 3 characters";
                              final nameRegex = RegExp(r"^[a-zA-Z\s]+$");
                              if (!nameRegex.hasMatch(v.trim())) return "Name can only contain letters";
                              return null;
                            },
                            decoration: TInputDecoration.inputDecoration(
                              context,
                              "Enter name",
                              Iconsax.user,
                            ),
                          ),
                          SizedBox(height: h * 0.02),

                          const Text("Age",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: h * 0.008),
                          TextFormField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Enter age";
                              final age = int.tryParse(v);
                              if (age == null) return "Age must be a number";
                              if (age < 15 || age > 80) return "Age must be between 15 and 80";
                              return null;
                            },
                            decoration: TInputDecoration.inputDecoration(
                              context,
                              "Enter age",
                              Iconsax.calendar,
                            ),
                          ),

                          SizedBox(height: h * 0.02),

                          const Text("Email",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: h * 0.008),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: TValidator.validateEmail,
                            decoration: TInputDecoration.inputDecoration(
                                context, TTexts.email, Iconsax.direct_right),
                          ),
                          SizedBox(height: h * 0.02),

                          const Text("Password",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: h * 0.008),
                          TextFormField(
                            controller: passwordController,
                            validator: TValidator.validatePassword,
                            obscureText: isPasswordHidden,
                            decoration: TInputDecoration.inputDecoration(
                                context, TTexts.password, Iconsax.password_check)
                                .copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordHidden
                                      ? Iconsax.eye_slash
                                      : Iconsax.eye,
                                  color: Colors.grey,
                                ),
                                onPressed: togglePasswordVisibility,
                              ),
                            ),
                          ),
                          SizedBox(height: h * 0.02),

                          const Text("Confirm Password",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: h * 0.008),
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: isConfirmHidden,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm your password";
                              }
                              if (value != passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null; // ✅ must return null when valid
                            },
                            decoration: TInputDecoration.inputDecoration(
                              context,
                              "Confirm Password",
                              Iconsax.lock,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isConfirmHidden ? Iconsax.eye_slash : Iconsax.eye,
                                  color: Colors.grey,
                                ),
                                onPressed: toggleConfirmVisibility,
                              ),
                            ),
                          ),

                          SizedBox(height: h * 0.03),

                          isLoading
                              ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF6366F1),
                            ),
                          )
                              : PrimaryButton(
                            text: "Create Storekeeper",
                            onPressed: _createStorekeeper,
                          ),
                        ],
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

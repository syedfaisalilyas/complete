import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'BorrowFeedbackThankYouScreen.dart';



class BorrowFeedbackScreen extends StatefulWidget {
  final String requestId;

  const BorrowFeedbackScreen({super.key, required this.requestId});

  @override
  State<BorrowFeedbackScreen> createState() => _BorrowFeedbackScreenState();
}

class _BorrowFeedbackScreenState extends State<BorrowFeedbackScreen> {
  double selectedRating = 0;
  final TextEditingController feedbackController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  Future<void> submitFeedback() async {
    if (user == null) {
      Get.snackbar("Not Logged In", "Please sign in first");
      return;
    }

    if (selectedRating == 0) {
      Get.snackbar("Rating Required", "Please select your experience.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    await FirebaseFirestore.instance
        .collection("borrow_feedbacks")
        .doc(widget.requestId)
        .collection("feedback_list")
        .add({
      "userId": user!.uid,
      "rating": selectedRating,
      "feedback": feedbackController.text.trim(),
      "timestamp": FieldValue.serverTimestamp()
    });

    Get.to(() => BorrowFeedbackThankYouScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF2FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Back Button + Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back, size: 30),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Feedback 🧐😃😡",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Rate your experience",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // BAD
                        ratingOption(
                          emoji: "😠",
                          label: "Bad",
                          rating: 1,
                        ),
                        // DECENT
                        ratingOption(
                          emoji: "😐",
                          label: "Decent",
                          rating: 2,
                        ),
                        // LOVE IT
                        ratingOption(
                          emoji: "😍",
                          label: "Love it",
                          rating: 3,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Text(
                      "Your opinion about the service:",
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Tell us more...",
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Submit your Feedback",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
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
    );
  }

  Widget ratingOption({
    required String emoji,
    required String label,
    required double rating,
  }) {
    final isActive = selectedRating == rating;

    return GestureDetector(
      onTap: () {
        setState(() => selectedRating = rating);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isActive ? Colors.orange : Colors.grey),
          color: isActive ? Colors.orange.shade50 : Colors.white,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.orange : Colors.black87,
                )),
          ],
        ),
      ),
    );
  }
}



import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileController extends GetxController {
  var studentId = "".obs;
  var studentName = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var password = "".obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot userDoc =
      await _firestore.collection("users").doc(uid).get();

      if (userDoc.exists) {
        studentId.value = userDoc["studentId"];
        studentName.value = userDoc["studentName"];
        email.value = userDoc["email"];
        phone.value = userDoc["phone"];
        password.value = userDoc["password"];
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  // ✅ User profile update karne ka function
  Future<void> updateProfile({
    required String studentName,
    required String phone,
  }) async {
    try {
      String uid = _auth.currentUser!.uid;

      await _firestore.collection("users").doc(uid).update({
        "studentName": studentName,
        "phone": phone,
      });

      // Local observable values update
      this.studentName.value = studentName;
      this.phone.value = phone;

    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e");
    }
  }
}

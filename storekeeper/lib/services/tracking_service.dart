
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackingService {
  static Future<void> trackUserActivity({
    required String productId,
    required String category,
    String? name,
    bool viewed = false,
    bool addedToCart = false,
    bool rated = false,
    bool purchased = false,
    bool borrowed = false,
    String? searchQuery,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("activity")
        .doc(productId);

    final existing = await docRef.get();

    Map<String, dynamic> updateData = {
      "productId": productId,
      "category": category,
      "name": name,
      "lastUpdated": FieldValue.serverTimestamp(),
      "viewed": existing.data()?["viewed"] == true || viewed,
      "addedToCart": existing.data()?["addedToCart"] == true || addedToCart,
      "rated": existing.data()?["rated"] == true || rated,
      "purchased": existing.data()?["purchased"] == true || purchased,
      "borrowed": existing.data()?["borrowed"] == true || borrowed,
    };

    if (searchQuery != null) {
      updateData["searchQuery"] = searchQuery;
    }

    await docRef.set(updateData);
  }

  /// Search Tracking
  static Future<void> trackSearch(String query) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("searches")
        .add({
      "query": query,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }
}

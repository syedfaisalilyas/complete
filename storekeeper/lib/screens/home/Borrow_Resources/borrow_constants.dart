import 'package:flutter/material.dart';

class BorrowStatuses {
  static const pending = "PENDING";
  static const rejected = "REJECTED";
  static const approved = "APPROVED";
  static const paid = "PAID";
  static const collected = "COLLECTED";
  static const completed = "COMPLETED";

  static const all = {pending, rejected, approved, paid, collected, completed};

  static Color color(String s) {
    switch (s) {
      case approved:
        return Colors.green;
      case rejected:
        return Colors.red;
      case paid:
        return Colors.blue;
      case collected:
        return Colors.purple;
      case completed:
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }

  static String label(String s) {
    switch (s) {
      case pending:
        return "Pending approval";
      case rejected:
        return "Rejected";
      case approved:
        return "Approved (pay now)";
      case paid:
        return "Paid (waiting pickup)";
      case collected:
        return "Collected";
      case completed:
        return "Completed";
      default:
        return s;
    }
  }

  static bool isActive(String s) {
    // active request = blocks duplicates
    return s == pending || s == approved || s == paid || s == collected;
  }
}

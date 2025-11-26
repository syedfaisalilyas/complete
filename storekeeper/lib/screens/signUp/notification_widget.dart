import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildSuccessNotification(String title, String message) {
  return Material(
    elevation: 8,
    borderRadius: BorderRadius.circular(12),
    color: Colors.white,
    child: Container(
      padding: EdgeInsets.all(14),
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 3),
                Text(message,
                    style: TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          Icon(Icons.close, size: 18, color: Colors.black54),
        ],
      ),
    ),
  );
}

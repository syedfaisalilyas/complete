import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            "Choose Your Language",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),

          // English Option (disabled)
          ListTile(
            leading: const Icon(Icons.language),
            title: Text("English", style: TextStyle(fontSize: 14.sp)),
            onTap: () {
              Navigator.pop(context); // bas sheet close hogi
            },
          ),

          // Arabic Option (disabled)
          ListTile(
            leading: const Icon(Icons.language),
            title: Text("Arabic", style: TextStyle(fontSize: 14.sp)),
            onTap: () {
              Navigator.pop(context); // bas sheet close hogi
            },
          ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

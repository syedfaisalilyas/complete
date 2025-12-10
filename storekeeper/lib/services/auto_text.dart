import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../translations.dart';

class AutoText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  AutoText(this.text, {this.style});

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LanguageController>();

    return Obx(() {
      return FutureBuilder(
        future: lang.auto(text),
        builder: (context, snapshot) {
          return Text(
            snapshot.data?.toString() ?? text,
            style: style,
          );
        },
      );
    });
  }
}

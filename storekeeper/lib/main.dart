import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storekeeper/screens/SignIn/SignIn_Screen.dart';
import 'package:storekeeper/screens/home/Buy_Resources/product_details_screen.dart';

import 'firebase_options.dart';
import 'controllers/Theme_Controller.dart';
import 'screens/opening/opening.dart';
import 'screens/home/home_screen.dart';
import 'translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Init GetX Theme Controller
  Get.put(ThemeController());
  Get.put(LanguageController());
  runApp(
    const OverlaySupport.global(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // auto choose screen based on login state
  Widget _initialScreen() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const HomeScreen(); // if already logged in
    } else {
      return const OpeningScreen(); // or LoginScreen()
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Uni Tools App",
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),

          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            );
          },

          home: _initialScreen(),

          // ============================
          //         ROUTES
          // ============================
          getPages: [
            GetPage(
              name: "/opening",
              page: () => const OpeningScreen(),
            ),
            GetPage(
              name: "/login",
              page: () => const SignInScreen(),
            ),
            GetPage(
              name: "/home",
              page: () => const HomeScreen(),
            ),

            // IMPORTANT: Product Detail Route
            GetPage(
              name: "/productDetail",
              page: () => ProductDetailScreen(productData: Get.arguments ?? {}),
            ),

          ],
        );
      },
    );
  }
}

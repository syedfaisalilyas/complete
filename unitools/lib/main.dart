import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:unitools/features/authentication/screens/login/login.dart';
import 'package:unitools/features/home/HomeScreen.dart';
import 'package:unitools/data/authentication_repository.dart';
import 'package:unitools/utils/helpers/network_manager.dart';
import 'package:unitools/utils/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterNativeSplash.remove();
  dumpFirestoreStructure();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NetworkManager(), permanent: true);
    Get.put(AuthenticationRepository(), permanent: true);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "UniToolsAdmin",
      theme: TAppTheme.lightTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}


Future<void> dumpCollection(String name) async {
  final snap = await FirebaseFirestore.instance.collection(name).limit(5).get();
  print("📂 Collection: $name  (${snap.docs.length} docs)");
  for (var doc in snap.docs) {
    print("  📄 Doc ID: ${doc.id}");
    (doc.data() as Map<String, dynamic>).forEach((key, value) {
      print("     🔑 $key : ${value.runtimeType} => $value");
    });
  }
  print("\n");
}
Future<void> dumpFirestoreStructure() async {
  final collections = [
    "borrow_requests",
    "cart",
    "orders",
    "products",
    "users",
  ];

  for (final col in collections) {
    try {
      await dumpCollection(col);
    } catch (e) {
      print("⚠️ Failed to fetch $col: $e");
    }
  }
}


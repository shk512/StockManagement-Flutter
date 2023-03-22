import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Screens/account.dart';
import 'package:stock_management/Screens/dashboard.dart';
import 'package:stock_management/Screens/employee.dart';
import 'package:stock_management/Screens/login.dart';
import 'package:stock_management/Screens/new_company.dart';
import 'package:stock_management/Screens/order.dart';
import 'package:stock_management/Screens/product.dart';
import 'package:stock_management/Screens/profile.dart';
import 'package:stock_management/Screens/splash.dart';
import 'package:stock_management/firebase_options.dart';
import 'package:stock_management/utils/routes.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock Management',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.cyan,
      ),
      initialRoute: Routes.splash,
      routes: {
        Routes.newCompany:(context)=>const NewCompany(),
        Routes.splash:(context) => const SplashScreen(),
        Routes.login:(context)=>const Login(),
        Routes.dashboard: (context) => const Dashboard(),
        Routes.accounts: (context) => const Accounts(),
        Routes.epmloyee: (context) => const Employee(),
        Routes.order: (context) => const Order(),
        Routes.product: (context) => const Product(),
        Routes.profile: (context) => const Profile(),
      },
    );
  }
}

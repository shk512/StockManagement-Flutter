import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Screens/Order/order_form.dart';
import 'package:stock_management/Screens/Shop/add_shop.dart';
import 'package:stock_management/Screens/Splash_Error/splash.dart';
import 'package:stock_management/firebase_options.dart';
import 'package:stock_management/utils/routes.dart';
import 'Screens/Accounts/account.dart';
import 'Screens/Area/area.dart';
import 'Screens/Dashboard/dashboard.dart';
import 'Screens/Order/order.dart';
import 'Screens/Product/product.dart';
import 'Screens/Profile/profile.dart';
import 'Screens/RegisterLogin/login.dart';
import 'Screens/RegisterLogin/new_company.dart';
import 'Screens/Shop/shop.dart';
import 'Screens/Stock/stock.dart';
import 'Screens/User/user.dart';

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
        Routes.area:(context)=>const Area(),
        Routes.newCompany:(context)=>const NewCompany(),
        Routes.orderForm:(context)=>const OrderForm(),
        Routes.splash:(context) => const SplashScreen(),
        Routes.login:(context)=>const Login(),
        Routes.shop:(context)=>const Shop(),
        Routes.addShop:(context)=>const AddShop(),
        Routes.dashboard: (context) => const Dashboard(),
        Routes.accounts: (context) => const Accounts(),
        Routes.employee: (context) => const Employee(),
        Routes.order: (context) => const Order(),
        Routes.product: (context) => const Product(),
        Routes.profile: (context) => const Profile(),
        Routes.stock:(context)=>const Stock(),
      },
    );
  }
}

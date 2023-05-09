import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Screens/Splash_Error/splash.dart';
import 'package:stock_management/Services/shared_preferences/spf.dart';
import 'package:stock_management/firebase_options.dart';
import 'package:stock_management/Constants/routes.dart';
import 'Screens/Dashboard/dashboard.dart';
import 'Screens/RegisterLogin/login.dart';
import 'Screens/RegisterLogin/new_company.dart';

void main() async{
  bool logInStatus=false;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SPF.getLogInStatus().then((value){
    if(value==null){
      logInStatus=false;
    }else{
      logInStatus=true;
    }
  });
  runApp(MyApp(logInStatus: logInStatus,));
}

class MyApp extends StatelessWidget {
  final bool logInStatus;
  const MyApp({super.key,required this.logInStatus});

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
      //home: const Area(),
      initialRoute: Routes.splash,
      routes: {
        Routes.newCompany:(context)=>const NewCompany(),
        Routes.splash:(context) => SplashScreen(logInStatus: logInStatus,),
        Routes.login:(context)=>const Login(),
        Routes.dashboard: (context) => const Dashboard(),
      },
    );
  }
}

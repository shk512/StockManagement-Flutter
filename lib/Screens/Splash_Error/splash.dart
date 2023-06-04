import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../Constants/routes.dart';

class SplashScreen extends StatefulWidget {
  final bool logInStatus;
  const SplashScreen({Key? key,required this.logInStatus}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), (){
      if(widget.logInStatus){
        Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard, (route) => false);
      }else{
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 150,
                width: 150,
                child: Image(image: AssetImage("logo/logo_2.png"),),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*.30,),
              Text(
                "Developed By",
                textAlign:TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.brown.shade200,letterSpacing: 2),),
              const SizedBox(height: 5,),
              SizedBox(
                height: 75,
                child: Image.asset("logo/company_logo.png"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

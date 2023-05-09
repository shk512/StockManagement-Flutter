import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../Constants/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _controller=AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this
  )..repeat();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), (){
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
    });


  }

  @override
  void dispose() {
    _controller.dispose();
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
              AnimatedBuilder(
                  animation: _controller,
                  child: const SizedBox(
                    height: 200,
                    width: 200,
                    child: Center(
                      child: Image(image: AssetImage("image/stock.png"),),
                    ),
                  ),
                  builder: (context,Widget? child){
                    return Transform.rotate(
                        angle: _controller.value * 2.0* math.pi,
                        child:child
                    );
                  }),
              SizedBox(height: MediaQuery.of(context).size.height*.04,),
              const Image(image: AssetImage("image/pos.png")),
              SizedBox(height: MediaQuery.of(context).size.height*.04,),
              Text(
                "Developed By\n360 Tech",
                textAlign:TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.cyan.withOpacity(0.8),letterSpacing: 2),)
            ],
          ),
        ),
      ),
    );
  }
}

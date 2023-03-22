import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../utils/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller=AnimationController(
      duration: Duration(seconds: 5),
      vsync: this
  )..repeat();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushNamed(context, Routes.login);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
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
                  child: Container(
                    height: 200,
                    width: 200,
                    child: const Center(
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
              Image(image: AssetImage("image/pos.png")),
              SizedBox(height: MediaQuery.of(context).size.height*.04,),
              Text(
                "Developed By\n360 Tech",
                textAlign:TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.cyan),)
            ],
          ),
        ),
      ),
    );
  }
}

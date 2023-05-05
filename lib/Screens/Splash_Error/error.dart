import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({Key? key,required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber,color: Colors.black45,),
                const SizedBox(height: 10),
                Text(error,style: const TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    }, 
                    child: const Text('Go Back',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
      ),
    );
  }
}

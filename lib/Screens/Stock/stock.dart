import 'package:flutter/material.dart';

import '../../Models/user_model.dart';
import '../../utils/routes.dart';

class Stock extends StatefulWidget {
  const Stock({Key? key}) : super(key: key);

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: UserModel.role.toUpperCase()=="Admin".toUpperCase()
          ?FloatingActionButton.extended(
          onPressed: (){
            Navigator.pushNamed(context, Routes.addShop);
          },
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("Shop",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
      )
          :const SizedBox(),
    );
  }
}

import 'package:flutter/material.dart';

import '../utils/routes.dart';

class FloatingActionBtn extends StatefulWidget {
  final String route;
  final String name;
  const FloatingActionBtn({Key? key,required this.route,required this.name}) : super(key: key);

  @override
  State<FloatingActionBtn> createState() => _FloatingActionBtnState();
}

class _FloatingActionBtnState extends State<FloatingActionBtn> {
  @override
  Widget build(BuildContext context) {
    return  FloatingActionButton.extended(
        onPressed: (){
          Navigator.pushNamed(context, widget.route);
        },
        icon: const Icon(Icons.add,color: Colors.white,),
        label: Text(widget.name,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
    );
  }
}

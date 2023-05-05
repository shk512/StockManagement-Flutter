import 'package:flutter/material.dart';

class ViewOrder extends StatefulWidget {
  final String orderId;
  const ViewOrder({Key? key,required this.orderId}) : super(key: key);

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

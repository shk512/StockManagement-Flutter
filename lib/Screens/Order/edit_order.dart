import 'package:flutter/material.dart';

import '../../Models/company_model.dart';

class EditOrder extends StatefulWidget {
  final String orderId;
  final CompanyModel companyModel;
  const EditOrder({Key? key,required this.orderId,required this.companyModel}) : super(key: key);

  @override
  State<EditOrder> createState() => _EditOrderState();
}

class _EditOrderState extends State<EditOrder> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

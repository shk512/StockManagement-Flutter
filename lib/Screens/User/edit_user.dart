import 'package:flutter/material.dart';
import 'package:stock_management/Services/DB/user_db.dart';

class EditUser extends StatefulWidget {
  final String userId;
  const EditUser({Key? key,required this.userId}) : super(key: key);

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  @override
  void initState() {
    super.initState();
    UserDb(id: widget.userId).getData().then((value) {
      setState(() {

      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

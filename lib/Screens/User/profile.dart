import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Widgets/row_info_display.dart';

import '../../Models/company_model.dart';


class Profile extends StatefulWidget {
  final UserModel userModel;
  const Profile({Key? key,required this.userModel}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Profile",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          const Icon(Icons.account_balance_wallet_outlined,color: Colors.white,),
          Padding(
              padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              child: Text(
                "Rs. ${widget.userModel.wallet}",
                style: const TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.center,),),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RowInfoDisplay(label: "Email", value: widget.userModel.mail.toLowerCase()),
              const SizedBox(height: 10),
              RowInfoDisplay(label: "Name", value: widget.userModel.name.toUpperCase()),
              const SizedBox(height: 10),
              RowInfoDisplay(label:"Contact", value: widget.userModel.phone),
              const SizedBox(height: 10),
              widget.userModel.designation.isNotEmpty?RowInfoDisplay(label: "Designation", value: widget.userModel.designation.toUpperCase()):const SizedBox(),
              const SizedBox(height: 10),
              widget.userModel.salary!=0?RowInfoDisplay(label: "Salary", value:widget.userModel.salary.toString()):const SizedBox(),
              const SizedBox(height: 10),
              widget.userModel.role=="shop keeper".toUpperCase()
                  ?Container()
                  :const Align(
                alignment: Alignment.center,
                  child:  Text("Area Assigned",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900),)),
              const SizedBox(height: 10),
              areaList(),
            ],
        ),
        ),
      ),
    );
  }

  Widget areaList(){
    return Column(
            children: widget.userModel.area.map((e) => Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(">\t\t $e")))).toList(),
    );
  }
}


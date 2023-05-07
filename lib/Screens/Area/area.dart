import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/company_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Services/DB/user_db.dart';
import '../Shop/area_shop.dart';
import '../Shop/shop.dart';

class Area extends StatefulWidget {
  const Area({Key? key}) : super(key: key);

  @override
  State<Area> createState() => _AreaState();
}

class _AreaState extends State<Area> {
  List? companyArea,userArea;
  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
    matchList();
  }
  matchList()async{
    for(var area in UserModel.area){
      if(!CompanyModel.area.contains(area)){
        await UserDb(id: UserModel.userId).deleteUserArea(area);
      }
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Area",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: UserModel.area==[]
        ? const Center(
        child:  Text(
          'No area assigned yet!',
          style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),)
        :ListView.builder(
          itemCount:UserModel.area.length /*userArea!.length*/,
          itemBuilder: (context,index){
                return ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AreaShop(areaName: UserModel.area[index],)));
                  },
                  title: Text(UserModel.area[index]),
                );
          }
      )
    );
  }
}

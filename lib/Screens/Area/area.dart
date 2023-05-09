import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';

import '../../Services/DB/user_db.dart';
import '../Shop/area_shop.dart';

class Area extends StatefulWidget {
  const Area({Key? key}) : super(key: key);

  @override
  State<Area> createState() => _AreaState();
}

class _AreaState extends State<Area> {
  List? companyArea,userArea;
  CompanyModel _companyModel=CompanyModel();
  UserModel _userModel=UserModel();
  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(_companyModel,_userModel);
    matchList();
  }
  matchList()async{
    for(var area in _userModel.area){
      if(_companyModel.area.contains(area)){
        await UserDb(id: _userModel.userId).deleteUserArea(area);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _userModel.role=="Shop Keeper".toUpperCase()
        ?AreaShop(areaName: _userModel.designation)
        :Scaffold(
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
      body: _userModel.area.isEmpty
        ? const Center(
        child:  Text(
          'No area assigned yet!',
          style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),)
        :ListView.builder(
          itemCount:_userModel.area.length /*userArea!.length*/,
          itemBuilder: (context,index){
                return ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AreaShop(areaName: _userModel.area[index],)));
                  },
                  title: Text(_userModel.area[index]),
                );
          }
      )
    );
  }
}

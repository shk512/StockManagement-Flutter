import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';

import '../../Services/DB/user_db.dart';
import '../Shop/area_shop.dart';

class Area extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const Area({Key? key,required this.companyModel,required this.userModel}) : super(key: key);

  @override
  State<Area> createState() => _AreaState();
}

class _AreaState extends State<Area> {
  List? companyArea,userArea;

  @override
  void initState() {
    super.initState();
    matchList();
  }
  matchList()async{
    for(var area in widget.userModel.area){
      if(widget.companyModel.area.contains(area)){
        await UserDb(id: widget.userModel.userId).deleteUserArea(area);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.userModel.role=="Shop Keeper".toUpperCase()
        ?AreaShop(areaName: widget.userModel.designation, companyModel: widget.companyModel, userModel: widget.userModel,)
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
      body: widget.userModel.area.isEmpty
        ? const Center(
        child:  Text(
          'No area assigned yet!',
          style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),)
        :ListView.builder(
          itemCount:widget.userModel.area.length /*userArea!.length*/,
          itemBuilder: (context,index){
                return ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AreaShop(areaName: widget.userModel.area[index], companyModel: widget.companyModel,userModel: widget.userModel,)));
                  },
                  title: Text(widget.userModel.area[index]),
                );
          }
      )
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/area_db.dart';

import '../Shop/area_shop.dart';

class UserArea extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const UserArea({Key? key,required this.companyModel,required this.userModel}) : super(key: key);

  @override
  State<UserArea> createState() => _UserAreaState();
}

class _UserAreaState extends State<UserArea> {
  Stream? area;
  TextEditingController searchController=TextEditingController();

  @override
  void initState() {
    super.initState();
    getArea();
  }
  getArea() async{
    await AreaDb(areaId: "", companyId: widget.companyModel.companyId).getArea().then((value){
      setState(() {
        area=value;
      });
    }).onError((error, stackTrace){
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)), (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.userModel.role=="Shop Keeper".toUpperCase()
        ?AreaShop(areaId: widget.userModel.name, companyModel: widget.companyModel, userModel: widget.userModel,)
        :Scaffold(
          body: Column(
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search here...",
                    ),
                    onChanged: (val){
                      setState(() {
                        searchController.text=val;
                      });
                    },
                  )
              ),
              Expanded(
                child: StreamBuilder(
                  stream: area,
                  builder: (context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    }
                    if(snapshot.hasError){
                      return Center(child: Text("Error"),);
                    }
                    if(!snapshot.hasData){
                      return Center(child: Text("No Data Found"),);
                    }
                    else{
                      return ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context,index){
                            if(searchController.text.isEmpty){
                              if(widget.userModel.area.contains(snapshot.data.docs[index]["areaId"])){
                                return listTile(snapshot.data.docs[index]);
                              }else{
                                return const SizedBox();
                              }
                            }else{
                              if(snapshot.data.docs[index]["areaName"].toString().trim().toLowerCase().contains(searchController.text.trim().toLowerCase())){
                                if(widget.userModel.area.contains(snapshot.data.docs[index]["areaId"])){
                                  return listTile(snapshot.data.docs[index]);
                                }else{
                                  return const SizedBox();
                                }
                              }else{
                                return const SizedBox();
                              }
                            }
                          });
                    }
                  }),
              ),
            ],
          )
      );
  }
  Widget listTile(DocumentSnapshot snapshot){
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>AreaShop(areaId: snapshot["areaId"], companyModel: widget.companyModel, userModel: widget.userModel,key: Key("areaShop"),)));
      },
      title: Text("${snapshot["areaName"]}"),
    );
  }
}

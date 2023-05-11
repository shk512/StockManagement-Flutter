import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/User/edit_user.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';

import '../../Widgets/row_info_display.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class ViewUser extends StatefulWidget {
  final UserModel userModel;
  final CompanyModel companyModel;
  final String userId;
  const ViewUser({Key? key,required this.userId,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<ViewUser> createState() => _ViewUserState();
}

class _ViewUserState extends State<ViewUser> {
  DocumentSnapshot? snapshot;
  String shopName="";
  String shopId="";
  List area=[];
  List rights=[];
  @override
  void initState() {
    super.initState();
    getData();
  }
  getData() async{
    await UserDb(id: widget.userId).getData().then((value)async{
      setState(() {
        snapshot=value;
        area=List.from(snapshot!["area"]);
        rights=List.from(snapshot!["right"]);
        shopId=snapshot!["designation"];
      });
      if(snapshot!["role"]=="Shop Keeper".toUpperCase()&&shopId.isNotEmpty){
        await ShopDB(companyId: widget.companyModel.companyId, shopId: shopId).getShopDetails().then((value){
          setState(() {
            shopName="${value["shopName"]}-${value["areaId"]}";
          });
        }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
      }
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
  }
  @override
  Widget build(BuildContext context) {
    return snapshot==null
        ?const Center(child: CircularProgressIndicator(),)
        :Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: Text(snapshot!["userId"]==widget.userModel.userId?"Profile":snapshot!["role"],style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
              onPressed: (){
                if(widget.userModel.rights.contains(Rights.addTransaction)||widget.userModel.rights.contains(Rights.all)){
                  createTransaction();
                }
              }, icon: const Icon(Icons.account_balance_wallet_outlined,color: Colors.white,)),
          Align(
            alignment: Alignment.center,
            child: Text(
              "Rs. ${snapshot!["wallet"]}",
              style: const TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.center,),
          ),
          const SizedBox(width: 5,),
          widget.userModel.rights.contains(Rights.editUser) || widget.userModel.rights.contains(Rights.all) || widget.userModel.userId==widget.userId
              ? IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EditUser(userId: widget.userId,userModel: widget.userModel,)));
              }, icon: const Icon(Icons.edit,color: Colors.white,))
              :const SizedBox()
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RowInfoDisplay(label: "Email", value: snapshot!["mail"].toLowerCase()),
                RowInfoDisplay(label: "Name", value: snapshot!["name"].toUpperCase()),
                RowInfoDisplay(label:"Contact", value: snapshot!["phone"]),
                snapshot!["role"]=="Employee".toUpperCase()?RowInfoDisplay(label: "Designation", value: snapshot!["designation"]):const SizedBox(),
                snapshot!["role"]=="Employee".toUpperCase()?RowInfoDisplay(label: "Salary", value:snapshot!["salary"].toString()):const SizedBox(),
                const SizedBox(height: 5),
                snapshot!["role"]=="shop keeper".toUpperCase()
                      ?Text("Shop",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color: Colors.cyan))
                      :Row(
                        children: [
                          Expanded(child: Text("Area",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color: Colors.cyan),)),
                            widget.userModel.rights.contains(Rights.addArea) || widget.userModel.rights.contains(Rights.all)
                            ? Expanded(
                              child :IconButton(
                                onPressed: (){
                                  showAreaDialogueBox();
                              },
                              icon: const Icon(Icons.add,color: Colors.cyan,) ,
                              ),
                            ): const SizedBox()
                        ],
                      ),
                const SizedBox(height: 5),
                snapshot!["role"]=="Shop Keeper".toUpperCase()
                      ? Text(snapshot!["designation"].toString().isNotEmpty ? shopName : "No Shop Assigned")
                      :area.isEmpty?const Text("No Area Assigned"):showAreaList(),
                const SizedBox(height: 10,),
                widget.userModel.role=="Company".toUpperCase()
                    ?Column(
                      children: [
                        const Align(
                          alignment: AlignmentDirectional.bottomStart,
                          child: Text(
                          "Rights:", style: TextStyle(color:Colors.cyan,fontWeight: FontWeight.bold,fontSize: 20),),
                      ),
                    showRights()
                  ],
                ):const SizedBox()
              ],
            ),
        ),
      ),
    );
  }
  Widget showRights(){
    return Column(
      children: rights.map((e) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text("$e"),
        ),
      )).toList(),
    );
  }
  Widget showAreaList(){
    return Column(
      children: area.map((e) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: InkWell(
            onTap: (){
              if(widget.userModel.rights.contains(Rights.deleteArea)||widget.userModel.rights.contains(Rights.all)){
                showWarningDialogue(e);
              }
            },
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(">\t\t $e")),
          ))).toList(),
    );
  }
  Widget showCompanyList(){
    return Column(
      children: widget.companyModel.area.map((e) => area.contains(e)
          ?const SizedBox()
          :Align(
        alignment: AlignmentDirectional.centerStart,
        child: InkWell(
          onTap: (){
            saveArea(e);
            Navigator.pop(context);
          },
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(e)),
        ),
      )).toList(),
    );
  }
  showAreaDialogueBox(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Tap on area to add"),
            content: showCompanyList(),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                    },
                  child: const Text("Cancel",style:  TextStyle(color: Colors.white),))
            ],
          );
        });
  }
  saveArea(String areaName)async{
    await UserDb(id: snapshot!["userId"]).updateAreaList(areaName).then((value)async{
      if(value==true){
        setState(() {
          area.add(areaName);
        });
      }else{
        showSnackbar(context, Colors.red, "Area with same name already available");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  deleteArea(String areaName)async{
    await UserDb(id: snapshot!["userId"]).deleteUserArea(areaName).then((value){
      if(value==true){
        showSnackbar(context, Colors.cyan, "Deleted");
        setState(() {
          area.remove(areaName);
        });
      }else{
        showSnackbar(context, Colors.red, "Error");
      }
    }).onError((error, stackTrace) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  showWarningDialogue(String areaName){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Warning"),
            content: Text("Are you sure to delete area $areaName?"),
            actions: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel,color: Colors.red,)),
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                    deleteArea(areaName);
                  },
                  icon: const Icon(Icons.check_circle_rounded,color: Colors.green,)),
            ],
          );
        }
    );
  }
  createTransaction(){

  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/User/assign_area.dart';
import 'package:stock_management/Screens/User/edit_user.dart';
import 'package:stock_management/Screens/User/remove_area.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';

import '../../Constants/routes.dart';
import '../../Services/Auth/auth.dart';
import '../../Services/DB/area_db.dart';
import '../../Services/shared_preferences/spf.dart';
import '../../Widgets/row_info_display.dart';
import '../../Widgets/text_field.dart';
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
  List area=[];
  String shopName="";
  String shopId="";
  List userArea=[];
  List rights=[];
  bool isLoading=false;

  @override
  void initState() {
    super.initState();
    getData();
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
  getData() async{
    await UserDb(id: widget.userId).getData().then((value)async{
      setState(() {
        snapshot=value;
        userArea=List.from(snapshot!["area"]);
        rights=List.from(snapshot!["right"]);
        shopId=snapshot!["designation"];
      });
      if(snapshot!["role"]=="Shop Keeper".toUpperCase()&&shopId.isNotEmpty){
        await ShopDB(companyId: widget.companyModel.companyId, shopId: shopId).getShopDetails().then((value){
          setState(() {
            shopName="${value["shopName"]}-${value["areaId"]}";
          });
        }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
      }else{
        for(String id in userArea){
          await AreaDb(areaId: id, companyId: widget.companyModel.companyId).getAreaById().then((value){
            setState(() {
              area.add(value["areaName"]);
            });
          });
        }
      }
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(CupertinoIcons.back,color: Colors.white,)
        ),

        actions: [
          IconButton(
              onPressed: (){
              },
              icon: const Icon(Icons.account_balance_wallet_outlined,color: Colors.white,)),
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
              :const SizedBox(),
          widget.userModel.userId==FirebaseAuth.instance.currentUser!.uid
              ? IconButton(
              onPressed: (){
                showPasswordChangeDialogue();
              },
              icon: Icon(Icons.lock_reset,color: Colors.white,))
              :const SizedBox(),
          widget.userModel.userId==FirebaseAuth.instance.currentUser!.uid
              ? IconButton(
              onPressed: (){
                showDeleteDialogue();
              }, icon: Icon(Icons.delete,color: Colors.white,))
              :const SizedBox()
        ],
      ),
      body:  isLoading
          ?const Center(child: CircularProgressIndicator(),)
          :SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RowInfoDisplay(label: "Email", value: snapshot!["mail"].toLowerCase()),
                RowInfoDisplay(label: "Name", value: snapshot!["name"].toUpperCase()),
                RowInfoDisplay(label:"Contact", value: snapshot!["phone"]),
                RowInfoDisplay(label:"Status", value: snapshot!["isDeleted"]?"InActive":"Active"),
                snapshot!["role"]=="Employee".toUpperCase()?RowInfoDisplay(label: "Designation", value: snapshot!["designation"]):const SizedBox(),
                snapshot!["role"]=="Employee".toUpperCase()?RowInfoDisplay(label: "Salary", value:snapshot!["salary"].toString()):const SizedBox(),
                const SizedBox(height: 5),
                snapshot!["role"]=="shop keeper".toUpperCase()
                      ?Text("Shop",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color: Colors.brown))
                      :Row(
                        children: [
                          Expanded(child: Text("Area",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color: Colors.brown),)),
                            widget.userModel.rights.contains(Rights.addArea) || widget.userModel.rights.contains(Rights.all)
                            ? Expanded(
                              child :IconButton(
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AssignArea(userModel: widget.userModel, companyModel: widget.companyModel,)));
                              },
                              icon: const Icon(Icons.add,color: Colors.brown,) ,
                              ),
                            ): const SizedBox(),
                          widget.userModel.rights.contains(Rights.addArea) || widget.userModel.rights.contains(Rights.all)
                              ? Expanded(
                            child :IconButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>RemoveArea(userModel: widget.userModel, companyModel: widget.companyModel,)));
                              },
                              icon: const Icon(Icons.remove,color: Colors.brown,) ,
                            ),
                          ): const SizedBox(),
                        ],
                      ),
                snapshot!["role"]=="Shop Keeper".toUpperCase()
                      ? Text(snapshot!["designation"].toString().isNotEmpty ? shopName : "No Shop Assigned")
                      :userArea.isEmpty
                          ?const Text("No Area Assigned")
                          :areaList(),
                const SizedBox(height: 10,),
                widget.userModel.role=="Company".toUpperCase()
                    ?Column(
                      children: [
                        const Align(
                          alignment: AlignmentDirectional.bottomStart,
                          child: Text(
                          "Rights:", style: TextStyle(color:Colors.brown,fontWeight: FontWeight.bold,fontSize: 20),),
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

  showDeleteDialogue(){
    TextEditingController licenseKey=TextEditingController();
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Delete Account"),
            content: TxtField(labelTxt: "License Key", hintTxt: "Company's license key", ctrl: licenseKey, icon: Icon(Icons.key)),
            actions: [
              IconButton(
                onPressed: (){
                  Navigator.pop(context);
                }, icon: Icon(Icons.cancel,color: Colors.red),),
              IconButton(
                onPressed: (){
                  Navigator.pop(context);
                  if(licenseKey.text==widget.companyModel.companyId){
                    deleteUser();
                  }else{
                    showSnackbar(context, Colors.red.shade400, "Invalid license");
                  }
                }, icon: Icon(Icons.check_circle_rounded,color: Colors.green),),
            ],
          );
        });
  }
  Future deleteUser()async{
    Auth auth=Auth();
    await auth.deleteUser().then((value){
      if(value==true){
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
        showSnackbar(context, Colors.green.shade300, "Deleted");
      }else{
        showSnackbar(context, Colors.red.shade400, value.toString());
      }
    });
  }

  updatePassword(String password)async{
    Auth auth=Auth();
    await auth.updateNewPass(password).then((value){
      if(value==true){
        SPF.saveUserLogInStatus(false);
        Navigator.pushNamedAndRemoveUntil(context,Routes.login, (route) => false);
      }
    });
  }
  showPasswordChangeDialogue(){
    final formKey=GlobalKey<FormState>();
    TextEditingController password=TextEditingController();
    TextEditingController confirmPassword=TextEditingController();

    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Change Password"),
            content: Form(
              key: formKey,
              child: Column(
                children: [
                  TxtField(labelTxt: "Password", hintTxt: "Type password", ctrl: password, icon: Icon(Icons.lock_outline_rounded)),
                  TxtField(labelTxt: "Confirm Password", hintTxt: "Retype your password", ctrl: confirmPassword, icon: Icon(Icons.lock_outline_rounded)),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel',style: TextStyle(color: Colors.white),)),
              ElevatedButton(
                  onPressed: ()async{
                    if(formKey.currentState!.validate()){
                      Navigator.pop(context);
                      updatePassword(password.text);
                    }
                  },
                  child: Text('Confirm',style: TextStyle(color: Colors.white),)),
            ],
          );
        });
  }
  
  Widget areaList(){
    return Column(
      children: area.map((e) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: InkWell(child: Text("$e")),
        ),
      )).toList(),
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

  saveArea(String areaId)async{
    await UserDb(id: snapshot!["userId"]).updateAreaList(areaId).then((value)async{
      if(value==true){
        setState(() {
          userArea.add(areaId);
        });
      }else{
        showSnackbar(context, Colors.red.shade400, "Area with same name already available");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
    });
  }

  deleteArea(String areaId)async{
    await UserDb(id: snapshot!["userId"]).deleteUserArea(areaId).then((value){
      if(value==true){
        showSnackbar(context, Colors.green.shade300, "Deleted");
        setState(() {
          userArea.remove(areaId);
        });
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
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
}

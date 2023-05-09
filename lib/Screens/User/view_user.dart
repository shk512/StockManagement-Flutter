import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/User/edit_user.dart';
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
  List area=[];
  @override
  void initState() {
    super.initState();
    getData();
  }
  getData() async{
    await UserDb(id: widget.userId).getData().then((value){
      setState(() {
        snapshot=value;
        area=List.from(snapshot!["area"]);
      });
    });
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
        title: Text(snapshot!["role"],style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
              onPressed: (){

              }, icon: const Icon(Icons.account_balance_wallet_outlined,color: Colors.white,)),
          Text(
              "Rs. ${snapshot!["wallet"]}",
              style: const TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.center,),
          widget.userModel.rights.contains(Rights.editUser) || widget.userModel.rights.contains(Rights.all)
              ? IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>EditUser(userId: widget.userId)));
              }, icon: const Icon(Icons.edit,color: Colors.white,))
              :const SizedBox()
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RowInfoDisplay(label: "Email", value: snapshot!["mail"].toLowerCase()),
              const SizedBox(height: 10),
              RowInfoDisplay(label: "Name", value: snapshot!["name"].toUpperCase()),
              const SizedBox(height: 10),
              RowInfoDisplay(label:"Contact", value: snapshot!["phone"]),
              const SizedBox(height: 10),
              snapshot!["designation"].isNotEmpty?RowInfoDisplay(label: "Designation", value: snapshot!["designation"]):const SizedBox(),
              const SizedBox(height: 10),
              snapshot!["salary"]!=0?RowInfoDisplay(label: "Salary", value:snapshot!["salary"].toString()):const SizedBox(),
              const SizedBox(height: 10),
              snapshot!["role"]=="shop keeper".toUpperCase()
                  ?Container()
                  : Row(
                children: [
                  const Expanded(child: Text("Area",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color: Colors.cyan),)),
                  widget.userModel.rights.contains(Rights.addArea) || widget.userModel.rights.contains(Rights.all)
                      ? Expanded(
                    child: IconButton(
                      onPressed: (){
                        showDialogueBox();
                      },
                      icon: const Icon(Icons.add,color: Colors.cyan,) ,
                    ),
                  ): const SizedBox()
                ],
              ),
              const SizedBox(height: 5),
              area.isEmpty?const Text("No Area Assigned"):showAreaList(),
            ],
          ),
        ),
      ),
    );
  }
  Widget showAreaList(){
    return Column(
      children: widget.userModel.area.map((e) => Align(
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
      children: widget.companyModel.area.map((e) => widget.userModel.area.contains(e)
          ?const SizedBox()
          :Align(
        alignment: AlignmentDirectional.centerStart,
        child: InkWell(
          onTap: (){
            saveArea(e);
            Navigator.pop(context);
          },
          child: Text(e),
        ),
      )).toList(),
    );
  }
  showDialogueBox(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Tap to add area"),
            content: showCompanyList(),
          );
        });
  }
  saveArea(String areaName)async{
    await UserDb(id: widget.userModel.userId).updateAreaList(areaName).then((value)async{
      if(value==true){
        setState(() {
          widget.userModel.area.add(areaName);
        });
      }else{
        showSnackbar(context, Colors.red, "Area with same name already available");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  deleteArea(String areaName)async{
    await UserDb(id: widget.userModel.userId).deleteUserArea(areaName).then((value){
      if(value==true){
        showSnackbar(context, Colors.cyan, "Deleted");
        setState(() {
          widget.userModel.area.remove(areaName);
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
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/user_company_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/company_db.dart';
import 'package:stock_management/utils/snackBar.dart';

import '../../Services/DB/user_db.dart';

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
    getAreaList();
    print(companyArea);
    print(userArea);
  }
  getAreaList(){
    setState(() async{
      userArea=await UserDb(id: UserModel.userId).getAreaList();
    });
    setState(() async{
      companyArea=await CompanyDb(id: CompanyModel.companyId).getAreaList();
    });
  }
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
        title: const Text("Area",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton:   FloatingActionButton.extended(
          onPressed: (){
            showDialogueBox();
          },
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("Area",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
      ),
      body: ListView.builder(
          itemCount: userArea!.length,
          itemBuilder: (context,index){
            if(userArea!.isEmpty){
              return const Center(
                child: Text(
                  'No area added yet!',
                style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),);
            }else{
              if(companyArea!.contains(userArea![index])){
                return ListTile(
                  title: Text(userArea![index]),
                  trailing: UserModel.role=="Manager".toUpperCase()
                      ? InkWell(
                        onTap: (){
                          deleteArea(userArea![index]);
                        },
                        child: Icon(Icons.delete,color: Colors.red,))
                      :Container(),
                );
              }else{
                UserDb(id: UserModel.userId).deleteUserArea(userArea![index]);
                return const SizedBox(height: 0);
              }
            }
          }
      )
    );
  }
  deleteArea(String areaName)async{
    await CompanyDb(id: CompanyModel.companyId).deleteArea(areaName).then((value){
      if(value==true){
        showSnackbar(context, Colors.green, "Deleted");
      }else{
        showSnackbar(context, Colors.red, "Error");
      }
    }).onError((error, stackTrace) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  showDialogueBox(){
    return showDialog(
        context: context,
        builder: (context){
      TextEditingController areaName=TextEditingController();
      return AlertDialog(
        title: const Text("Area Name"),
        content: TextFormField(
            controller: areaName,
            decoration: const InputDecoration(
              hintText: "Model Town",
            ),
            validator: (val){
              return val!.isEmpty?"Please insert name":null;
            },
          ),
        actions: [
          ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text("Cancel")),
          ElevatedButton(
              onPressed: (){
                if(areaName.text.isNotEmpty){
                  saveArea(areaName.text.toUpperCase());
                }else{

                }
              }, child: const Text("Save")),
        ],
      );
    });
  }
  saveArea(String areaName)async{
    await CompanyDb(id: CompanyModel.companyId).saveArea(areaName).then((value)async{
      if(value==true){
        await UserDb(id: UserModel.userId).updateAreaList(areaName).then((value){
          if(value==true){
            showSnackbar(context, Colors.cyan, "Saved Successfully");
            Navigator.pop(context);
          }else{
            Navigator.pop(context);
            showSnackbar(context, Colors.red, "Area with same name already available");
          }
        }).onError((error, stackTrace){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
        });
      }else{
        Navigator.pop(context);
        showSnackbar(context, Colors.red, "Area with same name already available");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
}

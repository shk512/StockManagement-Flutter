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
      floatingActionButton:   FloatingActionButton.extended(
          onPressed: (){
            showDialogueBox();
          },
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("Area",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
      ),
      body: UserModel.area==[]
        ? const Center(child:  Text(
          'No area added yet!',
          style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),)
        :ListView.builder(
          itemCount:UserModel.area.length /*userArea!.length*/,
          itemBuilder: (context,index){
            if(UserModel.area==[]){
              return const Center(
                child: Text(
                  'No area added yet!',
                style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),);
            }else{
                return ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Shop(areaName: UserModel.area[index],)));
                  },
                  title: Text(UserModel.area[index]),
                  trailing: UserModel.role=="Manager".toUpperCase()
                      ? InkWell(
                        onTap: (){
                          showWarningDialogue(UserModel.area[index]);
                        },
                        child: const Icon(Icons.delete,color: Colors.red,))
                      :Container(),
                );
            }
          }
      )
    );
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
                      Navigator.pop(context);
                      saveArea(areaName.text.toUpperCase());
                    }else{
                      Navigator.pop(context);
                      showSnackbar(context, Colors.red, "Not saved as field was empty");
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
            setState(() {
              UserModel.area.add(areaName);
            });
            showSnackbar(context, Colors.cyan, "Saved Successfully");
          }else{
            showSnackbar(context, Colors.red, "Area with same name already available");
          }
        }).onError((error, stackTrace){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
        });
      }else{
        showSnackbar(context, Colors.red, "Area with same name already available");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  deleteArea(String areaName)async{
    await CompanyDb(id: CompanyModel.companyId).deleteArea(areaName).then((value){
      if(value==true){
        showSnackbar(context, Colors.cyan, "Deleted");
        setState(() {
          UserModel.area.remove(areaName);
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
            content: const Text("Are you sure to delete this area?"),
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

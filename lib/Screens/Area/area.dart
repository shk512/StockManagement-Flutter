import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/user_company_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/area_db.dart';
import 'package:stock_management/utils/snackBar.dart';

class Area extends StatefulWidget {
  const Area({Key? key}) : super(key: key);

  @override
  State<Area> createState() => _AreaState();
}

class _AreaState extends State<Area> {
  List? area;
  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      area=UserModel.area;
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
          itemCount: area!.isEmpty?0:area!.length,
          itemBuilder: (context,index){
            if(area!.isEmpty){
              return const Center(child: Text('No area added yet!',
                style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold),),);
            }else{
              if(CompanyModel.area.contains(area![index])){
                return ListTile(
                  title: Text(area![index]),
                );
              }else{
                AreaDB(id: UserModel.userId).deleteUserArea(area![index]);
                return const SizedBox(height: 0);
              }
            }
          }
      )
    );
  }
  deleteArea(String areaId)async{
    await AreaDB(id: CompanyModel.companyId).deleteArea(areaId).then((value){
      if(value){
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
      final key=GlobalKey<FormState>();
      return AlertDialog(
        title: const Text("Area Name"),
        content: TextFormField(
          controller: areaName,
          decoration: InputDecoration(
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
                if(key.currentState!.validate()){
                  saveArea(areaName.text.toUpperCase());
                }
              }, child: const Text("Save")),
        ],
      );
    });
  }
  saveArea(String areaName)async{
    await AreaDB(id: CompanyModel.companyId).saveArea(areaName).then((value)async{
      if(value==true){
        await AreaDB(id: UserModel.userId).saveUserArea(areaName).then((value){
          if(value==true){
            showSnackbar(context, Colors.red, "Saved Successfully");
            Navigator.pop(context);
            setState(() {
            });
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

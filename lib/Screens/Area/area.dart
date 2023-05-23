import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Area/show_area_shop.dart';
import 'package:stock_management/Services/DB/area_db.dart';
import 'package:stock_management/Widgets/text_field.dart';

import '../../Models/area_model.dart';
import '../../Models/company_model.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class Area extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const Area({Key? key, required this.companyModel, required this.userModel}) : super(key: key);

  @override
  State<Area> createState() => _AreaState();
}

class _AreaState extends State<Area> {
  Stream? area;

  @override
  void initState() {
    super.initState();
    getArea();
  }
  getArea()async{
    await AreaDb(areaId: "", companyId: widget.companyModel.companyId).getArea().then((value){
      setState(() {
        area=value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
            },
          icon: Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: Text("Area"),
        actions: [
          widget.userModel.rights.contains(Rights.all) || widget.userModel.rights.contains(Rights.addArea)
              ?IconButton(
              onPressed: (){
            showSaveAreaDialogue();
          },
              icon: Icon(Icons.add,color: Colors.white,))
              :const SizedBox(),
        ],
      ),
      body: StreamBuilder(
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
              itemBuilder: (context,index) {
                return ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ShowAreaShop(areaId: snapshot.data.docs[index]["areaId"], companyModel: widget.companyModel, userModel: widget.userModel)));
                  },
                  title: Text("${snapshot.data.docs[index]["areaName"]}",style: TextStyle(fontWeight: FontWeight.bold),),
                  trailing: widget.userModel.rights.contains(Rights.all)
                      ? PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    onSelected: (value){
                      if(value==0){
                        showEditAreaDialogue(snapshot.data.docs[index]["areaId"], snapshot.data.docs[index]["areaName"]);
                      }
                      if(value==1){
                        if(widget.userModel.rights.contains(Rights.all)||widget.userModel.rights.contains(Rights.deleteArea)){
                          showWarningDialogue(snapshot.data.docs[index]["areaId"], snapshot.data.docs[index]["areaName"]);
                        }
                      }
                    },
                      itemBuilder: (context){
                        return [
                          PopupMenuItem(
                            value: 0,
                            child: Row(children: const [Icon(Icons.edit,color: Colors.black54,), SizedBox(width: 5,),Text("Edit")],),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Row(children: const [Icon(Icons.delete,color: Colors.black54,), SizedBox(width: 5,),Text("Delete")],),
                          ),
                        ];
                  }): const SizedBox()
                );
              });
        }
      }),
    );
  }
  showEditAreaDialogue(String areaId,  String areaName) {
    TextEditingController ctrl=TextEditingController();
    ctrl.text=areaName;
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("Edit Area"),
        content: TxtField(labelTxt: "Edit Area", hintTxt: "Your area name", ctrl: ctrl, icon: Icon(Icons.pin_drop_outlined)),
        actions: [
          ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text("Cancel",style: TextStyle(color: Colors.white),)),
          ElevatedButton(
              onPressed: (){
                if(ctrl.text.isNotEmpty){
                  Navigator.pop(context);
                  updateArea(areaId, ctrl.text);
                }else{
                  Navigator.pop(context);
                  showSnackbar(context, Colors.red.shade400, "Not updated as field was empty");
                }
              }, child: const Text("Update",style: TextStyle(color: Colors.white),)),
        ],
      );
    });
  }
  updateArea(String areaId, String areaName)async{
    await AreaDb(areaId: areaId, companyId: widget.companyModel.companyId).updateArea(areaName).then((value){
      showSnackbar(context, Colors.green.shade300, "Updated");
    });
  }

  showSaveAreaDialogue(){
    return showDialog(
        context: context,
        builder: (context){
          TextEditingController areaName=TextEditingController();
          return AlertDialog(
            title: const Text("New Area"),
            content: TxtField(labelTxt: "New Area", hintTxt: "Your area name", ctrl: areaName, icon: Icon(Icons.pin_drop_outlined)),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel",style: TextStyle(color: Colors.white),)),
              ElevatedButton(
                  onPressed: (){
                    if(areaName.text.isNotEmpty){
                      Navigator.pop(context);
                      saveArea(areaName.text);
                    }else{
                      Navigator.pop(context);
                      showSnackbar(context, Colors.red.shade400, "Not saved as field was empty");
                    }
                  }, child: const Text("Save",style: TextStyle(color: Colors.white),)),
            ],
          );
        });
  }
  saveArea(String areaName)async{
    String areaId=DateTime.now().microsecondsSinceEpoch.toString();
    AreaModel areaModel=AreaModel();
    areaModel.areaName=areaName;
    areaModel.areaId=areaId;
    await AreaDb(areaId: areaId, companyId: widget.companyModel.companyId).saveArea(areaModel.toJson()).then((value)async{
      if(value==true){
        showSnackbar(context, Colors.green.shade300, "Added");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }

  deleteArea(String areaId)async{
    await AreaDb(areaId: areaId, companyId: widget.companyModel.companyId).deleteArea().then((value){
      showSnackbar(context, Colors.green.shade300, "Deleted");
    }).onError((error, stackTrace) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  showWarningDialogue(String areaId, String areaName){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Warning"),
            content: Text("Are you sure to delete $areaName?"),
            actions: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel,color: Colors.red,)),
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                    deleteArea(areaId);
                  },
                  icon: const Icon(Icons.check_circle_rounded,color: Colors.green,)),
            ],
          );
        }
    );
  }
}

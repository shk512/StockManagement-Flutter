import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/area_model.dart';
import 'package:stock_management/Services/DB/area_db.dart';
import 'package:stock_management/utils/snackBar.dart';

import '../../Models/user_model.dart';
import '../../utils/routes.dart';

class Area extends StatefulWidget {
  const Area({Key? key}) : super(key: key);

  @override
  State<Area> createState() => _AreaState();
}

class _AreaState extends State<Area> {
  var area;
  @override
  void initState() {
    super.initState();
    getArea();
  }
  getArea()async{
    var request=await AreaDB(id: "").getArea();
    setState(() {
      area=request;
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
      body: StreamBuilder(
        stream: area,
        builder: (context,AsyncSnapshot snapshot){
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context,index){
                return ListTile(
                  onTap: (){
                    setAreaModel(snapshot.data.docs[index]["areaId"],snapshot.data.docs[index]["areaName"],snapshot.data.docs[index]["userId"]);
                    Navigator.pushNamed(context, Routes.shop);
                  },
                  title: Text("${snapshot.data.docs[index]["areaName"]}"),
                  trailing:UserModel.role=="Admin"
                      ?InkWell(
                      onTap: (){
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title: const Text("Warning"),
                            content: const Text("Are you sure to delete?"),
                            actions: [
                              ElevatedButton(onPressed: (){Navigator.pop(context);}, child: const Icon(Icons.cancel,color: Colors.red,)),
                              ElevatedButton(onPressed: (){deleteArea(snapshot.data.docs[index]["areaId"]);}, child: const Icon(Icons.done,color: Colors.green,)),
                            ],
                          );
                        });
                      },
                      child: const Icon(Icons.delete,color: Colors.red,))
                      :const SizedBox(),
                );
              });
        },
      ),
    );
  }
  setAreaModel(String areaId,String areaName,String userId){
    AreaModel(areaId, userId, areaName);
  }
  deleteArea(String areaId)async{
   await AreaDB(id: areaId).deleteArea().then((value){
     if(value){
       setState(() {

       });
       showSnackbar(context,Colors.cyan,"Deleted");
     }else{
       showSnackbar(context,Colors.cyan,"Error");
     }
   });
  }
}

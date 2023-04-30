import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/area_model.dart';
import 'package:stock_management/Models/company_model.dart';
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
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.pushNamed(context, Routes.addArea );
          },
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("Area",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)
      ),
      body: StreamBuilder(
        stream: area,
        builder: (context,AsyncSnapshot snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasError){
            return const Center(child: Text("error"),);
          }
          if(!snapshot.hasData){
            return const Center(child: Text("No Data Found"),);
          }else{
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context,index){

              });
          }
        },
      ),
    );
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

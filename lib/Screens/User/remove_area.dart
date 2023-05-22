import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/area_db.dart';

import '../../Functions/update_data.dart';
import '../../Models/company_model.dart';

class RemoveArea extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const RemoveArea({Key? key, required this.userModel, required this.companyModel}) : super(key: key);

  @override
  State<RemoveArea> createState() => _RemoveAreaState();
}

class _RemoveAreaState extends State<RemoveArea> {
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
    }).onError((error, stackTrace) => Navigator.push(context,MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(CupertinoIcons.back,color: Colors.white,)),
        title: Text("${widget.userModel.name}", style: const TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: StreamBuilder(
        stream: area,
        builder: (context, snapshot){
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
                  if(widget.userModel.area.contains(snapshot.data.docs[index]["areaId"])){
                    return ListTile(
                      onTap: (){
                        widget.userModel.area.remove(snapshot.data.docs[index]["areaId"]);
                        updateUserData(context, widget.userModel);
                        Navigator.pop(context);
                      },
                      title: Text("${snapshot.data.docs[index]["areaName"]}"),
                    );
                  }else{
                    return const SizedBox();
                  }
                });
          }
        },
      ),
    );
  }
}

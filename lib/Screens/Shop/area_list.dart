import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Shop/area_shop.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/area_db.dart';

class AreaList extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const AreaList({Key? key, required this.userModel, required this.companyModel}) : super(key: key);

  @override
  State<AreaList> createState() => _AreaListState();
}

class _AreaListState extends State<AreaList> {
  Stream? area;

  @override
  void initState() {
    super.initState();
    getArea();
  }
  getArea() async{
    await AreaDb(areaId: "", companyId: widget.companyModel.companyId).getArea().then((value){
      setState(() {
        area=value;
      });
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /*
          *
          * TAB
          *
          * */
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            child: SizedBox(
              height: 25,
              child: Row(
                children: [
                  //ALL
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.brown.shade300,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(18),bottomLeft: Radius.circular(18)),
                      ),
                      alignment: AlignmentDirectional.center,
                      child: const Text("ALL",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                    ),
                  ),
                  //AREA WISE
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(18),bottomRight: Radius.circular(18)),
                      ),
                      alignment: AlignmentDirectional.center,
                      child: const Text("AREA WISE",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*
          *
          * STREAM
          *
          * */
          Expanded(
            child: StreamBuilder(
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
                          return ListTile(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>AreaShop(areaId: snapshot.data.docs[index]["areaId"], companyModel: widget.companyModel, userModel: widget.userModel)));
                            },
                            title: Text("${snapshot.data.docs[index]["areaName"]}"),
                          );
                        });
                  }
                }),
          ),
        ],
      )
    );
  }
}

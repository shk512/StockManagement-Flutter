import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Order/4_order.dart';
import 'package:stock_management/Services/DB/user_db.dart';

import '../../Services/DB/order_db.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class EditUserId extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  final orderId;
  const EditUserId({Key? key,required this.orderId,required this.companyModel,required this.userModel}) : super(key: key);

  @override
  State<EditUserId> createState() => _EditUserIdState();
}

class _EditUserIdState extends State<EditUserId> {
  Stream? users;
  @override
  void initState() {
    super.initState();
    getUsers();
  }
  getUsers()async{
    await UserDb(id: "").getAllUser(widget.companyModel.companyId).then((value){
      setState(() {
        users=value;
      });
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),))));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Delivery Man",style: TextStyle(color: Colors.white),),
      ),
      body: StreamBuilder(
        stream: users,
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasError){
            return const Center(child: Text("Error"),);
          }
          if(!snapshot.hasData){
            return const Center(child: Text("No Data Found"),);
          }else{
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context,index){
                  List rights=List.from(snapshot.data.docs[index]["right"]);
                  if(snapshot.data.docs[index]["companyId"]==widget.companyModel.companyId&&rights.contains(Rights.all)||rights.contains(Rights.deliverOrder)){
                    return ListTile(
                      onTap: (){
                        addDeliveryMan(snapshot.data.docs[index]["userId"]);
                      },
                      title: Text("${snapshot.data.docs[index]["name"]}"),
                      subtitle: Text("${snapshot.data.docs[index]["phone"]}"),
                      trailing: Text("${snapshot.data.docs[index]["designation"]}"),
                    );
                  }else{
                    return const SizedBox();
                  }
                }
            );
          }
        },
      ),
    );
  }
  addDeliveryMan(String id)async{
    await OrderDB(companyId: widget.companyModel.companyId, orderId: widget.orderId).updateOrder({
      "deliverBy":id
    }).then((value) {
      showSnackbar(context, Colors.green.shade300, "Order Dispatch");
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Order(userModel: widget.userModel, companyModel: widget.companyModel)), (route) => false);
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),))));
  }
}

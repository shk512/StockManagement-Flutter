import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Services/DB/order_db.dart';


class Order extends StatefulWidget {
  const Order({Key? key}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  Stream? order;
  String tab="Processing".toUpperCase();
  TextEditingController searchController=TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
    getOrderData();
  }
  getOrderData()async{
    await OrderDB(companyId: CompanyModel.companyId, orderId: "").getOrder().then((value) {
      setState(() {
        order=value;
      });
    });
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
    title: Expanded(
      child: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "\t Search shop name here...",
          hintStyle: TextStyle(color: Colors.white),
          labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    ),
    centerTitle: true,
    ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                      //PROCESSING
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              tab="processing".toUpperCase();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18),bottomLeft: Radius.circular(18)),
                              color: tab=="processing".toUpperCase()?Colors.red:Colors.cyan.withOpacity(0.8),
                            ),
                            child:const Text("In-Process",style: TextStyle(color:Colors.white,fontWeight: FontWeight.bold),),
                          ),
                        ),
                      ),
                      //DISPATCH
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              tab="dispatch".toUpperCase();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: tab=="dispatch".toUpperCase()?Colors.amber:Colors.cyan.withOpacity(0.8)
                            ),
                            child: const Text("In-Route",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ),
                      //DELIVERED
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              tab="deliver".toUpperCase();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: tab=="deliver".toUpperCase()?Colors.green:Colors.cyan.withOpacity(0.8),
                            ),
                            child: const Text("Deliver",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ),
                      //ALL
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              tab="all".toUpperCase();
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(18),bottomRight: Radius.circular(18)),
                              color: tab=="all".toUpperCase()?Colors.black38:Colors.cyan.withOpacity(0.8),
                            ),
                            child: const Text("All",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),),
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
              stream: order,
              builder: (context,AsyncSnapshot snapshot){
                if(snapshot.connectionState==ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator(),);
                }
                if(snapshot.hasError){
                  return const Center(child: Text("Error"),);
                }
                if(!snapshot.hasData){
                  return const Center(child: Text("No Data Found"),);
                }
                if(snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          Color clr;
                          if(snapshot.data.docs[index]["status"]=="processing".toUpperCase()){
                            clr=Colors.red;
                          }else if(snapshot.data.docs[index]["status"]=="dispatch".toUpperCase()){
                            clr=Colors.amber;
                          }else if(snapshot.data.docs[index]["status"]=="deliver".toUpperCase()){
                            clr=Colors.green;
                          }else{
                            clr=Colors.black38;
                          }
                          if(searchController.text.isEmpty){
                            if(UserModel.role=="Manager".toUpperCase()){
                              if(tab.toUpperCase()=="All".toUpperCase()){
                                return  ListTile(
                                  title: Text("${snapshot.data.docs[index]["shopDetails"]}"),
                                  subtitle: Text("${snapshot.data.docs[index]["dateTime"]}"),
                                  trailing: Icon(Icons.brightness_1,color: clr,size: 10,),
                                );
                              }else{
                                if(snapshot.data.docs[index]["status"]==tab.toUpperCase()){
                                  return  ListTile(
                                    title: Text("${snapshot.data.docs[index]["shopDetails"]}"),
                                    subtitle: Text("${snapshot.data.docs[index]["dateTime"]}"),
                                  );
                                }else{
                                  return const SizedBox();
                                }
                              }
                            }else if(snapshot.data.docs[index]["userId"]==UserModel.userId){
                              if(tab.toUpperCase()=="All".toUpperCase()){
                                return  ListTile(
                                    title: Text("${snapshot.data.docs[index]["shopDetails"]}"),
                                    subtitle: Text("${snapshot.data.docs[index]["dateTime"]}"),
                                    trailing: Icon(Icons.brightness_1,color: clr,size: 10,)
                                );
                              }else{
                                if(snapshot.data.docs[index]["status"]==tab.toUpperCase()){
                                  return  ListTile(
                                    title: Text("${snapshot.data.docs[index]["shopDetails"]}"),
                                    subtitle: Text("${snapshot.data.docs[index]["dateTime"]}"),
                                  );
                                }else{
                                  return const SizedBox();
                                }
                              }
                            }else{
                              return const SizedBox();
                            }
                          }else{
                            if(snapshot.data.docs[index]["shopDetails"].contains(searchController.text)){
                              if(UserModel.role=="Manager".toUpperCase()){
                                if(tab.toUpperCase()=="All".toUpperCase()){
                                  return  ListTile(
                                    title: Text("${snapshot.data.docs[index]["shopDetails"]}"),
                                    subtitle: Text("${snapshot.data.docs[index]["dateTime"]}"),
                                    trailing: Icon(Icons.brightness_1,color: clr,size: 10,),
                                  );
                                }else{
                                  if(snapshot.data.docs[index]["status"]==tab.toUpperCase()){
                                    return  ListTile(
                                      title: Text("${snapshot.data.docs[index]["shopDetails"]}"),
                                      subtitle: Text("${snapshot.data.docs[index]["dateTime"]}"),
                                    );
                                  }else{
                                    return const SizedBox();
                                  }
                                }
                              }else if(snapshot.data.docs[index]["userId"]==UserModel.userId){
                                if(tab.toUpperCase()=="All".toUpperCase()){
                                  return  ListTile(
                                      title: Text("${snapshot.data.docs[index]["shopDetails"]}"),
                                      subtitle: Text("${snapshot.data.docs[index]["dateTime"]}"),
                                      trailing: Icon(Icons.brightness_1,color: clr,size: 10,)
                                  );
                                }else{
                                  if(snapshot.data.docs[index]["status"]==tab.toUpperCase()){
                                    return  ListTile(
                                      title: Text("${snapshot.data.docs[index]["shopDetails"]}"),
                                      subtitle: Text("${snapshot.data.docs[index]["dateTime"]}"),
                                    );
                                  }else{
                                    return const SizedBox();
                                  }
                                }
                              }else{
                                return const SizedBox();
                              }
                            }else{
                              return const SizedBox();
                            }
                          }
                        });
                }else{
                  return const Center(child: Text("Something Error"),);
                }
              }),)
        ],
      ),
    );
  }
}

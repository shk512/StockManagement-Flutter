import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Services/DB/user_db.dart';

import '../RegisterLogin/signup.dart';

class Employee extends StatefulWidget {
  const Employee({Key? key}) : super(key: key);

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  Stream? user;

  @override
  void initState() {
    super.initState();
    getUser();
  }
  getUser()async{
    var request=await UserDb(id: "").getAllUser();
      setState(() {
        user=request;
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
        title: const Text("Users",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup(companyId: CompanyModel.companyId)));
          },
          icon: const Icon(Icons.add,color: Colors.white,),
          label: const Text("User",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
      body: StreamBuilder(
        stream: user,
        builder: (context,AsyncSnapshot snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasError){
            return const Center(child: Text("Error"),);
          }
          if(snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context,index){
                  if(CompanyModel.companyId==snapshot.data.docs[index]["companyId"]){
                    return ListTile(
                        title: Text("${snapshot.data.docs[index]["name"]}"),
                  subtitle: Text("${snapshot.data.docs[index]["phone"]}"),
                  trailing: Text("${snapshot.data.docs[index]["role"]}"));
                  }else{
                    return const SizedBox();
                  }
                });
          }
          else{
            return const Center(child: Text("No Data Found"),);
          }
        },
      ),
    );
  }
}

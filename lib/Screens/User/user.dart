import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Screens/User/view_user.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Services/shared_preferences/spf.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Constants/rights.dart';
import '../../Constants/routes.dart';
import '../RegisterLogin/signup.dart';

class Employee extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const Employee({Key? key,required this.companyModel,required this.userModel}) : super(key: key);

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {
  Stream? user;
  bool isLoading=false;

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
    return isLoading
        ? const Center(child: CircularProgressIndicator(),)
        :Scaffold(
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
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup(companyId: widget.companyModel.companyId)));
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
                  if(widget.companyModel.companyId==snapshot.data.docs[index]["companyId"]&&snapshot.data.docs[index]["isDeleted"]==false){
                    return ListTile(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewUser(userId: snapshot.data.docs[index]["userId"], userModel: widget.userModel,companyModel: widget.companyModel,)));
                      },
                        title: Text("${snapshot.data.docs[index]["name"]}"),
                        subtitle: Text("${snapshot.data.docs[index]["phone"]}"),
                        trailing: widget.userModel.rights.contains(Rights.deleteUser)||widget.userModel.rights.contains(Rights.all)
                            ?IconButton(
                            onPressed: (){
                              showWarningDialogue(snapshot.data.docs[index]["userId"]);
                            },
                            icon: Icon(Icons.delete,color: Colors.red,))
                            :const SizedBox()
                    );
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
  showWarningDialogue(String userId){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Warning"),
            content: Text("Are you sure to delete this user?"),
            actions: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.cancel,color: Colors.red,)),
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                    deleteUser(userId);
                    setState(() {
                      isLoading=true;
                    });
                  },
                  icon: Icon(Icons.check_circle_rounded,color: Colors.green,)),
            ],
          );
        }
    );
  }
  deleteUser(String userId)async{
    await UserDb(id: userId).deleteUser().then((value)async{
      await SPF.saveUserLogInStatus(false);
      if(userId==FirebaseAuth.instance.currentUser!.uid){
        Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
      }else{
        setState(() {
          isLoading=false;
        });
        showSnackbar(context, Colors.cyan, "Deleted");
      }
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
  }
}

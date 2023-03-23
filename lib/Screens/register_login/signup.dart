import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Services/DB/company_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Services/shared_preferences/spf.dart';
import 'package:stock_management/Widgets/text_field.dart';
import 'package:stock_management/utils/enum.dart';
import 'package:stock_management/utils/snackBar.dart';

import '../../utils/routes.dart';

class Signup extends StatefulWidget {
  final String companyId;
  const Signup({Key? key,required this.companyId}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final formKey = GlobalKey<FormState>();
  TextEditingController mail = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController cPass = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController salary = TextEditingController();
  String role = "";
  UserRole _role = UserRole.admin;
  Auth auth=Auth();
  bool isLoading=false;

  @override
  void initState() {
    super.initState();
    getCompanyDetails();
  }

  getCompanyDetails() async {
    DocumentSnapshot snapshot=await CompanyDb(id: widget.companyId).getData();
    setState(() {
      Company.fromJson(snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ?const Center(child: CircularProgressIndicator(),)
          :SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: const Icon(CupertinoIcons.back,),
                  ),
                ),
                const SizedBox(height: 10,),
                const Image(image: AssetImage("image/signup.png")),
                Center(child: Text(Company.companyName,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 25),)),
                const SizedBox(height: 20,),
                TxtField(labelTxt: "Email",
                    hintTxt: "john@gmail.com",
                    ctrl: mail,
                    icon: const Icon(Icons.mail)),
                const SizedBox(height: 20,),
                TxtField(labelTxt: "Name",
                    hintTxt: "Your Name",
                    ctrl: name,
                    icon: const Icon(Icons.perm_identity)),
                const SizedBox(height: 20,),
                TxtField(labelTxt: "Contact",
                    hintTxt: "923001234567",
                    ctrl: contact,
                    icon: const Icon(Icons.phone)),
                const SizedBox(height: 20,),
                TxtField(labelTxt: "Password",
                    hintTxt: "Enter your password",
                    ctrl: pass,
                    icon: const Icon(Icons.password)),
                const SizedBox(height: 20,),
                TxtField(labelTxt: "Confirm Password",
                    hintTxt: "Retype your password",
                    ctrl: cPass,
                    icon: const Icon(Icons.password)),
                const SizedBox(height: 20,),
                const Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    "Role:", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                ),
                radioButtons("Admin", UserRole.admin),
                radioButtons("Order Taker", UserRole.orderTaker),
                radioButtons("Supplier", UserRole.supplier),
                radioButtons("Shop Keeper", UserRole.shopKeeper),
                _role == UserRole.admin
                    ? Container()
                    : TxtField(labelTxt: "Salary", hintTxt: "In digits", ctrl: salary, icon: const Icon(Icons.onetwothree)),
                const SizedBox(height: 20,),
                ElevatedButton(onPressed: (){
                  if(_role==UserRole.admin){
                    role="Admin";
                  }else if(_role==UserRole.supplier){
                    role="Supplier";
                  }else if(_role==UserRole.orderTaker){
                    role="Order Taker";
                  }else if(_role==UserRole.shopKeeper){
                    role="Shop Keeper";
                  }
                  if(pass.text==cPass.text){
                    signup();
                  }else{
                    showSnackbar(context, Colors.red, "Oops! Password doesn't match");
                  }

                }, child: const Text("Register")),
              ],
            ),
          ),
        ),
      )
    );
  }

  Widget radioButtons(String name, UserRole role) {
    return ListTile(
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Radio(
            value: role,
            groupValue: _role,
            onChanged: (UserRole? value) {
              setState(() {
                _role = value!;
              });
            })
    );
  }
  signup()async{
    if(formKey.currentState!.validate()){
      setState(() {
        isLoading=true;
      });
      await auth.createUser(mail.text, pass.text).then((value)async{
        if(value=="true"){
          await UserDb(id: FirebaseAuth.instance.currentUser!.uid).saveUser(UserModel(Company.companyId,mail.text,contact.text,role,salary.text,name.text,value.toString()).toJson()).then((value)async{
            if(value){
              setState(() {
                isLoading=false;
              });
              await SPF.saveUserLogInStatus(true);
              showSnackbar(context, Colors.cyan, "Registered Successffully!");
              Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard, (route) => false);
            }else{
              showSnackbar(context, Colors.red, "Error");
            }
          });
        }else{
          setState(() {
            isLoading=false;
          });
          showSnackbar(context, Colors.red, value.toString());
        }
      });
    }
  }
}
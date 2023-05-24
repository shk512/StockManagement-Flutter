import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Screens/RegisterLogin/signup.dart';
import 'package:stock_management/Services/DB/auth_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Widgets/num_field.dart';

class NewCompany extends StatefulWidget {
  const NewCompany({Key? key}) : super(key: key);

  @override
  State<NewCompany> createState() => _NewCompanyState();
}

class _NewCompanyState extends State<NewCompany> {
  TextEditingController license=TextEditingController();
  AuthDb db=AuthDb();
  final formKey=GlobalKey<FormState>();
  bool isLoading=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ?const Center(child: CircularProgressIndicator())
          :Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(CupertinoIcons.back,color: Colors.white,),
                ),
              ),
              const SizedBox(height: 10,),
              NumField(labelTxt: "License Key", hintTxt: "Your company's license key....", ctrl: license, icon: const Icon(Icons.key)),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: (){
                licenseCheck();
              }, child: const Text("Submit",style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(height: 30),
              const Text("For any issue or assistance,\nPlease contact or whatsApp \n0310-7136172",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,letterSpacing: 2),
              )
            ]
          ),
      ),
    );
  }
  licenseCheck() async{
    if(formKey.currentState!.validate()){
      setState(() {
        isLoading=true;
      });
      await db.licenseKey(license.text).then((value){
        if(value==true){
          setState(() {
            isLoading=false;
          });
         Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup(companyId: license.text,key: Key("signup"),)));
        }else{
          setState(() {
            isLoading=false;
          });
          showSnackbar(context, Colors.red.shade400, "Oops! no valid license");
        }
      });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:stock_management/Screens/register_login/signup.dart';
import 'package:stock_management/Services/DB/auth_db.dart';
import 'package:stock_management/Widgets/text_field.dart';
import 'package:stock_management/utils/snackBar.dart';

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
              TxtField(labelTxt: "License Key", hintTxt: "Your company's license key....", ctrl: license, icon: const Icon(Icons.warehouse_outlined)),
              const SizedBox(height: 30),
              ElevatedButton(onPressed: (){
                licenseCheck();
              }, child: const Text("Submit"),
              ),
              const SizedBox(height: 30),
              const Text("For any query or assistance,\nPlease contact or whatsApp \n0310-7136172",
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
        if(value){
          setState(() {
            isLoading=false;
          });
         Navigator.push(context, MaterialPageRoute(builder: (context)=>Signup(companyId: license.text)));
        }else{
          setState(() {
            isLoading=false;
          });
          showSnackbar(context, Colors.red, "Oops! no valid license");
        }
      });
    }
  }
}
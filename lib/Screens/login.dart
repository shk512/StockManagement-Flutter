import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company.dart';
import 'package:stock_management/Models/user.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Services/DB/company_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Services/shared_preferences/spf.dart';
import 'package:stock_management/Widgets/text_field.dart';
import 'package:stock_management/utils/snackBar.dart';

import '../utils/routes.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin{
  late final AnimationController _controller=AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this
  )..repeat();
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  TextEditingController mail=TextEditingController();
  TextEditingController pass=TextEditingController();
  final formKey=GlobalKey<FormState>();
  Auth auth=Auth();
  bool isLoading=false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ?const Center(child: CircularProgressIndicator())
      :SingleChildScrollView(
        child:Center(
            child: Form(
                key: formKey,
                child: Column(
                  
                  children:[
                    const Image(image: AssetImage("image/login.png")),
                    const SizedBox(height: 20),
                    TxtField(labelTxt: "Email", hintTxt: "Enter your email", ctrl: mail, icon: const Icon(Icons.mail_outline_sharp)),
                    const SizedBox(height: 20,),
                    TxtField(labelTxt: "Password", hintTxt: "Enter Your Password", ctrl: pass, icon: const Icon(Icons.password)),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: (){
                      login();
                    }, child: const Text('Login')),
                    const SizedBox(height: 20),
                    Text.rich(
                      TextSpan(
                        text: "New Company? ",
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: "Register here",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(
                                      context, Routes.newCompany);
                                })
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ),
        ),
    );
  }
  login() async{
    if(formKey.currentState!.validate()){
      setState(() {
        isLoading=true;
      });
      await auth.signInWithEmailAndPassword(mail.text, pass.text).then((value)async{
        if(value!=null){
          DocumentSnapshot snapshot=await UserDb(id: value.toString()).getData();
          await UserModel.fromJson(snapshot);
          snapshot=await CompanyDb(id: UserModel.companyId).getData();
          await Company.fromJson(snapshot);
          await SPF.saveUserLogInStatus(true);
          Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard, (route) => false);
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

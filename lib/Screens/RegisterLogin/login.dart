import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Widgets/text_field.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Services/shared_preferences/spf.dart';
import '../../Constants/routes.dart';
import '../Splash_Error/error.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController mail=TextEditingController();
  TextEditingController pass=TextEditingController();
  final formKey=GlobalKey<FormState>();
  Auth auth=Auth();
  bool isLoading=false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
        body: isLoading
            ?const Center(child: CircularProgressIndicator())
            :Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          const Text("Login",style: TextStyle(fontWeight: FontWeight.w900,color: Colors.brown,fontSize: 55, fontFamily:"Lobster Two",letterSpacing: 2),),
                          SizedBox(height: MediaQuery.of(context).size.height*.03),
                          TxtField(labelTxt: "Email", hintTxt: "Enter your email", ctrl: mail, icon: const Icon(Icons.mail_outline_sharp)),
                          TxtField(labelTxt: "Password", hintTxt: "Enter Your Password", ctrl: pass, icon: const Icon(Icons.lock_outline_rounded)),
                          SizedBox(height: MediaQuery.of(context).size.height*.01),
                          ElevatedButton(onPressed: (){
                            login();
                          }, child: const Text('Login',style: TextStyle(color: Colors.white),)),
                          SizedBox(height: MediaQuery.of(context).size.height*.01),
                          Text.rich(
                            TextSpan(
                              text: "Don't have an account? ",
                              style: const TextStyle(
                                color: Colors.brown,
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
                          SizedBox(height: MediaQuery.of(context).size.height*.01),
                          Text.rich(
                            TextSpan(
                              text: "Forgot Password? ",
                              style: const TextStyle(
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: "Click here",
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushNamed(
                                            context, Routes.resetPassword);
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
        if(value==true){
          await SPF.saveUserLogInStatus(true);
          Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard, (route) => false);
        }else{
          setState(() {
            isLoading=false;
          });
          showSnackbar(context, Colors.red.shade400, value.toString());
        }
      }).onError((error, stackTrace){
        setState(() {
          isLoading=false;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
      });
    }
  }
}

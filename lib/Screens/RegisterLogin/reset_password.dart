import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Widgets/text_field.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController mail=TextEditingController();
  Auth auth=Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TxtField(labelTxt: "Email", hintTxt: "Enter your mail", ctrl: mail, icon: Icon(Icons.mail_outline)),
              const SizedBox(height: 20,),
              ElevatedButton(
                  onPressed: (){
                    if(EmailValidator.validate(mail.text)){
                      try{
                        auth.resetPassword(mail.text);
                        Navigator.pop(context);
                      }catch(e){
                        showSnackbar(context, Colors.red.shade400, e.toString());
                      }
                    }else{
                      showSnackbar(context, Colors.red.shade400, "Email is invalid");
                    }
                  },
                child: Text("Send Email Link"),
              )
            ],
          ),
      ),
    );
  }
}

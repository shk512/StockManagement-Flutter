import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

class TxtField extends StatefulWidget {
  final String hintTxt;
  final String labelTxt;
  final Icon icon;
  final TextEditingController ctrl;
  const TxtField({Key? key,required this.labelTxt,required this.hintTxt,required this.ctrl,required this.icon}) : super(key: key);

  @override
  State<TxtField> createState() => _TxtFieldState();
}

class _TxtFieldState extends State<TxtField> {
  bool _hide=true;
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 9,
            child: TextFormField(
                obscureText: widget.labelTxt=='Password'||widget.labelTxt=='Confirm Password'?_hide:false,
                controller: widget.ctrl,
                decoration: InputDecoration(
                  icon: widget.icon,
                  border: const OutlineInputBorder(),
                  labelText: widget.labelTxt,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                  hintText: widget.hintTxt,
                ),
                validator: (val) {
                  if(widget.labelTxt=="Password"||widget.labelTxt=="Confirm Password"){
                    return val!.length<6?"Contains min six characters":null;
                  }else if(widget.labelTxt=="Email"){
                    return EmailValidator.validate(val!)?null:"Invalid";
                  }else{
                    return val!.isNotEmpty?null:"Invalid";
                  }
                }
            ),
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 1,
            child: widget.labelTxt=="Password"||widget.labelTxt=='Confirm Password'
                ?GestureDetector(
              onTap: (){
                setState(() {
                  _hide=!_hide;
                });
              },
              child: Icon(Icons.remove_red_eye,color: _hide?Colors.grey:Colors.cyan),
      )
          :const SizedBox(),
      ),
      ]
      ),
    );
  }
}
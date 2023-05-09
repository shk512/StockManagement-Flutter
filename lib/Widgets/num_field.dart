import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumField extends StatefulWidget {
  final String hintTxt;
  final String labelTxt;
  final Icon icon;
  final TextEditingController ctrl;
  const NumField({Key? key,required this.icon,required this.ctrl,required this.hintTxt,required this.labelTxt}) : super(key: key);

  @override
  State<NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<NumField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
      child: Row(
          children: [
            Expanded(
              flex: 9,
              child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
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
                    if(widget.labelTxt=="Contact"){
                      return val!.length==11?null:"Invalid";
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
              child: Container(),
            ),
          ]
      ),
    );
  }
}

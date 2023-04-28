import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/area_model.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Services/DB/area_db.dart';
import 'package:stock_management/Widgets/text_field.dart';
import 'package:stock_management/utils/snackBar.dart';

class AddArea extends StatefulWidget {
  const AddArea({Key? key}) : super(key: key);

  @override
  State<AddArea> createState() => _AddAreaState();
}

class _AddAreaState extends State<AddArea> {
  final formKey=GlobalKey<FormState>();
  TextEditingController areaCtrl=TextEditingController();
  bool isLoading=false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator(),)
          :SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Icon(CupertinoIcons.back),
                ),
                const SizedBox(height: 20,),
                const Text("Area DETAILS",style: TextStyle(color: Colors.cyan,letterSpacing: 2,fontSize: 25,fontWeight: FontWeight.bold),),
                const SizedBox(height: 20,),
                TxtField(labelTxt: "Area", hintTxt: "Area name...", ctrl: areaCtrl, icon: const Icon(Icons.pin_drop)),
                const SizedBox(height: 20,),
                ElevatedButton(
                      onPressed: (){
                        save();
                      },
                      child: const Text("Save")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  save() async{
    if(formKey.currentState!.validate()){
      setState(() {
        isLoading=true;
      });
      String areaId=DateTime.now().microsecondsSinceEpoch.toString();
      await AreaDB(id: areaId).saveArea(AreaModel(CompanyModel.companyId, areaId, "","", areaCtrl.text).toJson()).then((value){
        if(value!){
          setState(() {
            isLoading=false;
          });
          showSnackbar(context, Colors.cyan, "Saved Successfully");
          Navigator.pop(context);
        }else{
          setState(() {
            isLoading=false;
          });
          showSnackbar(context, Colors.red, "Oops! Error");
        }
      });
    }
  }
}

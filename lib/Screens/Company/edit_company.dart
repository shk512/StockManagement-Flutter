import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Services/DB/company_db.dart';
import '../../Widgets/num_field.dart';
import '../../Widgets/text_field.dart';

class EditCompany extends StatefulWidget {
  final CompanyModel companyModel;
  const EditCompany({Key? key,required this.companyModel}) : super(key: key);

  @override
  State<EditCompany> createState() => _EditCompanyState();
}

class _EditCompanyState extends State<EditCompany> {
  TextEditingController companyName=TextEditingController();
  TextEditingController city=TextEditingController();
  TextEditingController phone=TextEditingController();
  String imageUrl="";
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
      setState(() {
        companyName.text=widget.companyModel.companyName;
        city.text=widget.companyModel.city;
        phone.text=widget.companyModel.contact;
        imageUrl=widget.companyModel.imageUrl;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: Text(widget.companyModel.companyName,style: const TextStyle(color: Colors.white),),
        actions: [
          ElevatedButton(
            onPressed: (){
              if(formKey.currentState!.validate()){
                update();
              }
            },
            child: const Text("Update",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TxtField(labelTxt: "Company Name", hintTxt: "e.g. Candy Land", ctrl: companyName, icon: const Icon(Icons.warehouse)),
                TxtField(labelTxt: "City", hintTxt: "City Name...", ctrl: city, icon: const Icon(Icons.location_city)),
                NumField(icon: const Icon((Icons.phone)), ctrl: phone, hintTxt: "03001234567", labelTxt: "Contact"),
              ],
            ),
          ),
        ),
      ),
    );
  }
  update() async{
    if(formKey.currentState!.validate()){
      setState(() {
        isLoading=true;
      });
      widget.companyModel.companyName=companyName.text.toUpperCase();
      widget.companyModel.contact=phone.text;
      widget.companyModel.city=city.text.toUpperCase();
      widget.companyModel.imageUrl=imageUrl;
      await CompanyDb(id: widget.companyModel.companyId).updateCompany(widget.companyModel.toJson()).then((value)async{
        showSnackbar(context, Colors.green.shade300, "Updated");
        Navigator.pop(context);
      }).onError((error, stackTrace){
        showSnackbar(context, Colors.red.shade400, error.toString());
      });
        }else{
          setState(() {
            isLoading=false;
          });
          showSnackbar(context, Colors.red.shade400, "Error. Please Try Again!");
        }
  }
}
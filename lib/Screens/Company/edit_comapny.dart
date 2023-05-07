import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Functions/update_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Services/DB/company_db.dart';
import '../../Widgets/num_field.dart';
import '../../Widgets/text_field.dart';

class EditCompany extends StatefulWidget {
  const EditCompany({Key? key}) : super(key: key);

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
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid).then((value){
      setState(() {
        companyName.text=CompanyModel.companyName;
        city.text=CompanyModel.city;
        phone.text=CompanyModel.contact;
        imageUrl=CompanyModel.imageUrl;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: Text(CompanyModel.companyName,style: const TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            update();
          },
          label: Text("Update",style: TextStyle(color: Colors.white),)),
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
                const SizedBox(height: 20),
                TxtField(labelTxt: "City", hintTxt: "City Name...", ctrl: city, icon: const Icon(Icons.location_city)),
                const SizedBox(height: 20),
                NumField(icon: const Icon((Icons.phone)), ctrl: phone, hintTxt: "03001234567", labelTxt: "Contact"),
              ],
            ),),
        ),
      ),
    );
  }
  update() async{
    if(formKey.currentState!.validate()){
      setState(() {
        isLoading=true;
      });
      await CompanyDb(id: CompanyModel.companyId).updateCompany(
          CompanyModel.toJson(
              companyId: CompanyModel.companyId,
              companyName: companyName.text,
              contact: phone.text,
              whatsApp: CompanyModel.whatsApp,
              packageEndsDate: CompanyModel.packageEndsDate,
              packageType: CompanyModel.packageType,
              city: city.text,
              wallet: CompanyModel.wallet,
              area: CompanyModel.area,
              isPackageActive: CompanyModel.isPackageActive,
              location: LatLng(CompanyModel.location.latitude, CompanyModel.location.longitude),
              imageUrl: imageUrl
          )
      ).then((value)async{
        showSnackbar(context, Colors.cyan, "Updated");
        Navigator.pop(context);
      }).onError((error, stackTrace){
        showSnackbar(context, Colors.red, error.toString());
      });
        }else{
          setState(() {
            isLoading=false;
          });
          showSnackbar(context, Colors.red, "Error. Please Try Again!");
        }
  }
}
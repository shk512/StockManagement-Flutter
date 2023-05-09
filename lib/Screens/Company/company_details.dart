import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Services/DB/company_db.dart';

import '../../Constants/routes.dart';
import '../../Models/user_model.dart';
import '../../Widgets/row_info_display.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class CompanyDetails extends StatefulWidget {
  const CompanyDetails({Key? key}) : super(key: key);

  @override
  State<CompanyDetails> createState() => _CompanyDetailsState();
}

class _CompanyDetailsState extends State<CompanyDetails> {
  GeoPoint location=const GeoPoint(0,0);
  CompanyModel _companyModel=CompanyModel();
  UserModel _userModel=UserModel();
  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(_companyModel,_userModel);
    getLatitudeAndLongitude();
  }
  getLatitudeAndLongitude()async{
   await CompanyDb(id: _companyModel.companyId).getData().then((value){
      if(location.latitude!=0&&location.longitude!=0){
        setState(() {
          location=value["geoLocation"];
        });
      }
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
        title: const Text("Company",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          _userModel.rights.contains(Rights.viewCompanyWallet)||_userModel.rights.contains(Rights.all)
          ?const Icon(Icons.account_balance_wallet_outlined,color: Colors.white,):const SizedBox(),
          _userModel.rights.contains(Rights.viewCompanyWallet)||_userModel.rights.contains(Rights.all)
              ?Padding(
            padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            child: Text(
              "Rs. ${_companyModel.wallet}",
              style: const TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.center,),)
              :const SizedBox(),
          _userModel.rights.contains(Rights.editCompany)||_userModel.rights.contains(Rights.all)
              ?IconButton(
              onPressed: (){
                Navigator.pushNamed(context, Routes.editCompany);
              }, icon: const Icon(Icons.edit,color: Colors.white,))
              :const SizedBox()
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RowInfoDisplay(label: "Status", value:_companyModel.isPackageActive?"Active":"InActive"),
              const SizedBox(height: 5),
              _companyModel.packageType=="LifeTime".toUpperCase()||_companyModel.packageEndsDate==""
                  ?const SizedBox()
                  :RowInfoDisplay(label: "Package Ends Date", value:_companyModel.packageEndsDate),
              const SizedBox(height: 5),
              RowInfoDisplay(label: "Name", value:_companyModel.companyName),
              const SizedBox(height: 5),
              RowInfoDisplay(label: "City", value:_companyModel.city),
              const SizedBox(height: 5),
              RowInfoDisplay(label: "Contact", value: _companyModel.contact),
              const SizedBox(height: 5),
              RowInfoDisplay(label: "Package", value: _companyModel.packageType),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(child: Text("Area",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900,color: Colors.cyan),)),
                  _userModel.rights.contains(Rights.addArea) || _userModel.rights.contains(Rights.all)
                      ? Expanded(
                      child: IconButton(
                          onPressed: (){
                            showDialogueBox();
                          },
                        icon: const Icon(Icons.add,color: Colors.cyan,) ,
                          ),
                  ): const SizedBox()
                ],
              ),
              const SizedBox(height: 5),
              areaList(),
            ],
          ),
        ),
      ),
    );
  }
  Widget areaList(){
    return Column(
      children: _companyModel.area.map((e) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: InkWell(
            onTap: (){
              if(_userModel.rights.contains(Rights.deleteArea)||_userModel.rights.contains(Rights.all)){
                showWarningDialogue(e);
              }
            },
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(">\t\t $e")),
          ))).toList(),
    );
  }
  showDialogueBox(){
    return showDialog(
        context: context,
        builder: (context){
          TextEditingController areaName=TextEditingController();
          return AlertDialog(
            title: const Text("Area Name"),
            content: TextFormField(
              controller: areaName,
              decoration: const InputDecoration(
                hintText: "Model Town",
              ),
              validator: (val){
                return val!.isEmpty?"Please insert name":null;
              },
            ),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              ElevatedButton(
                  onPressed: (){
                    if(areaName.text.isNotEmpty){
                      Navigator.pop(context);
                      saveArea(areaName.text.toUpperCase());
                    }else{
                      Navigator.pop(context);
                      showSnackbar(context, Colors.red, "Not saved as field was empty");
                    }
                  }, child: const Text("Save")),
            ],
          );
        });
  }
  saveArea(String areaName)async{
    await CompanyDb(id: _companyModel.companyId).saveArea(areaName).then((value)async{
      if(value==true){
        setState(() {
          _companyModel.area.add(areaName);
        });
      }else{
        showSnackbar(context, Colors.red, "Area with same name already available");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  deleteArea(String areaName)async{
    await CompanyDb(id: _companyModel.companyId).deleteArea(areaName).then((value){
      if(value==true){
        showSnackbar(context, Colors.cyan, "Deleted");
        setState(() {
          _companyModel.area.remove(areaName);
        });
      }else{
        showSnackbar(context, Colors.red, "Error");
      }
    }).onError((error, stackTrace) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  showWarningDialogue(String areaName){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Warning"),
            content: Text("Are you sure to delete area $areaName?"),
            actions: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel,color: Colors.red,)),
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                    deleteArea(areaName);
                  },
                  icon: const Icon(Icons.check_circle_rounded,color: Colors.green,)),
            ],
          );
        }
    );
  }
}

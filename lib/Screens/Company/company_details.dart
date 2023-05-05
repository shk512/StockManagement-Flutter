import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Functions/get_data.dart';
import 'package:stock_management/Functions/location.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/geolocation_model.dart';
import 'package:stock_management/Services/DB/company_db.dart';

import '../../Widgets/row_info_display.dart';
import '../../utils/routes.dart';

class CompanyDetails extends StatefulWidget {
  const CompanyDetails({Key? key}) : super(key: key);

  @override
  State<CompanyDetails> createState() => _CompanyDetailsState();
}

class _CompanyDetailsState extends State<CompanyDetails> {
  String address="";
  var lat;
  var lng;
  @override
  void initState() {
    super.initState();
    getUserAndCompanyData(FirebaseAuth.instance.currentUser!.uid);
    getLatitudeAndLongitude();
    if(lat!=0&&lng!=0){
      getAddress();
    }
  }
  getLatitudeAndLongitude()async{
   await CompanyDb(id: CompanyModel.companyId).getData().then((value){
      if(value["geoLocation"]["lat"]!=null&&value["geoLocation"]["lng"]!=null){
        setState(() {
          lat=value["geoLocation"]["lat"];
          lng=value["geoLocation"]["lng"];
        });
      }else{
        setState(() {
          lat=0;
          lng=0;
        });
      }
    });
  }
  getAddress(){
    setState(() {
      address=convertCoordiantesToAddress(GeoLocationModel.lat, GeoLocationModel.lng).toString();
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
        title: const Text("Profile",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          const Icon(Icons.account_balance_wallet_outlined,color: Colors.white,),
          Padding(
            padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            child: Text(
              "Rs. ${CompanyModel.wallet}",
              style: const TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.center,),),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RowInfoDisplay(label: "Status", value:CompanyModel.isPackageActive?"Active":"InActive"),
              const SizedBox(height: 5),
              CompanyModel.packageType=="LifeTime".toUpperCase()||CompanyModel.packageEndsDate==""
                  ?const SizedBox()
                  :RowInfoDisplay(label: "Package Ends Date", value:CompanyModel.packageEndsDate),
              const SizedBox(height: 5),
              RowInfoDisplay(label: "Company Name", value:CompanyModel.companyName),
              const SizedBox(height: 5),
              RowInfoDisplay(label: "Address", value:address),
              const SizedBox(height: 5),
              RowInfoDisplay(label: "City", value:CompanyModel.city),
              const SizedBox(height: 5),
              RowInfoDisplay(label: "Contact", value: CompanyModel.contact),
              const SizedBox(height: 5),
              RowInfoDisplay(label: "Package", value: CompanyModel.packageType),
              const SizedBox(height: 10),
              const Align(
                  alignment: Alignment.center,
                  child:  Text("Area",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w900),)),
              const SizedBox(height: 10),
              areaList(),
              const SizedBox(height: 10),
              ElevatedButton(
                  onPressed: (){
                    Navigator.pushNamed(context, Routes.area);
                  },
                  child: const Text('Area'))
            ],
          ),
        ),
      ),
    );
  }
  Widget areaList(){
    return Column(
      children: CompanyModel.area.map((e) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(">\t\t $e")))).toList(),
    );
  }
}

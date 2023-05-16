import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Functions/image_upload.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Company/edit_company.dart';
import 'package:stock_management/Services/DB/company_db.dart';

import '../../Functions/update_data.dart';
import '../../Models/user_model.dart';
import '../../Widgets/row_info_display.dart';
import '../../utils/snack_bar.dart';
import '../Splash_Error/error.dart';

class CompanyDetails extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const CompanyDetails({Key? key,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<CompanyDetails> createState() => _CompanyDetailsState();
}

class _CompanyDetailsState extends State<CompanyDetails> {
  GeoPoint location=const GeoPoint(0,0);

  @override
  void initState() {
    super.initState();
    getLatitudeAndLongitude();
  }
  getLatitudeAndLongitude()async{
   await CompanyDb(id: widget.companyModel.companyId).getData().then((value){
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
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.back,color: Colors.white,),
        ),
        title: const Text("Company",style: TextStyle(color: Colors.white),),
        actions: [
          widget.userModel.rights.contains(Rights.viewCompanyWallet)||widget.userModel.rights.contains(Rights.all)
          ?const Icon(Icons.account_balance_wallet_outlined,color: Colors.white,):const SizedBox(),
          widget.userModel.rights.contains(Rights.viewCompanyWallet)||widget.userModel.rights.contains(Rights.all)
              ?Padding(
            padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            child: Text(
              "Rs. ${widget.companyModel.wallet}",
              style: const TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.center,),)
              :const SizedBox(),
          widget.userModel.rights.contains(Rights.editCompany)||widget.userModel.rights.contains(Rights.all)
              ?IconButton(
              onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (context)=>EditCompany(companyModel: widget.companyModel)));
              }, icon: const Icon(Icons.edit,color: Colors.white,))
              :const SizedBox()
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: ()async{
                  try{
                    widget.companyModel.imageUrl=await uploadImage();
                    updateCompanyData(context,widget.companyModel);
                  }catch(e){
                    showSnackbar(context, Colors.red, e);
                  }
                },
                child: widget.companyModel.imageUrl.isNotEmpty
                    ?CircleAvatar(
                  backgroundImage: NetworkImage(widget.companyModel.imageUrl),
                  backgroundColor: Colors.brown.shade300,
                  radius: 100,
                )
                    :Icon(Icons.image,size: 70,),
              ),
              SizedBox(height: 10,),
              RowInfoDisplay(label: "Status", value:widget.companyModel.isPackageActive?"Active":"InActive"),
              RowInfoDisplay(label: "Package", value: widget.companyModel.packageType),
              widget.companyModel.packageType=="LifeTime".toUpperCase()||widget.companyModel.packageEndsDate==""
                  ?const SizedBox()
                  :RowInfoDisplay(label: "Package Ends Date", value:widget.companyModel.packageEndsDate),
              RowInfoDisplay(label: "Name", value:widget.companyModel.companyName),
              RowInfoDisplay(label: "City", value:widget.companyModel.city),
              RowInfoDisplay(label: "Contact", value: widget.companyModel.contact),
              const SizedBox(height: 10,),
              widget.companyModel.location.latitude==0&&widget.companyModel.location.longitude==0
                  ? RowInfoDisplay(value: "Not Set", label: "Location")
                  : Container(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                      target: LatLng(widget.companyModel.location.latitude, widget.companyModel.location.longitude),
                    zoom: 14.4746,
                  ),

                ),
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  const Expanded(child: Text("Area",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w900,color: Colors.brown),)),
                  widget.userModel.rights.contains(Rights.addArea) || widget.userModel.rights.contains(Rights.all)
                      ? Expanded(
                      child: IconButton(
                          onPressed: (){
                            showDialogueBox();
                          },
                        icon: const Icon(Icons.add,color: Colors.brown,) ,
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
      children: widget.companyModel.area.map((e) => Align(
          alignment: AlignmentDirectional.centerStart,
          child: InkWell(
            onTap: (){
              if(widget.userModel.rights.contains(Rights.deleteArea)||widget.userModel.rights.contains(Rights.all)){
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
                  child: const Text("Cancel",style: TextStyle(color: Colors.white),)),
              ElevatedButton(
                  onPressed: (){
                    if(areaName.text.isNotEmpty){
                      Navigator.pop(context);
                      saveArea(areaName.text.toUpperCase());
                    }else{
                      Navigator.pop(context);
                      showSnackbar(context, Colors.red.shade400, "Not saved as field was empty");
                    }
                  }, child: const Text("Save",style: TextStyle(color: Colors.white),)),
            ],
          );
        });
  }
  saveArea(String areaName)async{
    await CompanyDb(id: widget.companyModel.companyId).saveArea(areaName).then((value)async{
      if(value==true){
        setState(() {
          widget.companyModel.area.add(areaName);
        });
      }else{
        showSnackbar(context, Colors.red.shade400, "Area with same name already available");
      }
    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  deleteArea(String areaName)async{
    await CompanyDb(id: widget.companyModel.companyId).deleteArea(areaName).then((value){
      if(value==true){
        showSnackbar(context, Colors.green.shade300, "Deleted");
        setState(() {
          widget.companyModel.area.remove(areaName);
        });
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
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

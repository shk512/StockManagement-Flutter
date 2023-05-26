import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Functions/image_upload.dart';
import 'package:stock_management/Functions/location.dart';
import 'package:stock_management/Functions/open_map.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Company/edit_company.dart';
import 'package:stock_management/Services/DB/company_db.dart';

import '../../Functions/update_data.dart';
import '../../Models/user_model.dart';
import '../../Services/DB/area_db.dart';
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
  Stream? area;
  List<Marker> _marker=[];

  @override
  void initState() {
    super.initState();
    getLatitudeAndLongitude();
    getArea();
  }
  getArea()async{
    await AreaDb(areaId: "", companyId: widget.companyModel.companyId).getArea().then((value){
      setState(() {
        area=value;
      });
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),))));
  }
  getLatitudeAndLongitude()async{
   await CompanyDb(id: widget.companyModel.companyId).getData().then((value){
      if(location.latitude!=0&&location.longitude!=0){
        setState(() {
          location=value["geoLocation"];
          _marker.add(
              Marker(
                markerId: MarkerId("company"),
                position: LatLng(location.latitude, location.longitude),
                infoWindow: InfoWindow(
                  title: "${widget.companyModel.companyName}"
                )
              ),
          );
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
              onPressed: ()async{
                await Navigator.push(context,MaterialPageRoute(builder: (context)=>EditCompany(companyModel: widget.companyModel)));
                setState(() {

                });
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
                    await uploadImage().then((value){
                      setState((){
                        widget.companyModel.imageUrl=value;
                      });
                      showSnackbar(context, Colors.green.shade300, "Uploaded");
                    });
                    updateCompanyData(context,widget.companyModel);
                  }catch(e){
                    showSnackbar(context, Colors.red, e);
                  }
                },
                child: widget.companyModel.imageUrl.isNotEmpty
                    ?CircleAvatar(
                  backgroundImage: NetworkImage(widget.companyModel.imageUrl),
                  radius: 150,
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
                  : Column(
                children: [
                  Container(
                      color: Colors.brown,
                      height: 50,
                      child: InkWell(
                        onTap: (){
                          openMap(widget.companyModel.location.latitude, widget.companyModel.location.longitude);
                        },
                        child: Row(
                          mainAxisAlignment:  MainAxisAlignment.center,
                          children: [
                            Text(
                              "Navigate", style:  TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                            ),
                            Icon(Icons.navigation_outlined,color: Colors.white,)
                          ],
                        ),
                      )
                  ),
                  Container(
                    height: 300,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(widget.companyModel.location.latitude, widget.companyModel.location.longitude),
                        zoom: 14.4746,
                      ),
                      markers: Set<Marker>.of(_marker),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      color: Colors.brown,
                      child: ElevatedButton.icon(
                          onPressed: (){
                            showNavigationDialogue();
                          },
                          icon: Icon(Icons.pin_drop_outlined),
                          label: Text("Edit Location"))
                  ),
                ],
              ),
              widget.companyModel.location.latitude==0&&widget.companyModel.location.longitude==0
                  ? Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  color: Colors.brown,
                  child: ElevatedButton.icon(
                      onPressed: (){
                        showNavigationDialogue();
                      },
                      icon: Icon(Icons.pin_drop_outlined),
                      label: Text("Set Comapny Location"))
              ): const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
  showNavigationDialogue(){
    return showDialog(
        context: context,
        builder:(context){
          return AlertDialog(
            title: Text("Message"),
            content: Text("Please make sure that you are exact in your company location right now as the app will capture your current location and set it as your company location."),
            actions: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.remove_circle,color: Colors.red,)),
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                    updateCompanyLocation();
                  }, icon: Icon(Icons.check_circle_rounded,color: Colors.green,))
            ],
          );
        });
  }
  updateCompanyLocation() async{
   await getCurrentLocation(context).then((value){
     setState(() {
       widget.companyModel.location=GeoPoint(value.latitude, value.longitude);
     });
     updateCompanyData(context, widget.companyModel);
   });

  }
}

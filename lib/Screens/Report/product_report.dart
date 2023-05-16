import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/product_db.dart';
import 'package:stock_management/Services/DB/report_db.dart';

import '../../Widgets/row_info_display.dart';

class ProductReport extends StatefulWidget {
  final String productId;
  final CompanyModel companyModel;
  const ProductReport({Key? key,required this.companyModel,required this.productId}) : super(key: key);

  @override
  State<ProductReport> createState() => _ProductReportState();
}

class _ProductReportState extends State<ProductReport> {
  Stream? report;
  String productName="";
  TextEditingController from=TextEditingController();
  TextEditingController to=TextEditingController();

  @override
  void initState() {
    super.initState();
    getReportData();
  }
  getReportData()async{
    await ReportDb(companyId: widget.companyModel.companyId, productId: "").getReport().then((value)async{
      setState(() {
        report=value;
      });
      await ProductDb(companyId: widget.companyModel.companyId, productId: widget.productId).getProductDetails().then((value){
        setState(() {
          productName=value["productName"];
        });
      }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
    }).onError((error, stackTrace) => Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString()))));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            }, icon: Icon(CupertinoIcons.back,color: Colors.white,)
        ),
        title: Text("$productName",style: const TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child:const Text("Date",style: TextStyle(fontWeight: FontWeight.w900),)
                  ),
                  Expanded(
                      flex: 1,
                      child: const Text("Quantity",style:  TextStyle(fontWeight: FontWeight.w900))
                  ),
                ],
              ),
            ),
            Expanded(
                child: StreamBuilder(
                    stream: report,
                    builder: (context,snapshot){
                      if(snapshot.connectionState==ConnectionState.waiting){
                        return const Center(child: CircularProgressIndicator(),);
                      }
                      if(snapshot.hasError){
                        return const Center(child: Text("Error"),);
                      }
                      if(!snapshot.hasData){
                        return const Center(child: Text("No Data Found"),);
                      }
                      else{
                        return ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index){
                              return display("${snapshot.data.docs[index]["date"]}", '${snapshot.data.docs[index]["${widget.productId}"]}');
                            });
                      }
                    })
            )
          ],
        ),
      ),
    );
  }
  Widget display(String label,String value){
    return Padding(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 1,
              child: Text(label,style: const TextStyle(fontWeight: FontWeight.w900),)
          ),
          Expanded(
              flex: 1,
              child: Text(value)
          ),
        ],
      ),
    );
  }
  Widget date(TextEditingController ctrl,String value) {
    return Expanded(
      child: TextField(
          decoration: InputDecoration(
            icon: const Icon(Icons.calendar_month),
            labelText: value,
          ),
          readOnly: true,
          controller: ctrl,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100));
            if (pickedDate != null) {
              String formattedDate =
              DateFormat("dd-MM-yyyy").format(pickedDate);
              setState(() {
                ctrl.text = formattedDate;
              });
            }
          }),
    );
  }
}

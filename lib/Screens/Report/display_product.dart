import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stock_management/Screens/Report/product_report.dart';
import 'package:stock_management/Widgets/row_info_display.dart';

import '../../Models/company_model.dart';
import '../../Services/DB/product_db.dart';

class DisplayProduct extends StatefulWidget {
  final CompanyModel companyModel;
  const DisplayProduct({Key? key,required this.companyModel}) : super(key: key);

  @override
  State<DisplayProduct> createState() => _DisplayProductState();
}

class _DisplayProductState extends State<DisplayProduct> {
  Stream? products;

  @override
  void initState() {
    super.initState();
    getProducts();
  }
  getProducts()async{
    await ProductDb(companyId: widget.companyModel.companyId, productId: "").getProducts().then((value){
      setState(() {
        products=value;
      });
    });
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
        title: const Text("Products",style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body:  StreamBuilder(
          stream: products,
          builder: (context,AsyncSnapshot snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator(),);
            }
            if(snapshot.hasError){
              return const Center(child: Text("error"),);
            }
            if(!snapshot.hasData){
              return const Center(child: Text("No Data Found"),);
            }else{
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context,index){
                    if(snapshot.data.docs[index]["isDeleted"]==true){
                      return const SizedBox(height: 0,);
                    }else{
                      return ListTile(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductReport(companyModel: widget.companyModel, productId: snapshot.data.docs[index]["productId"])));
                        },
                        leading:  snapshot.data.docs[index]["imageUrl"].toString().isEmpty
                            ?Icon(Icons.image)
                            :CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data.docs[index]["imageUrl"]),
                        ),
                        title: Text(snapshot.data.docs[index]["productName"]),
                        subtitle: Text("${snapshot.data.docs[index]["description"]}"),
                      );
                    }
                  });
            }}),
    );
  }
}

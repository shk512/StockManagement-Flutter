import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Screens/Report/product_report.dart';

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
  TextEditingController searchController=TextEditingController();

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
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search here",
                ),
                onChanged: (val){
                  setState(() {
                    searchController.text=val;
                  });
                },
              )
          ),
          Expanded(
            child: StreamBuilder(
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
                        if(searchController.text.isEmpty){
                          return listTile(snapshot.data.docs[index]);
                        }else{
                          if("${snapshot.data
                              .docs[index]["productName"]}-${snapshot.data
                              .docs[index]["description"]}".toString().trim().toLowerCase().contains(searchController.text.trim().toLowerCase())){
                            return listTile(snapshot.data.docs[index]);
                          }else{
                            return const SizedBox();
                          }
                        }
                      });
                }}),
          )
        ],
      )
    );
  }
  Widget listTile(DocumentSnapshot snapshot){
    return ListTile(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductReport(companyModel: widget.companyModel, productId: snapshot["productId"],key: Key("productReport"),)));
      },
      leading:  snapshot["imageUrl"].toString().isEmpty
          ?Icon(Icons.image)
          :CircleAvatar(
        backgroundImage: NetworkImage(snapshot["imageUrl"]),
      ),
      title: Text(snapshot["productName"]),
      subtitle: Text("${snapshot["description"]}"),
    );
  }
}

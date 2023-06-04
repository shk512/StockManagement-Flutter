import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/DB/product_db.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Constants/rights.dart';
import '../../Models/user_model.dart';

class Stock extends StatefulWidget {
  final CompanyModel companyModel;
  final UserModel userModel;
  const Stock({Key? key,required this.userModel,required this.companyModel}) : super(key: key);

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  Stream? products;
  TextEditingController searchController=TextEditingController();

  @override
  void initState() {
    super.initState();
    getProducts();
  }
  getProducts()async{
    ProductDb(companyId: widget.companyModel.companyId, productId: "").getProducts().then((value){
      setState(() {
        products=value;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search here...",
                ),
                onChanged: (val){
                  setState(() {
                    searchController.text=val;
                  });
                },
              )
          ),
          Expanded(
            child:  StreamBuilder(
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
                        return ListTile(
                          leading:  snapshot.data.docs[index]["imageUrl"].toString().isEmpty
                              ?Icon(Icons.image)
                              :CircleAvatar(
                            backgroundImage: NetworkImage(snapshot.data.docs[index]["imageUrl"]),
                          ),
                          title: Text("${snapshot.data
                              .docs[index]["productName"]}-${snapshot.data
                              .docs[index]["description"]}"),
                          subtitle: Text(snapshot.data.docs[index]["totalQuantity"].toString()),
                          trailing:  widget.userModel.rights.contains(Rights.updateStock)||widget.userModel.rights.contains(Rights.all)
                              ? InkWell(
                              onTap: () {
                                showStockInputDialogue(
                                    snapshot.data.docs[index]["productId"], snapshot.data.docs[index]["totalQuantity"],
                                    snapshot.data.docs[index]["productName"]);
                              },
                              child: const Icon(Icons.cached_outlined, color: Colors.brown,))
                              : const SizedBox(height: 0,),
                        );
                      }else{
                        if("${snapshot.data
                            .docs[index]["productName"]}-${snapshot.data
                            .docs[index]["description"]}".toString().trim().toLowerCase().contains(searchController.text.trim().toLowerCase())){
                          return ListTile(
                            leading:  snapshot.data.docs[index]["imageUrl"].toString().isEmpty
                                ?Icon(Icons.image)
                                :CircleAvatar(
                              backgroundImage: NetworkImage(snapshot.data.docs[index]["imageUrl"]),
                            ),
                            title: Text("${snapshot.data
                                .docs[index]["productName"]}-${snapshot.data
                                .docs[index]["description"]}"),
                            subtitle: Text(snapshot.data.docs[index]["totalQuantity"].toString()),
                            trailing:  widget.userModel.rights.contains(Rights.updateStock)||widget.userModel.rights.contains(Rights.all)
                                ? InkWell(
                                onTap: () {
                                  showStockInputDialogue(
                                      snapshot.data.docs[index]["productId"], snapshot.data.docs[index]["totalQuantity"],
                                      snapshot.data.docs[index]["productName"]);
                                },
                                child: const Icon(Icons.cached_outlined, color: Colors.brown,))
                                : const SizedBox(height: 0,),
                          );
                        }else{
                          return const SizedBox();
                        }
                      }

                    });
              }
            },
          ),)
        ],
      ),
    );
  }
  showStockInputDialogue(String productId,num quantity,String productName){
    TextEditingController newQuantity=TextEditingController();
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
             title: Text(productName),
            content: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              controller: newQuantity,
              decoration: const InputDecoration(
                labelText: "Stock",
                hintText: "Enter new stock"
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: (){Navigator.pop(context);},
                  child: const Text("Cancel",style: TextStyle(color: Colors.white),)),
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                    if(newQuantity.text.isNotEmpty){
                      updateStock(-int.parse(newQuantity.text),productId);
                    }
                  },
                  child: const Text("Minus",style: TextStyle(color: Colors.white),)),
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                    if(newQuantity.text.isNotEmpty){
                      updateStock(int.parse(newQuantity.text),productId);
                    }
                  },
                  child: const Text("Plus",style: TextStyle(color: Colors.white),))
            ],
          );
        });
  }
  updateStock(num quantity,String productId)async{
    await ProductDb(companyId:  widget.companyModel.companyId, productId: productId).increment(quantity).then((value){
      if(value==true){
        showSnackbar(context,Colors.green.shade300, "Updated");
        setState(() {

        });
      }else{
        showSnackbar(context, Colors.red.shade400, "Error");
      }
    }).onError((error, stackTrace) {
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString(),key: Key("errorScreen"),)));
    });
  }
}

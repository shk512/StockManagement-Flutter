import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Screens/User/asign_shop.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Widgets/text_field.dart';

import '../../Constants/rights.dart';
import '../../Widgets/num_field.dart';
import '../Splash_Error/error.dart';

class EditUser extends StatefulWidget {
  final String userId;
  const EditUser({Key? key,required this.userId}) : super(key: key);

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  TextEditingController name=TextEditingController();
  TextEditingController contact=TextEditingController();
  TextEditingController designation=TextEditingController();
  TextEditingController salary=TextEditingController();
  String role="";
  final formKey=GlobalKey<FormState>();
  List rights=[];
  /*
  * RIGHTS BOOLEAN
  * */
  bool all=false;
  bool changeShopStatus=false;
  bool addShop=false;
  bool editShop=false;
  bool deleteShop=false;
  bool viewShop=false;
  bool addArea=false;
  bool deleteArea=false;
  bool viewCompany=false;
  bool editCompany=false;
  bool viewCompanyWallet=false;
  bool viewOrder=false;
  bool editOrder=false;
  bool placeOrder=false;
  bool deliverOrder=false;
  bool dispatchOrder=false;
  bool deleteOrder=false;
  bool addUser=false;
  bool viewUser=false;
  bool editUser=false;
  bool deleteUser=false;
  bool viewTransaction=false;
  bool addTransaction=false;
  bool rollBackTransaction=false;
  bool addProduct=false;
  bool viewProduct=false;
  bool editProduct=false;
  bool deleteProduct=false;
  bool updateStock=false;
  bool viewStock=false;
  bool navigateShop=false;
  bool navigateOrder=false;
  bool viewReport=false;

  @override
  void initState() {
    super.initState();
    getUserData();
  }
  getUserData()async{
    await UserDb(id: widget.userId).getData().then((snapshot) {
      setState(() {
        name.text=snapshot["name"];
        contact.text=snapshot["phone"];
        designation.text=snapshot["designation"];
        salary.text=snapshot["salary"].toString();
        role=snapshot["role"];
        rights=List.from(snapshot["right"]);
        /*
        * RIGHTS BOOLEAN
        * */
        if(rights.contains(Rights.all)){
          all=true;
        }
        if(rights.contains(Rights.changeShopStatus)){
          changeShopStatus=true;
        }
        if(rights.contains(Rights.addShop)){
          addShop=true;
        }
        if(rights.contains(Rights.editShop)){
          editShop=true;
        }
        if(rights.contains(Rights.deleteShop)){
          deleteShop=true;
        }
        if(rights.contains(Rights.viewShop)){
          viewShop=true;
        }
        if(rights.contains(Rights.addArea)){
         addArea=true;
        }
        if(rights.contains(Rights.deleteArea)){
          deleteArea=true;
        }
        if(rights.contains(Rights.viewCompany)){
          viewCompany=true;
        }
        if(rights.contains(Rights.editCompany)){
          editCompany=true;
        }
        if(rights.contains(Rights.viewCompanyWallet)){
          viewCompanyWallet=true;
        }
        if(rights.contains(Rights.viewOrder)){
          viewOrder=true;
        }
        if(rights.contains(Rights.editOrder)){
          editOrder=true;
        }
        if(rights.contains(Rights.placeOrder)){
          placeOrder=true;
        }
        if(rights.contains(Rights.deliverOrder)){
          deliverOrder=true;
        }
        if(rights.contains(Rights.dispatchOrder)){
          dispatchOrder=true;
        }
        if(rights.contains(Rights.deleteOrder)){
          deleteOrder=true;
        }
        if(rights.contains(Rights.addUser)){
          addUser=true;
        }
        if(rights.contains(Rights.viewUser)){
          viewUser=true;
        }
        if(rights.contains(Rights.editUser)){
          editUser=true;
        }
        if(rights.contains(Rights.deleteUser)){
          deleteUser=true;
        }
        if(rights.contains(Rights.viewTransactions)){
          viewTransaction=true;
        }
        if(rights.contains(Rights.addTransaction)){
          addTransaction=true;
        }
        if(rights.contains(Rights.rollBackTransaction)){
          rollBackTransaction=true;
        }if(rights.contains(Rights.addProduct)){
          addProduct=true;
        }
        if(rights.contains(Rights.viewProduct)){
          viewProduct=true;
        }
        if(rights.contains(Rights.editProduct)){
          editProduct=true;
        }
        if(rights.contains(Rights.deleteProduct)){
          deleteProduct=true;
        }
        if(rights.contains(Rights.updateStock)){
          updateStock=true;
        }
        if(rights.contains(Rights.viewStock)){
          viewStock=true;
        }
        if(rights.contains(Rights.shopNavigation)){
          navigateShop=true;
        }
        if(rights.contains(Rights.orderNavigation)){
          navigateOrder=true;
        }
        if(rights.contains(Rights.viewReport)){
          viewReport=true;
        }
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
        title: const Text("Edit",style: TextStyle(color: Colors.white),),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: (){
            updateDate();
          }, label: Text("Update",style: TextStyle(color: Colors.white),)),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
          child: Form(
              key: formKey,
              child: Column(
                children: [
                  TxtField(labelTxt: "Name", hintTxt: "Enter your name", ctrl: name, icon: const Icon(Icons.person_outline)),
                  NumField(labelTxt: "Contact", hintTxt: "03001234567", ctrl: contact, icon: const Icon(Icons.phone)),
                  role!="Company".toUpperCase()?NumField(labelTxt: "Salary", hintTxt: "In digits", ctrl: salary, icon:const Icon(Icons.onetwothree)):const SizedBox(),
                  role=="Shop Keeper".toUpperCase()
                      ?Column(
                    children: [
                      Text(designation.text),
                      SizedBox(height: 10,),
                      ElevatedButton(
                          onPressed: (){
                            Navigator.push(context,MaterialPageRoute(builder: (context)=>AssignShop(userId: widget.userId)));
                          },
                          child: Text("Change Shop"))
                    ],
                  )
                      :TxtField(labelTxt: "Designation", hintTxt: "Employee's designation", ctrl: designation, icon: const Icon(CupertinoIcons.star_circle)),
                  role=="Company".toUpperCase()
                      ?const SizedBox()
                      :const Align(
                    alignment: AlignmentDirectional.bottomStart,
                    child: Text(
                      "Rights:", style: TextStyle(color:Colors.cyan,fontWeight: FontWeight.bold,fontSize: 20),),
                  ),
                  role=="Company".toUpperCase()
                      ?const SizedBox()
                      :checkBoxLists(),
                ],
              )),
        ),
      )
    );
  }
  updateDate()async{
    await UserDb(id: widget.userId).updateUser({
      "name":name.text,
      "phone":contact.text,
      "designation":designation.text,
      "salary":salary.text
    }).then((value){

    }).onError((error, stackTrace){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
    });
  }
  Widget checkBoxLists(){
    return Column(
      children: [
        /*
        COMPANY RIGHTS CHECK BOX
        * */
        CheckboxListTile(
          value: viewCompany,
          onChanged: (val){
            setState(() {
              viewCompany=val as bool;
            });
            if(viewCompany){
              rights.add(Rights.viewCompany);
            }else{
              rights.remove(Rights.viewCompany);
            }
          },
          title: const Text("View Company Profile",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        viewCompany
            ? CheckboxListTile(
          value: editCompany,
          onChanged: (val){
            setState(() {
              editCompany=val as bool;
            });
            if(editCompany){
              rights.add(Rights.editCompany);
            }else{
              rights.remove(Rights.editCompany);
            }
          },
          title: const Text("Edit Company Profile",),
        )
            :const SizedBox(),
        viewCompany
            ?CheckboxListTile(
          value:  viewCompanyWallet,
          onChanged: (val){
            setState(() {
              viewCompanyWallet=val as bool;
            });
            if( viewCompanyWallet){
              rights.add(Rights.viewCompanyWallet);
            }else{
              rights.remove(Rights.viewCompanyWallet);
            }
          },
          title: const Text("Company Wallet Access",),
        )
            :const SizedBox(),
        /*
                    AREA RIGHTS CHECK BOX
        * */
        viewCompany
            ?CheckboxListTile(
          value:  addArea,
          onChanged: (val){
            setState(() {
              addArea=val as bool;
            });
            if( addArea){
              rights.add(Rights.addArea);
            }else{
              rights.remove(Rights.addArea);
            }
          },
          title: const Text("Add Area",style: TextStyle(fontWeight: FontWeight.bold),),
        )
            :const SizedBox(),
        viewCompany
            ?CheckboxListTile(
          value:  deleteArea,
          onChanged: (val){
            setState(() {
              deleteArea=val as bool;
            });
            if( deleteArea){
              rights.add(Rights.deleteArea);
            }else{
              rights.remove(Rights.deleteArea);
            }
          },
          title: const Text("Delete Area",style: TextStyle(fontWeight: FontWeight.bold),),
        )
            :const SizedBox(),

        /*
        SHOPS RIGHTS CHECK BOX
        * */
        CheckboxListTile(
          value:  viewShop,
          onChanged: (val){
            setState(() {
              viewShop=val as bool;
            });
            if( viewShop){
              rights.add(Rights.viewShop);
            }else{
              rights.remove(Rights.viewShop);
            }
          },
          title: const Text("View All Shops",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        viewShop
            ?CheckboxListTile(
          value:  addShop,
          onChanged: (val){
            setState(() {
              addShop=val as bool;
            });
            if( addShop){
              rights.add(Rights.addShop);
            }else{
              rights.remove(Rights.addShop);
            }
          },
          title: const Text("Add Shop",),
        )
            :const SizedBox(),
        viewShop
            ?CheckboxListTile(
          value:  editShop,
          onChanged: (val){
            setState(() {
              editShop=val as bool;
            });
            if( editShop){
              rights.add(Rights.editShop);
            }else{
              rights.remove(Rights.editShop);
            }
          },
          title: const Text("Edit Shop"),
        )
            :const SizedBox(),
        viewShop
            ?CheckboxListTile(
          value:  deleteShop,
          onChanged: (val){
            setState(() {
              deleteShop=val as bool;
            });
            if( deleteShop){
              rights.add(Rights.deleteShop);
            }else{
              rights.remove(Rights.deleteShop);
            }
          },
          title: const Text("Delete Shop"),
        )
            :const SizedBox(),
        viewShop
            ?CheckboxListTile(
          value:  changeShopStatus,
          onChanged: (val){
            setState(() {
              changeShopStatus=val as bool;
            });
            if( changeShopStatus){
              rights.add(Rights.changeShopStatus);
            }else{
              rights.remove(Rights.changeShopStatus);
            }
          },
          title: const Text("Change Shop Status"),
        )
            :const SizedBox(),

        /*
        * ORDER RIGHTS CHECK BOX
        * */
        CheckboxListTile(
          value:  viewOrder,
          onChanged: (val){
            setState(() {
              viewOrder=val as bool;
            });
            if( viewOrder){
              rights.add(Rights.viewOrder);
            }else{
              rights.remove(Rights.viewOrder);
            }
          },
          title: const Text("View Order",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        viewOrder
            ? CheckboxListTile(
          value:  editOrder,
          onChanged: (val){
            setState(() {
              editOrder=val as bool;
            });
            if( editOrder){
              rights.add(Rights.editOrder);
            }else{
              rights.remove(Rights.editOrder);
            }
          },
          title: const Text("Edit Order"),
        )
            :const SizedBox(),
        viewOrder
            ? CheckboxListTile(
          value:  dispatchOrder,
          onChanged: (val){
            setState(() {
              dispatchOrder=val as bool;
            });
            if( dispatchOrder){
              rights.add(Rights.dispatchOrder);
            }else{
              rights.remove(Rights.dispatchOrder);
            }
          },
          title: const Text("Dispatch Order"),
        )
            :const SizedBox(),
        viewOrder
            ? CheckboxListTile(
          value:  deleteOrder,
          onChanged: (val){
            setState(() {
              deleteOrder=val as bool;
            });
            if( deleteOrder){
              rights.add(Rights.deleteOrder);
            }else{
              rights.remove(Rights.deleteOrder);
            }
          },
          title: const Text("Delete Order"),
        )
            :const SizedBox(),
        CheckboxListTile(
          value:  placeOrder,
          onChanged: (val){
            setState(() {
              placeOrder=val as bool;
            });
            if( placeOrder){
              rights.add(Rights.placeOrder);
            }else{
              rights.remove(Rights.placeOrder);
            }
          },
          title: const Text("Place Order",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        CheckboxListTile(
          value:  deliverOrder,
          onChanged: (val){
            setState(() {
              deliverOrder=val as bool;
            });
            if( deliverOrder){
              rights.add(Rights.deliverOrder);
            }else{
              rights.remove(Rights.deliverOrder);
            }
          },
          title: const Text("Deliver Order",style: TextStyle(fontWeight: FontWeight.bold),),
        ),

        /*
        * USER RIGHTS CHECK BOX
        * */
        CheckboxListTile(
          value:  viewUser,
          onChanged: (val){
            setState(() {
              viewUser=val as bool;
            });
            if( viewUser){
              rights.add(Rights.viewUser);
            }else{
              rights.remove(Rights.viewUser);
            }
          },
          title: const Text("View Users",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        viewUser
            ?CheckboxListTile(
          value:  addUser,
          onChanged: (val){
            setState(() {
              addUser=val as bool;
            });
            if( addUser){
              rights.add(Rights.addUser);
            }else{
              rights.remove(Rights.addUser);
            }
          },
          title: const Text("Add Users"),
        )
            :const SizedBox(),
        viewUser
            ?CheckboxListTile(
          value:  editUser,
          onChanged: (val){
            setState(() {
              editUser=val as bool;
            });
            if( editUser){
              rights.add(Rights.editUser);
            }else{
              rights.remove(Rights.editUser);
            }
          },
          title: const Text("Edit Users"),
        )
            :const SizedBox(),
        viewUser
            ?CheckboxListTile(
          value:  deleteUser,
          onChanged: (val){
            setState(() {
              deleteUser=val as bool;
            });
            if( deleteUser){
              rights.add(Rights.deleteUser);
            }else{
              rights.remove(Rights.deleteUser);
            }
          },
          title: const Text("Delete Users"),
        )
            :const SizedBox(),

        /*
        * PRODUCT RIGHTS CHECK BOX
        * */
        CheckboxListTile(
          value:  viewProduct,
          onChanged: (val){
            setState(() {
              viewProduct=val as bool;
            });
            if( viewProduct){
              rights.add(Rights.viewProduct);
            }else{
              rights.remove(Rights.viewProduct);
            }
          },
          title: const Text("View Product",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        viewProduct
            ?CheckboxListTile(
          value:  addProduct,
          onChanged: (val){
            setState(() {
              addProduct=val as bool;
            });
            if( addProduct){
              rights.add(Rights.addProduct);
            }else{
              rights.remove(Rights.addProduct);
            }
          },
          title: const Text("Add Product"),
        )
            :const SizedBox(),
        viewProduct
            ?CheckboxListTile(
          value:  editProduct,
          onChanged: (val){
            setState(() {
              editProduct=val as bool;
            });
            if( editProduct){
              rights.add(Rights.editProduct);
            }else{
              rights.remove(Rights.editProduct);
            }
          },
          title: const Text("Edit Product"),
        )
            :const SizedBox(),
        viewProduct
            ?CheckboxListTile(
          value:  deleteProduct,
          onChanged: (val){
            setState(() {
              deleteProduct=val as bool;
            });
            if( deleteProduct){
              rights.add(Rights.deleteProduct);
            }else{
              rights.remove(Rights.deleteProduct);
            }
          },
          title: const Text("Delete Product"),
        )
            :const SizedBox(),
        /*
         * STOCK RIGHTS CHECK BOX
        * */
        CheckboxListTile(
          value:  viewStock,
          onChanged: (val){
            setState(() {
              viewStock=val as bool;
            });
            if( viewStock){
              rights.add(Rights.viewStock);
            }else{
              rights.remove(Rights.viewStock);
            }
          },
          title: const Text("View Stock",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        viewStock
            ?CheckboxListTile(
          value:  updateStock,
          onChanged: (val){
            setState(() {
              updateStock=val as bool;
            });
            if( updateStock){
              rights.add(Rights.updateStock);
            }else{
              rights.remove(Rights.updateStock);
            }
          },
          title: const Text("Update Stock"),
        )
            :const SizedBox(),
        /*
         * TRANSACTION RIGHTS CHECK BOX
         * */
        CheckboxListTile(
          value:  viewTransaction,
          onChanged: (val){
            setState(() {
              viewTransaction=val as bool;
            });
            if( viewTransaction){
              rights.add(Rights.viewTransactions);
            }else{
              rights.remove(Rights.viewTransactions);
            }
          },
          title: const Text("View Transactions",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        viewTransaction
            ?CheckboxListTile(
          value:  addTransaction,
          onChanged: (val){
            setState(() {
              addTransaction=val as bool;
            });
            if( viewTransaction){
              rights.add(Rights.addTransaction);
            }else{
              rights.remove(Rights.addTransaction);
            }
          },
          title: const Text("Add Transactions"),
        )
            :const SizedBox(),
        viewTransaction
            ?CheckboxListTile(
            value:  rollBackTransaction,
            onChanged: (val){
              setState(() {
                rollBackTransaction=val as bool;
              });
              if( rollBackTransaction){
                rights.add(Rights.rollBackTransaction);
              }else{
                rights.remove(Rights.rollBackTransaction);
              }
            },
            title: const Text("Roll Back Transactions",
            )
        )
            :const SizedBox(),
        CheckboxListTile(
          value: navigateShop,
          onChanged: (val){
            setState(() {
              navigateShop=val as bool;
            });
            if( navigateShop){
              rights.add(Rights.shopNavigation);
            }else{
              rights.remove(Rights.shopNavigation);
            }
          },
          title: const Text("Navigate Shop",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        CheckboxListTile(
          value: navigateOrder,
          onChanged: (val){
            setState(() {
              navigateOrder=val as bool;
            });
            if( navigateOrder){
              rights.add(Rights.orderNavigation);
            }else{
              rights.remove(Rights.orderNavigation);
            }
          },
          title: const Text("Navigate Order",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
        /*
        * REPORT RIGHTS CHECK BOX
        * */
        CheckboxListTile(
          value: viewReport,
          onChanged: (val){
            setState(() {
              viewReport=val as bool;
            });
            if( viewReport){
              rights.add(Rights.viewReport);
            }else{
              rights.remove(Rights.viewReport);
            }
          },
          title: const Text("View Report",style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ],
    );
  }
}

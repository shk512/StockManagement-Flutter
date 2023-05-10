import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Constants/rights.dart';
import 'package:stock_management/Models/company_model.dart';
import 'package:stock_management/Models/user_model.dart';
import 'package:stock_management/Screens/Splash_Error/error.dart';
import 'package:stock_management/Services/Auth/auth.dart';
import 'package:stock_management/Services/DB/company_db.dart';
import 'package:stock_management/Services/DB/shop_db.dart';
import 'package:stock_management/Services/DB/user_db.dart';
import 'package:stock_management/Services/shared_preferences/spf.dart';
import 'package:stock_management/Widgets/text_field.dart';
import 'package:stock_management/utils/enum.dart';
import 'package:stock_management/utils/snack_bar.dart';

import '../../Widgets/num_field.dart';
import '../../Constants/routes.dart';

class Signup extends StatefulWidget {
  final String companyId;
  const Signup({Key? key,required this.companyId}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final formKey = GlobalKey<FormState>();
  TextEditingController mail = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController cPass = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController salary = TextEditingController();
  TextEditingController designation=TextEditingController();
  String role = "";
  List rights=[];
  UserRole _role = UserRole.company;
  Auth auth=Auth();
  bool isLoading=false;
  List shopsList=[];
  Stream? shopStream;
  CompanyModel _companyModel=CompanyModel();
  UserModel _userModel=UserModel();
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
    getCompanyDetails();
  }

  getCompanyDetails() async {
    DocumentSnapshot snapshot=await CompanyDb(id: widget.companyId).getData();
    setState(() {
      _companyModel.fromJson(snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ?const Center(child: CircularProgressIndicator(),)
          :FutureBuilder(
          future: getCompanyDetails(),
          builder: (context,index){
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: const Icon(CupertinoIcons.back,),
                        ),
                      ),
                      const SizedBox(height: 10,),
                      const Image(image: AssetImage("image/signup.png")),
                      Center(child: Text(_companyModel.companyName,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 25),)),
                      const SizedBox(height: 20,),
                      TxtField(labelTxt: "Email",
                          hintTxt: "john@gmail.com",
                          ctrl: mail,
                          icon: const Icon(Icons.mail)),
                      const SizedBox(height: 20,),
                      TxtField(labelTxt: "Name",
                          hintTxt: "Your Name",
                          ctrl: name,
                          icon: const Icon(Icons.perm_identity)),
                      const SizedBox(height: 20,),
                      NumField(labelTxt: "Contact",
                          hintTxt: "03001234567",
                          ctrl: contact,
                          icon: const Icon(Icons.phone)),
                      const SizedBox(height: 20,),
                      TxtField(labelTxt: "Password",
                          hintTxt: "Enter your password",
                          ctrl: pass,
                          icon: const Icon(Icons.password)),
                      const SizedBox(height: 20,),
                      TxtField(labelTxt: "Confirm Password",
                          hintTxt: "Retype your password",
                          ctrl: cPass,
                          icon: const Icon(Icons.password)),
                      const SizedBox(height: 20,),
                      const Align(
                        alignment: AlignmentDirectional.bottomStart,
                        child: Text(
                          "Role:", style: TextStyle(color:Colors.cyan,fontWeight: FontWeight.bold,fontSize: 20),),
                      ),
                      radioButtons("Company", UserRole.company),
                      radioButtons("Employee", UserRole.employee),
                      radioButtons("Shop Keeper", UserRole.shopKeeper),
                      _role==UserRole.shopKeeper || _role==UserRole.company
                          ? Container()
                          : NumField(labelTxt: "Salary", hintTxt: "In digits", ctrl: salary, icon: const Icon(Icons.onetwothree)),
                      const SizedBox(height: 20,),
                      _role==UserRole.employee
                          ? TxtField(labelTxt: "Designation", hintTxt: "Employee's Designation", ctrl: designation, icon: const Icon(CupertinoIcons.star_circle))
                          :const SizedBox(),
                      const SizedBox(height: 20,),
                      _role==UserRole.company
                          ?const SizedBox()
                          :const Align(
                        alignment: AlignmentDirectional.bottomStart,
                        child: Text(
                          "Rights:", style: TextStyle(color:Colors.cyan,fontWeight: FontWeight.bold,fontSize: 20),),
                      ),
                      _role==UserRole.company
                          ?const SizedBox()
                          :checkBoxLists(),
                      const SizedBox(height: 20,),
                      ElevatedButton(onPressed: (){
                        if(_role==UserRole.employee){
                          role="Employee".toUpperCase();
                        }else if(_role==UserRole.shopKeeper){
                          role="Shop Keeper".toUpperCase();
                          salary.text="0";
                        }else if(_role==UserRole.company){
                          role="Company".toUpperCase();
                          salary.text="0";
                          rights.add("all".toLowerCase());
                        }
                        if(pass.text==cPass.text){
                          signup();
                        }else{
                          showSnackbar(context, Colors.red, "Oops! Password doesn't match");
                        }
                      }, child: const Text("Register",style: TextStyle(color: Colors.white),)),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
  Widget radioButtons(String name, UserRole role) {
    return ListTile(
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Radio(
            value: role,
            groupValue: _role,
            onChanged: (UserRole? value) {
              setState(() {
                _role = value!;
              });
            })
    );
  }
  signup()async{
    if(formKey.currentState!.validate()){
      setState(() {
        isLoading=true;
      });
      await auth.createUser(mail.text, pass.text).then((value)async{
          await UserDb(id: FirebaseAuth.instance.currentUser!.uid).saveUser(_userModel.toJson(
              userId: FirebaseAuth.instance.currentUser!.uid,
              name: name.text,
              salary: int.parse(salary.text),
              mail: mail.text,
              companyId: widget.companyId,
              phone: contact.text,
              role: role,
              designation: designation.text,
              wallet: 0,
              isDeleted: false,
              rights: rights,
              area: [])).then((value){
                SPF.saveUserLogInStatus(true);
                setState(() {
                  isLoading=false;
                });
                Navigator.pushNamed(context, Routes.dashboard);
          }).onError((error, stackTrace){
            setState(() {
              isLoading=false;
            });
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
          });
      }).onError((error, stackTrace){
        setState(() {
          isLoading=false;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ErrorScreen(error: error.toString())));
      });
    }
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
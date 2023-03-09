import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/utils/snackBar.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
            color: Colors.cyan,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome",style: TextStyle(letterSpacing: 2,fontWeight: FontWeight.bold,),),
                  SizedBox(height: 10),
                  Text("Name"),
                  SizedBox(height: 5),
                  Text("Contact"),
                ],
              ),
            ),
          ),
          drawerList(Icon(CupertinoIcons.square_list), "Orders"),
          drawerList(Icon(CupertinoIcons.person_2_fill), "Employee"),
          drawerList(Icon(Icons.production_quantity_limits), "Product"),
          drawerList(Icon(Icons.account_balance), "Accounts"),
          drawerList(Icon(CupertinoIcons.person_crop_circle), "Profile"),
          drawerList(Icon(Icons.logout), "Logout"),
        ],
      ),
    );
  }
  Widget drawerList(Icon icon,String text){
    return   InkWell(
      onTap: () {
       
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            icon,
            SizedBox(
              width: 20,
            ),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stock_management/Widgets/myDrawer.dart';
import 'package:stock_management/utils/snackBar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: Text("Company Name",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          Icon(Icons.account_balance_wallet_outlined),
          Padding(
              padding:EdgeInsets.symmetric(horizontal: 10,vertical: 20),
            child: const Text("Rs.1000",style: TextStyle(fontSize: 17,color: Colors.white),textAlign: TextAlign.center,))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Text("Recent Activity:",textAlign: TextAlign.start,),
            InkWell(
              onTap: (){
                showSnackbar(context, Colors.cyan, "Clicked");
              },
              child: ListTile(
                title: Text("Shop Name"),
                subtitle: Text("Area"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text("Status"),
                  Text("Date",style: TextStyle(color: Colors.grey),)
                ],),
              ),
            ),
            InkWell(
              onTap: (){
                showSnackbar(context, Colors.cyan, "Clicked");
              },
              child: ListTile(
                title: Text("Shop Name"),
                subtitle: Text("Area"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text("Status"),
                  Text("Date",style: TextStyle(color: Colors.grey),)
                ],),
              ),
            ),
            InkWell(
              onTap: (){
                showSnackbar(context, Colors.cyan, "Clicked");
              },
              child: ListTile(
                title: Text("Shop Name"),
                subtitle: Text("Area"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text("Status"),
                  Text("Date",style: TextStyle(color: Colors.grey),)
                ],),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

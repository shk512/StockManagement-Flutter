import 'package:flutter/material.dart';

class DashboardMenu extends StatefulWidget {
  final String route;
  final Color clr;
  final String name;
  final IconData icon;
  const DashboardMenu({Key? key,required this.name,required this.route,required this.icon,required this.clr}) : super(key: key);

  @override
  State<DashboardMenu> createState() => _DashboardMenuState();
}

class _DashboardMenuState extends State<DashboardMenu> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.pushNamed(context,widget.route);
      },
      child: Container(
        decoration: BoxDecoration(
            color: widget.clr,
            borderRadius: BorderRadius.circular(30)
        ),
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(widget.icon,size: 40,color: Colors.white,),
            Text(widget.name,style:const TextStyle(fontWeight: FontWeight.w900,fontSize: 20,color: Colors.white) ,),
          ],
        ),
      ),
    );
  }
}

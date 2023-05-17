import 'dart:io';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' ;
import 'package:stock_management/Functions/pdf_api.dart';

class BuildPdf{
  static Future<File> generate({
    required String companyName,
    required String invoiceNo,
    required List products,
    required String totalAmount,
    required String balanceAmount,
    required String advanceAmount,
    required String concessionAmount,
    required String shopName,
    required String contactPerson
})async{
    final pdf=Document();
    /*var data= await rootBundle.load("assets/open-sans/OpenSans-Bold.ttf");
    var myFont = Font.ttf(data);
    var myStyle = TextStyle(font: myFont);*/
    pdf.addPage(
        MultiPage(build: (context)=>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${companyName}",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
              Text("Invoice#${invoiceNo}"),
              SizedBox(height: 0.1 * PdfPageFormat.cm),
              buildHeaderRow("Shop Details ",shopName),
              buildHeaderRow("Contact Person ",contactPerson),
              SizedBox(height: 0.7 * PdfPageFormat.cm),
              Row(
                  children:[
                    Expanded(
                      flex: 4,
                        child: Text("Product Name",style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Quantity",style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Price",style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text("Total Price",style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ]
              ),
              ListView.builder(
                itemCount: products.length,
                itemBuilder: (context,index){
                  return buildProductDetailsRow(
                      "${products[index]["productName"]}-${products[index]["description"]}", products[index]["totalQuantity"].toString(), products[index]["minPrice"].toString(), products[index]["totalPrice"].toString());
                }
              ),
              SizedBox(height: 0.3 * PdfPageFormat.cm),
              Padding(
                  padding: EdgeInsets.all(0.1*PdfPageFormat.cm),
                child: Align(
                    alignment: Alignment.bottomRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Total Amount:\t$totalAmount",style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Advance Amount:\t$advanceAmount",style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Concession Amount:\t$concessionAmount",style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Balance Amount:\t$balanceAmount",style: TextStyle(fontWeight: FontWeight.bold)),
                        ]
                    )
                )
              )
            ]
          ),
        ],
            footer: (context){
          final text="Page ${context.pageNumber} of ${context.pagesCount}";
          return Container(
            alignment: Alignment.centerRight,
            child: Text(text,style: TextStyle(fontWeight: FontWeight.bold))
          );
        }
        )
    );
    return PdfApi.saveDocument(fileName: DateTime.now().toString(), document: pdf);
  }
  static Widget buildHeaderRow(String label, String value)=>Padding(
      padding: EdgeInsets.all(0.1*PdfPageFormat.cm),
    child: Row(
        children: [
          Expanded(
              flex: 1,
              child: Text(label,style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 4,
              child: Text(value)),
        ]
    ),
  );
  static Widget buildProductDetailsRow(String pName, String quan, String price, String total)=>Padding(
      padding: EdgeInsets.all(0.1*PdfPageFormat.cm),
    child: Row(
        children:[
          Expanded(
            flex: 4,
            child: Text(pName),
          ),
          Expanded(
            flex: 2,
            child: Text(quan),
          ),
          Expanded(
            flex: 2,
            child: Text(price),
          ),
          Expanded(
            flex: 2,
            child: Text(total),
          ),
        ]
    ),
  );
}

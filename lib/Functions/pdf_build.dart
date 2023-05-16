import 'dart:io';

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
    pdf.addPage(
        MultiPage(build: (context)=>[
          Column(
              crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${companyName}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25)),
              Text("${invoiceNo}",style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 0.5 * PdfPageFormat.cm),
              buildHeaderRow("Shop Details ",shopName),
              buildHeaderRow("Contact Person ",contactPerson),
              SizedBox(height: 1 * PdfPageFormat.cm),
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
              SizedBox(height: 0.5 * PdfPageFormat.cm),
              Padding(
                  padding: EdgeInsets.all(0.5*PdfPageFormat.cm),
                child: Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                        children: [
                          Text("Total Amount: $totalAmount"),
                          Text("Advance Amount: $advanceAmount"),
                          Text("Concession Amount: $concessionAmount"),
                          Text("Balance Amount: $balanceAmount"),
                        ]
                    )
                )
              )
            ]
          ),
        ],
            footer: (context){
          final text="Page ${context.pageNumber} of ${context.pagesCount}";
          return Text(text,style: TextStyle(fontWeight: FontWeight.bold));
        }
        )
    );
    return PdfApi.saveDocument(fileName: DateTime.now().toString(), document: pdf);
  }
  static Widget buildHeaderRow(String label, String value)=>Padding(
      padding: EdgeInsets.all(0.5*PdfPageFormat.cm),
    child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(label,style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 4,
              child: Text(value)),
        ]
    ),
  );
  static Widget buildProductDetailsRow(String pName, String quan, String price, String total)=>Padding(
      padding: EdgeInsets.all(0.5*PdfPageFormat.cm),
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

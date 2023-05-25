import 'dart:io';
import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfApi{
  static Future<File> saveDocument({required String fileName, required Document document })async{
    final directory;

    if(defaultTargetPlatform==TargetPlatform.android){
      directory = await getExternalStorageDirectory();
    }else{
      directory=await getApplicationDocumentsDirectory();
    }
    final file=File("${directory.path}/${fileName}");

    final bytes=await document.save();
    await file.writeAsBytes(bytes.toList());

    DocumentFileSavePlus().saveMultipleFiles(
      dataList: [bytes,],
      fileNameList: ["$fileName",],
      mimeTypeList: ["$fileName/pdf",],
    );
    return file;
  }
  static Future openFile(File file)async{
    final url=file.path;
    await OpenFile.open(url);
  }
}
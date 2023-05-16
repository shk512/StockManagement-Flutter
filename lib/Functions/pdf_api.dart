import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfApi{
  static Future<File> saveDocument({required String fileName, required Document document })async{
    final bytes=await document.save();
    final directory=await getApplicationDocumentsDirectory();
    final file=File("${directory.path}/${fileName}");
    await file.writeAsBytes(bytes);
    return file;
  }
  static Future openFile(File file)async{
    final url=file.path;
    await OpenFile.open(url);
  }
}
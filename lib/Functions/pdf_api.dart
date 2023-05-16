import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

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
  static Future<bool> saveFile(String url, String fileName) async {
    try {
      if (await Permission.storage.request().isGranted) {
        Directory? directory;
        directory = await getExternalStorageDirectory();
        String newPath = "";
        List<String> paths = directory!.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + "/PDF_Download";
        directory = Directory(newPath);

        File saveFile = File(directory.path + "/$fileName");
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        if (await directory.exists()) {
          await Dio().download(
            url,
            saveFile.path,
          );
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
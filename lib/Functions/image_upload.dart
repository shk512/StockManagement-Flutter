import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

uploadImage() async {
  final _firebaseStorage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();
  var image;
  String imageUrl="";
  //Check Permissions
  await Permission.storage.request();

  var permissionStatus = await Permission.storage.status;

  if (permissionStatus.isGranted){
    //Select Image
    image = await _imagePicker.pickImage(source: ImageSource.gallery);
    var file = File(image.path);

    if (image != null){
      //Upload to Firebase
      String imageId=DateTime.now().microsecondsSinceEpoch.toString();
      var snapshot;
      await _firebaseStorage.ref()
          .child('images/$imageId')
          .putFile(file).then((p0){
         snapshot=p0;
      });
      imageUrl= await snapshot.ref.getDownloadURL();
    }
    return imageUrl;
  } else {
    throw "Permission Denied";
  }
}
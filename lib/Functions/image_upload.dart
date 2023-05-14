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
      var snapshot=
      await _firebaseStorage.ref()
          .child('image/$imageId')
          .putFile(file).whenComplete(() {});
      imageUrl= await snapshot.ref.getDownloadURL();
    }
    return imageUrl;
  } else {
    throw "Permission Denied";
  }
}

/*
uploadImageFile() async {
  File? image;
  final picker = ImagePicker();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
}
  final pickedFile =
  await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  if (pickedFile != null) {
    setState(() {
      image = File(pickedFile.path);
    });
  }*/

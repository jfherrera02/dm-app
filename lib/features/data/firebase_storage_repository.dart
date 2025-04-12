import 'dart:io';
import 'dart:typed_data';

import 'package:dmessages/features/domain/storage_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseStorageRepository implements StorageRepository {
  final FirebaseStorage storage = FirebaseStorage.instance;
  

  // Mobile - file upload
  // this method will be used to upload the profile image from mobile devices
  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return uploadFile(path, fileName, "user_profile_images");
  }

  // web - byte upload
  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return uploadBytes(fileBytes, fileName, "user_profile_images");
  }
  // for cleaner code - implement following methods to 
  // help upload files to storage ->

  // mobile - file upload 
  Future<String?> uploadFile(String path, String fileName, String folder) async {
    try {
      // create file using the path
      final file = File(path);

      // Determine content type from fileName instead of path.
      final contentType = getContentType(fileName);

      // now find the place to store the file
      final storageReference = storage.ref().child('$folder/$fileName');

      // set metadata for the file
      // this is optional but it helps to set the content type of the file
      // so that it can be served correctly by the server
      final metadata = SettableMetadata(contentType: contentType);

      // Upload the file along with metadata.
      final uploadTask = await storageReference.putFile(file, metadata);
      
      // finally upload the file
      // final uploadTask = await storageReference.putFile(file);

      // get image download url that we can return
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
      // then catch any errors
    } catch (e) {
      // print the error message to the console
      debugPrint("Upload failed: $e");
      return null;
    }
  }

  // web - byte upload
  Future<String?> uploadBytes(Uint8List fileBytes, String fileName, String folder) async {
    try {
      // now find the place to store the data
      final storageReference = storage.ref().child('$folder/$fileName');

      // Determine content type from the fileName.
      final contentType = getContentType(fileName);
      // set metadata for the file
      // this is optional but it helps to set the content type of the file
      // so that it can be served correctly by the server
      final metadata = SettableMetadata(contentType: contentType);

      // Upload the byte data along with metadata.
      final uploadTask = await storageReference.putData(fileBytes, metadata);

      // finally upload the data
      // final uploadTask = await storageReference.putData(fileBytes);

      // get image download url that we can return
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
      // then catch any errors
    } catch (e) {
      debugPrint("Upload failed: $e");
      return null;
    }
  }

  // now we can implement the other methods for uploading post images
  // mobile - file upload
  @override
  Future<String?> uploadPostImageMobile(String path, String fileName) {
    return uploadFile(path, fileName, "post_images");
  }
  // web - byte upload
  @override
  Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName) {
    return uploadBytes(fileBytes, fileName, "post_images");
  }
}
// this method is used to get the content type of the file
// this is used to set the content type of the file when uploading to firebase storage  
String getContentType(String pathOrFileName) {
  final lowerCaseName = pathOrFileName.toLowerCase();
  if (lowerCaseName.endsWith('.png')) {
    return 'image/png';
  } else if (lowerCaseName.endsWith('.jpg') || lowerCaseName.endsWith('.jpeg')) {
    return 'image/jpeg';
  }
  // Optionally add other cases or a default:
  return 'application/octet-stream';
}

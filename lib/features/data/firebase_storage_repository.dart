import 'dart:io';
import 'dart:typed_data';

import 'package:dmessages/features/domain/storage_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageRepository implements StorageRepository {
  final FirebaseStorage storage = FirebaseStorage.instance;
  

  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return uploadFile(path, fileName, "user_profile_images");
  }

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

      // now find the place to store the file
      final storageReference = storage.ref().child('$folder/$fileName');
      
      // finally upload the file
      final uploadTask = await storageReference.putFile(file);

      // get image download url that we can return
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
      // then catch any errors
    } catch (e) {
      return null;
    }
  }

  // web - byte upload
  Future<String?> uploadBytes(Uint8List fileBytes, String fileName, String folder) async {
    try {
      // now find the place to store the data
      final storageReference = storage.ref().child('$folder/$fileName');
      
      // finally upload the data
      final uploadTask = await storageReference.putData(fileBytes);

      // get image download url that we can return
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
      // then catch any errors
    } catch (e) {
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
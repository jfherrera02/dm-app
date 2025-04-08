// upload profile images on mobile 
import 'dart:typed_data';

abstract class StorageRepository {
  Future<String?> uploadProfileImageMobile(String path, String fileName);


// and on web 
Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName);

// upload post images on mobile 
Future<String?> uploadPostImageMobile(String path, String fileName);

// and on web 
Future<String?> uploadPostImageWeb(Uint8List fileBytes, String fileName);

}
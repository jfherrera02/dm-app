import 'dart:typed_data';

import 'package:dmessages/features/domain/storage_repository.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_states.dart';
import 'package:dmessages/pages/profile/profile_user.dart';
import 'package:dmessages/pages/profile/repos/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepository profileRepository;
  final StorageRepository storageRepository;

  ProfileCubit({
    required this.profileRepository,
    required this.storageRepository,
    }) : super(ProfileInitial());

  // fetch the user profile via the profile repository
  // useful for loading the profile page of the user
  Future <void> fetchUserProfile(String uid) async {  
    try {
      emit(ProfileLoading());
      // go to profile repo to fetch user profile
      final user = await profileRepository.fetchUserProfile(uid);
    
    // if successful 
    if (user != null) {
      emit(ProfileLoaded(user));
    } else {
      emit(ProfileError("User not fouond"));
    }

    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // return the current user profile with given user id
  Future<ProfileUser?> getCurrentUserProfile(String uid) async {
    try {
      emit(ProfileLoading());
      // go to profile repo to fetch user profile
      final user = await profileRepository.fetchUserProfile(uid);
    
    // if successful 
    if (user != null) {
      emit(ProfileLoaded(user));
      return user;
    } else {
      emit(ProfileError("User not found"));
    }

    } catch (e) {
      emit(ProfileError(e.toString()));
    }
    return null;
  }


  // update bio and/or the user profile
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    Uint8List? webImageBytes,
    String? mobileImagePath, 
  }) async {
    emit(ProfileLoading());

    // then 
    try {
      // get the current user
      final currentUser = await profileRepository.fetchUserProfile(uid);

      // if it does not exist
      if(currentUser == null) {
        emit(ProfileError("Failed fetching user when updating profile."));
      }

      // update the profile picture
      String? imageDownloadUrl;

      // make sure that an image exists before proceeding 
      if (webImageBytes != null || mobileImagePath != null ) {
        // mobile case
        if (mobileImagePath != null ) {
          imageDownloadUrl = 
            await storageRepository.uploadProfileImageMobile(mobileImagePath, uid);
        }
        // web case 
        else if (webImageBytes != null) {
          imageDownloadUrl = 
            await storageRepository.uploadProfileImageWeb(webImageBytes, uid);
        }
        
      // error case
      if(imageDownloadUrl == null) {
        emit(ProfileError("Imaged failed to upload."));
        return;
      }
    }

      // then update the new profile
      final updatedProfile = 
        currentUser!.copywith(
          newBio: newBio ?? currentUser.bio,
          // upload the new profile image if successful 
          newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
          );

      // finally update it in the profile repository 
      await profileRepository.updateProfile(updatedProfile);
    } catch (e) {
      emit(ProfileError("Error when updating the profile: $e"));
    }
  }
}
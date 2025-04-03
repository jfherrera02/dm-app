import 'package:dmessages/pages/profile/presentation/cubit/profile_states.dart';
import 'package:dmessages/pages/profile/repos/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepository profileRepository;

  ProfileCubit({required this.profileRepository}) : super(ProfileInitial());

  // fetch the user profile via the profile repository
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

  // update bio and/or the user profile
  Future<void> updateProfile({
    required String uid,
    String? newBio,
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

      // then update the new profile
      final updatedProfile = 
        currentUser!.copywith(newBio: newBio ?? currentUser.bio);

      // finally update it in the profile repository 
      await profileRepository.updateProfile(updatedProfile);
    } catch (e) {
      emit(ProfileError("Error when updating the profile: $e"));
    }
  }
}
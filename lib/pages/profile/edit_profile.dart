import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // says whether current platform is web or not
import 'package:dmessages/components/my_textfield.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_cubit.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_states.dart';
import 'package:dmessages/pages/profile/profile_user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfile extends StatefulWidget {
  final ProfileUser user;
  const EditProfile({
    super.key,
    required this.user,
    });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  // UI to select an image (using file_picker)
  // mobile image
  PlatformFile? mobileImage;

  // web image
  Uint8List? webImage; 
  // pick the proper image to uplaod 
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        mobileImage = result.files.first;

        if (kIsWeb) {
          webImage = mobileImage!.bytes;
        }  
      });
    }
  }

  final textContrller = TextEditingController();

  // update user profile when save button is pressed ->
  void updateProfile() async {
    // get the profile cubit
    final profileCubit = context.read<ProfileCubit>();
    // prepare to upload images
    final String uid = widget.user.uid;
    // are we looking at web or mobile?
    final mobileImagePath = kIsWeb ? null : mobileImage?.path;
    final webImageBytes = kIsWeb ? mobileImage?.bytes : null; 
    final String? newBio = textContrller.text.isNotEmpty ? textContrller.text : null;

    // update the profile if there is something to update (bio or image)
    if(mobileImage != null || newBio != null) {
      profileCubit.updateProfile(
      uid: uid,
      newBio: newBio,
      mobileImagePath: mobileImagePath,
      webImageBytes: webImageBytes,
      );
    }

    // if there is nothing to update -> pop the page (go to previous page)
    else {
      Navigator.pop(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    // scaffold
    return BlocConsumer<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        // states when in bio editing
        // profile loading....
        if (state is ProfileLoading) {
          return Scaffold(
            body: Column(
              children: [
                CircularProgressIndicator(),
                Text("Saving changes..."),
              ],
            ),
          );
        } else {
          return buildEditPage(); // return same page 
        }
        // error state

        // edit form
      }, 
      listener: (context, state) {
        if (state is ProfileLoaded) {
          // go to previous page after saving changes
          Navigator.pop(context);
        }
      },
    );
}

Widget buildEditPage() {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Edit Profile"),
      foregroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        // save/upload
        IconButton(
          onPressed: updateProfile, 
          icon: const Icon(Icons.save)),
      ],
    ),
    body: Column(
      children: [
        // profile picture edit here
        Center(
          child: Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            // image will stay in the bounds of the profile circle outline
            clipBehavior: Clip.hardEdge,
            // child container 
            child: 
            // 3 display options:
            // selected mobile image
            (!kIsWeb && mobileImage != null) ? 
            Image.file(File(mobileImage!.path!),
            fit: BoxFit.cover,
            )
            :
            // web image
            (kIsWeb && webImage != null)
            ?
            // return image
            Image.memory(webImage!)
            : 
            // no image selected -> current image is displayed
            // use the cached_network_image dependency from fluttter pub
            // great for loading image or chaching image (save to local storage)
            // eliminates need to fetch every time
            CachedNetworkImage(
              imageUrl: widget.user.profileImageUrl,
              // when loading.... ->
              placeholder: (context, url) => 
                const CircularProgressIndicator(),
              // in case of an error ->
              errorWidget: (context, url, error) => 
                Icon(Icons.person,
                size: 68,
                color: Theme.of(context).colorScheme.primary,
                ),
              // when loaded:
              imageBuilder: (context, imageProvider) => Image(
                image: imageProvider,
                // now ensure the image fills up the profile image area
                fit: BoxFit.cover,
                ),
            ),
          ),
        ),

        const SizedBox(height: 25),
        // bio edit here
        const Text("Edit Your Bio"),

        // finally implement the button to pick an image
        Center(
          child: MaterialButton(
            onPressed: pickImage,
            color: Colors.blue,
            child: const Text("Change Profile Image"),
            ),
        ),

        MyTextField(
        hintText: widget.user.bio, 
        obscureText: false, 
        controller: textContrller),
      ],
    ),
  );
}
}
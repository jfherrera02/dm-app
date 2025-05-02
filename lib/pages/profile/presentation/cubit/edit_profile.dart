import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dmessages/components/my_textfield.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_cubit.dart';
import 'package:dmessages/pages/profile/presentation/cubit/profile_states.dart';
import 'package:dmessages/pages/profile/data/profile_user.dart';
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
  PlatformFile? imageFilePicked;

  // web image
  Uint8List? webImage;

  final textController = TextEditingController();

  // pick the proper image to upload
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imageFilePicked = result.files.first;
        if (kIsWeb) {
          webImage = imageFilePicked!.bytes;
        }
      });
    }
  }

  // update user profile when save button is pressed ->
  void updateProfile() async {
    final profileCubit = context.read<ProfileCubit>();
    final String uid = widget.user.uid;

    final fileExtension = imageFilePicked?.extension ?? 'jpg';
    final fileNameWithExtension = '$uid.$fileExtension';
    final mobileImagePath = kIsWeb ? null : imageFilePicked?.path;
    final webImageBytes = kIsWeb ? imageFilePicked?.bytes : null;
    final String? newBio =
        textController.text.isNotEmpty ? textController.text : null;

    if (imageFilePicked != null || newBio != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        mobileImagePath: mobileImagePath,
        webImageBytes: webImageBytes,
        fileName: fileNameWithExtension,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return buildEditPage(); // return same page
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
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
          IconButton(onPressed: updateProfile, icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // profile picture edit here
            GestureDetector(
              onTap: pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondary,
                      image: DecorationImage(
                        // display selected or current image
                        image: imageFilePicked != null
                            ? (kIsWeb
                                ? MemoryImage(webImage!)
                                : FileImage(File(imageFilePicked!.path!)) as ImageProvider)
                            : NetworkImage(widget.user.profileImageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // edit icon overlay
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // bio edit here
            Align(
               alignment: Alignment.topCenter,
              child: Text(
                "Bio",
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            MyTextField(
              hintText: widget.user.bio,
              obscureText: false,
              controller: textController,
            ),
            const SizedBox(height: 24),
            // finally implement the button to pick an image
            SizedBox(
              // width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text("Change Photo"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

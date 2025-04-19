import 'dart:io';
import 'dart:typed_data';
import 'package:dmessages/components/my_textfield.dart';
import 'package:dmessages/post/domain/entities/post.dart';
import 'package:dmessages/post/presentation/cubits/post_cubit.dart';
import 'package:dmessages/post/presentation/cubits/post_states.dart';
import 'package:dmessages/responsive/constrained_scaffold.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dmessages/services/auth/domain/app_user.dart';
import 'package:dmessages/services/auth/presentation/cubits/auth_cubits.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}
  // this page will be used to upload a new post
  // mobile image pick
  class _UploadPostPageState extends State<UploadPostPage> {  
  PlatformFile? _imageFile;


  // we image picker for web platforms

  Uint8List? webImage;
  // this is the image bytes that will be used to upload the image to the backend

  // text controller for the post description
  final TextEditingController _descriptionController = TextEditingController();
  
  // current user
  // this is the current user that will be used to upload the image to the backend
  AppUser? _currentUser;
  @override
  void initState() {
    super.initState();
    // this is the current user that will be used to upload the image to the backend
    getCurrentUser();
  }
   // now get the current user
   void getCurrentUser() async {
      // this is the current user that will be used to upload the image to the backend
      final authCubit = context.read<AuthCubit>();  
      _currentUser = authCubit.newgetCurrentUser;
   }

   // select image
   Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        _imageFile = result.files.first;

        if (kIsWeb) {
          webImage = _imageFile!.bytes;
        }  
      });
    }
  }

  // create and upload the post
  void uploadPost() async {
    // check if the image and caption are not null
    if (_imageFile == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An image and caption is required...")),
      );
      return;
    }

  // now we can create a new post object 
  final newPost = Post(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: _currentUser!.uid,
    userName: _currentUser!.username,
    text: _descriptionController.text,
    imageUrl: '',
    timestamp: DateTime.now(),
    likes: [],
    comments: [],
  );
  
  // ensure we upload using the post cubit
  final postCubit = context.read<PostCubit>();

  // case for web upload
  if (kIsWeb) {
    // upload the image to the backend
    await postCubit.createPost(
      newPost,
      imageBytes: _imageFile?.bytes,
    );
  } else {
    // upload the image to the backend
    await postCubit.createPost(
      newPost,
      imagePath: _imageFile!.path,
    );
  }
}
  // now we can dispose of the controllers
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
  // create the UI for the upload post page
  @override
  Widget build(BuildContext context) {
    // create a bloc consumer to listen to the post cubit
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        // state for loading / uploading:
        if (state is PostLoading || state is PostUpload) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // else we return the upload post page
        return buildUploadPage();
      },
      // this is the listener for the post cubit
      // able to go back to the home page
      // when the post is uploaded successfully
      listener: (context, state) {
        if (state is PostLoaded) {
          // show a snackbar to inform the user that the post was uploaded successfully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Post uploaded successfully!")),
          );
          // go back to the home page
          Navigator.pop(context);
        } else if (state is PostError) {
          // show a snackbar to inform the user that the post was not uploaded successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
    ); 
  }

  Widget buildUploadPage() {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text("Create a Post"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: uploadPost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // image preview
            // web image preview
            if (kIsWeb && webImage != null)
              Image.memory(webImage!),
            // mobile image preview
            if (!kIsWeb && _imageFile != null)
              Image.file(
                File(_imageFile!.path!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            // text field for the post description
            MyTextField(
              controller: _descriptionController,
              hintText: "Write a caption...",
              obscureText: false,
              ),
            // button to select image
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Select Image"),
            ),
          ],
        ),
      ),
    );
  }
}

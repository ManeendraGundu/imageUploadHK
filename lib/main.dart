
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'package:image_picker/image_picker.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Upload Example',
      home: ImageUploadScreen(),
    );
  }
}

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? imageFile;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImageToFirebase() async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("images/${DateTime.now().toString()}");
      var metadata = SettableMetadata(
        contentType: "image/jpeg",
      );
      UploadTask uploadTask = ref.putFile(imageFile!, metadata);
      await uploadTask.whenComplete(() => null);
      String url = await ref.getDownloadURL();
      print("Image uploaded to Firebase: $url");
    } catch (e) {
      print("Error uploading image to Firebase: $e");
    }
  }

  // Future<void> _uploadImage() async{
  //   // var imageFile = File(image!.path);
  //   print("Image Name =====> ${imageFile!.path}");
  //   String fileName = basename(imageFile!.path);
  //   FirebaseStorage storage = FirebaseStorage.instance;
  //   Reference ref =
  //   storage.ref().child("Image-");
  // }

  // Future<void> _uploadImage() async {
  //   if (_imageFile == null) {
  //     print('No image selected.');
  //     return;
  //   }
  //
  //   var headers = {
  //     'Content-Type': 'image/jpeg',
  //   };
  //
  //   var request = http.MultipartRequest(
  //       'PUT',
  //       Uri.parse(
  //           'https://wbln3zcwk9.execute-api.us-east-1.amazonaws.com/testing/fileupload-cancepro-1/abc.jpg'));
  //
  //   request.files.add(http.MultipartFile(
  //       'file',
  //       _imageFile!.readAsBytes().asStream(),
  //       _imageFile!.lengthSync(),
  //       filename: 'abc.jpg'));
  //
  //   request.headers.addAll(headers);
  //
  //   http.StreamedResponse response = await request.send();
  //
  //   if (response.statusCode == 200) {
  //     print(await response.stream.bytesToString());
  //     print("Image sent successfully");
  //   } else {
  //     print(response.reasonPhrase);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload Example'),
      ),
      body: Center(
        child: imageFile == null
            ? Text('No image selected.')
            : Image.file(imageFile!),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getImage,
            tooltip: 'Pick Image',
            child: Icon(Icons.add_a_photo),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: uploadImageToFirebase,
            tooltip: 'Upload Image',
            child: Icon(Icons.cloud_upload),
          ),
        ],
      ),
    );
  }
}
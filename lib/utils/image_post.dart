import 'package:capture/utils/backend.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateImagePost extends StatefulWidget {
  @override
  _CreateImagePostState createState() => _CreateImagePostState();
}

class _CreateImagePostState extends State<CreateImagePost> {
  late File? _myImage = File(
      'https://c1.wallpaperflare.com/preview/989/1023/622/hand-holding-camera-old.jpg');
  late final picker = ImagePicker();
  Future getImage(ImageSource imagesource) async {
    final PickedFile? pickedImage = await picker.getImage(source: imagesource);

    setState(() {
      if (pickedImage != null) {
        _myImage = File(pickedImage.path);
      } else {
        print('No image selected.');
      }
    });
  }

  late String caption;
  late String location;

  late String _uploadedImageURL;
  bool _isLoading = false;
  CRUDmethods crudMethods = CRUDmethods();

  uploadUserPost() async {
    setState(() {
      _isLoading = true;
      print('Uploading....');
    });
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('postedImages/${DateTime.now()}.jpg');

    final UploadTask uploadTask = storageRef.putFile(_myImage!);
    await uploadTask.whenComplete(() async {
      print('File Uploaded');

      final String url = await storageRef.getDownloadURL();
      setState(() {
        _uploadedImageURL = url;
      });
      print('File URL = $_uploadedImageURL');

      Map<String, String> userPostDetails = {
        "imgURL": _uploadedImageURL,
        "caption": caption,
        "location": location,
      };
      crudMethods
          .addData(userPostDetails)
          .then((value) => Navigator.pop(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen[200],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Capture',
              style: TextStyle(
                fontSize: 22.0,
              ),
            ),
            Text(
              ' the Image',
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              margin: const EdgeInsets.all(22.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Upload Image"),
                              content:
                                  // ignore: deprecated_member_use
                                  Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // ignore: deprecated_member_use
                                  FlatButton(
                                    onPressed: () async {
                                      await getImage(ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Photo with Camera"),
                                  ),
                                  // ignore: deprecated_member_use
                                  FlatButton(
                                    onPressed: () async {
                                      await getImage(ImageSource.gallery);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Photo with Gallery"),
                                  ),
                                  // ignore: deprecated_member_use
                                  FlatButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: _myImage!.existsSync()
                          ? Container(
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _myImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              height: 180,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.add_a_photo, size: 80.0),
                            ),
                    ),
                    SizedBox(height: 25.0),
                    TextField(
                      decoration: InputDecoration(hintText: 'Write a caption'),
                      onChanged: (String value) {
                        caption = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                          hintText: 'Where was this photo taken ?'),
                      onChanged: (String value) {
                        location = value;
                      },
                    ),
                    SizedBox(height: 30.0),
                    Container(
                      height: 70,
                      child: ElevatedButton(
                        onPressed: () {
                          if (caption != "" &&
                              location != "" &&
                              _myImage!.existsSync()) {
                            return uploadUserPost();
                          }
                        },
                        child: Text('Upload', style: TextStyle(fontSize: 30)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

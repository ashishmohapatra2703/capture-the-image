import 'package:capture/utils/backend.dart';
import 'package:capture/utils/image_post.dart';
import 'package:capture/utils/image_post_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CRUDmethods crudMethods = CRUDmethods();
  CollectionReference userPostSnapshot =
      FirebaseFirestore.instance.collection('userBlogPosts');

  Widget? userPostsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: userPostSnapshot.snapshots(),
      builder: (context, stream) {
        if (stream.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (stream.hasError) {
          return Center(child: Text(stream.error.toString()));
        }

        QuerySnapshot? querySnapshot = stream.data;

        return Container(
          child: querySnapshot != null
              ? ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  itemCount: querySnapshot.size,
                  itemBuilder: (context, index) {
                    return PostTile(
                      imgURL: querySnapshot.docs[index].data()!['imgURL'],
                      caption: querySnapshot.docs[index].data()!['caption'],
                      location: querySnapshot.docs[index].data()!['location'],
                    );
                  })
              : Container(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent[100],
      appBar: AppBar(
        backgroundColor: Colors.orange,
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
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(vertical: 25.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateImagePost()));
              },
              icon: Icon(Icons.add_a_photo),
              label: Text("Upload your photo"),
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
      body: userPostsList(),
    );
  }
}

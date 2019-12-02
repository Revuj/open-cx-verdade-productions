import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conferly/main.dart';
import 'package:conferly/widgets/InfoWrapper.dart';
import 'package:flutter/material.dart';

import 'editProfile.dart';

class Profile extends StatefulWidget {

  String user;

  Profile({this.user});

  @override
  ProfileState createState() {
    return new ProfileState(user);
  }
}


class ProfileState extends State<Profile> {

  String _fullName = "Name";
  String _status = "Status";
  String _bio = "Bio";
  String _local = "Location";
  String _work = "Work";
  List<String> _interests = [];
  bool _loading = true;
  String imageFile;
  FirebaseStorage _storage =
  FirebaseStorage(storageBucket: 'gs://conferly-8779b.appspot.com/');

  String getImagePath() {
    StorageReference photo = _storage.ref().child('images/${MyApp.firebaseUser.uid}.png');
    photo.getDownloadURL().then((data){
      setState(() {
          imageFile = data;
      });
    });
    if (imageFile != null) {
      print(imageFile);
      return imageFile;
    }
    return 'assets/images/profile.png';
  }


  getUserInfo(user) async {
    if (user == "" || user == null)
      user = MyApp.firebaseUser.uid;
    Firestore.instance
        .collection("Users")
        .document(user)
        .get().then((document) {
      if (document.exists) {
        setState(() {
          if (document.data['name'] != "" && document.data['name'] != null)
            _fullName = document.data['name'];
          if (document.data['description'] != "" &&
              document.data['description'] != null)
            _bio = document.data['description'];
          if (document.data['location'] != "" &&
              document.data['location'] != null)
            _local = document.data['location'];
          if (document.data['status'] != "" && document.data['status'] != null)
            _status = document.data['status'];
          if (document.data['work'] != "" && document.data['work'] != null)
            _work = document.data['work'];
          _interests.clear();
          if (document.data['interests'] != null)
          _interests = document.data['interests'].cast<String>();
          _loading = false;
        });
      }
    });
  }

  ProfileState(user) {
    getUserInfo(user);
  }

  Widget _coverImage(Size screen) {
    return Container(
      height: screen.height / 3,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/feup.jpeg'),
          fit: BoxFit.cover,

        ),
      ),
    );
  }

  Widget _profileImage() {
    return Center(
        child: Container(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageCapture()),
              );
            },
          ),
          width: 140.0, height: 140.0,
          decoration: BoxDecoration(
              image: DecorationImage(
                image: new NetworkImage(getImagePath()),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                color: Colors.grey,
                width: 5.0,
              )
          ),
        )
    );
  }

  Widget _buildFullName() {
    TextStyle _nameStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
    );
    return Text(
      _fullName,
      style: _nameStyle,
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 50.0),
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
            _status,
            style: TextStyle(
              fontFamily: 'Spectral',
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w300,

            )
        )

    );
  }


  Widget _buildBio() {
    TextStyle _style = TextStyle(
      fontFamily: 'Spectral',
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
      color: Color(0xFF788495),
    );
    return Text(
      _bio,
      style: _style,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSperator(Size screen) {
    return Container(
      width: screen.width / 1.6,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 15.0, bottom: 8.0),
    );
  }

  Widget _buildInterests() {
    List <Widget> chipChildren = new List<Widget>();
    for (int i = 0; i < _interests.length; i++) {
      chipChildren.add(
          Chip(
            label: Text(_interests[i]),
            avatar: Icon(Icons.adb),
            labelPadding: EdgeInsets.all(5),
            padding: EdgeInsets.all(5),
          )
      );
    }

    return Wrap(
        spacing: 8.0,
        runSpacing: 2.0,
        alignment: WrapAlignment.center,
        children: chipChildren
    );
  }


  @override
  Widget build(BuildContext context) {
    Size sizeScreen = MediaQuery
        .of(context)
        .size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.edit, color: Colors.white,), onPressed: _loading ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfile()),
                );
            })
          ],
        ),
        body: _loading ?
        Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme
                        .of(context)
                        .accentColor)))
            : SingleChildScrollView(
          child: Stack(
          children: <Widget>[
            _coverImage(sizeScreen),
            Container(
              margin:EdgeInsets.all(16),
              child: Column(
                  children: <Widget>[
                    SizedBox(height: sizeScreen.height / 6.4,),
                    _profileImage(),
                    _buildFullName(),
                    _buildStatus(context),
                    _buildBio(),
                    _buildSperator(sizeScreen),
                    InfoWrapper(
                        text: _local,
                        icon: Icon(Icons.place),
                        bg: Theme
                            .of(context)
                            .scaffoldBackgroundColor),
                    InfoWrapper(
                        text: _work,
                        icon: Icon(Icons.work), bg: Theme
                        .of(context)
                        .scaffoldBackgroundColor),
                    Container(margin: EdgeInsets.all(4),),
                    _buildInterests()
                  ],
                ),
              )
          ]

            )


        )
    );
//    );
  }

}


class ImageCapture extends StatefulWidget {
  createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {

  File _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
    });
  }

  Future<void> _cropImage() async{
    File cropped = await ImageCropper.cropImage(
        sourcePath: _imageFile.path,
        toolbarColor: Colors.greenAccent.shade100,
        toolbarWidgetColor: Colors.white,
        toolbarTitle: 'Crop Image'
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }

  void _clear() {
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.photo_camera),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            IconButton(
              icon: Icon(Icons.photo_library),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
      body: ListView(
        children: <Widget>[
          if (_imageFile != null) ...[
            Image.file(_imageFile),

            Row(
              children: <Widget>[
                FlatButton(
                  child: Icon(Icons.crop),
                  onPressed: _cropImage,
                )
              ],
            ),

            Uploader(file: _imageFile)
          ]
        ],
      ),
    );
  }
}

class Uploader extends StatefulWidget {
  final File file;

  Uploader({Key key, this.file}) : super(key: key);

  createState() => _UploaderState();
}

class _UploaderState extends State<Uploader>{
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://conferly-8779b.appspot.com/');

  StorageUploadTask _uploadTask;

  void _startUpload() {
    String filePath = 'images/${MyApp.firebaseUser.uid}.png';

    setState(() {
      _uploadTask = _storage.ref().child(filePath).putFile(widget.file);

    });
  }


  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
        stream: _uploadTask.events,
        builder: (context, snapshot) {
          var event = snapshot?.data?.snapshot;

          double progressPercent = event != null
          ? event.bytesTransferred / event.totalByteCount
              : 0;

          return Column(
            children: <Widget>[
              if (_uploadTask.isComplete)
                Text('Done'),

              LinearProgressIndicator(value: progressPercent),
              Text(
                '${(progressPercent * 100)} %'
              ),
            ],
          );
        },
      );
    } else {
      return FlatButton.icon (
        label: Text('Upload Image'),
        icon: Icon(Icons.cloud_upload),
        onPressed: _startUpload,
      );
    }
  }}


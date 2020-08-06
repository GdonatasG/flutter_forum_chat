import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterforum/bloc/image_uploader_bloc.dart';
import 'package:flutterforum/image_uploader.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../model/user.dart';
import '../../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  final FirebaseUser user;

  const ProfilePage({Key key, @required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserService _userService;
  String appBarTitle = "";
  ImagePicker _imagePicker = ImagePicker();
  File _newPicture;
  ImageUploaderBloc _imageUploaderBloc;
  User _user;
  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _userService = Provider.of<UserService>(context, listen: false);
    _imageUploaderBloc = ImageUploaderBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
              stream: _userService
                  .getFirestoreUserById(widget.user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.exists) {
                    _user = User.fromMap(snapshot.data.data);
                    _user.id = snapshot.data.documentID;
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      setState(() {
                        appBarTitle = _user.username + "'s profile";
                      });
                    });
                    return _buildUserData();
                  } else
                    return Center(
                      child: Text("Something went wrong!"),
                    );
                } else
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              })),
    );
  }

  _buildUserData() => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    new Container(
                        width: 190.0,
                        height: 190.0,
                        decoration: new BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                            image: _imageUploaderBloc.newPicture != null
                                ? new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new FileImage(
                                        _imageUploaderBloc.newPicture))
                                : _user.photoUrl.isNotEmpty
                                    ? new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new NetworkImage(_user.photoUrl))
                                    : null)),
                    SizedBox(
                      height: 10,
                    ),
                    Text(_user.username),
                    SizedBox(
                      height: 20,
                    ),
                    FlatButton(
                      color: Colors.blue.shade800,
                      onPressed: () => _changePicture(ImageSource.camera),
                      child: Text(
                        "CAMERA",
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    FlatButton(
                      color: Colors.blue.shade800,
                      onPressed: () => _changePicture(ImageSource.gallery),
                      child: Text(
                        "STORAGE",
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ImageUploader(
                        user: widget.user,
                        firestoreUserDocId: _user.id,
                        imageUploaderBloc: _imageUploaderBloc,
                        scaffoldKey: _scaffoldKey)
                  ],
                ),
              ),
            ),
          ),
        );
      });

  _changePicture(source) async {
    var pickedFile = await _imagePicker.getImage(source: source);
    File cropped = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        cropStyle: CropStyle.circle,
        androidUiSettings: AndroidUiSettings(
            statusBarColor: Colors.blue.shade800,
            toolbarColor: Colors.blue,
            toolbarTitle: "Crop Image"));
    setState(() {
      _imageUploaderBloc.newPicture = cropped ?? pickedFile.path;
    });
  }
}

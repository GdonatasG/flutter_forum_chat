import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterforum/bloc/image_uploader_bloc.dart';
import 'package:flutterforum/services/auth_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:provider/provider.dart';

class ImageUploader extends StatefulWidget {
  final FirebaseUser user;
  final String firestoreUserDocId;
  final ImageUploaderBloc imageUploaderBloc;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ImageUploader(
      {Key key,
      @required this.user,
      @required this.firestoreUserDocId,
      @required this.imageUploaderBloc,
      @required this.scaffoldKey})
      : super(key: key);

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final FirebaseStorage _firebaseStorage =
      FirebaseStorage(storageBucket: 'gs://flutter-forum-499db.appspot.com');
  UserService _userService;
  AuthService _authService;
  bool isUpdating = false;

  StorageUploadTask _uploadTask;

  @override
  void initState() {
    _userService = Provider.of<UserService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    super.initState();
  }

  void _startUpload() {
    isUpdating = false;
    String filePath = 'images/${DateTime.now()}.png';

    setState(() {
      _uploadTask = _firebaseStorage
          .ref()
          .child(filePath)
          .putFile(widget.imageUploaderBloc.newPicture);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
          stream: _uploadTask.events,
          builder: (context, snapshot) {
            var event = snapshot?.data?.snapshot;
            if (_uploadTask.isComplete) {
              print("task completed");
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  widget.imageUploaderBloc.newPicture = null;
                  _uploadTask = null;
                });
              });
              if (!isUpdating)
                _updateUserProfile(snapshot.data.snapshot.ref.getDownloadURL());
            }

            double progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;

            return Column(
              children: [
                LinearProgressIndicator(
                  value: progressPercent,
                ),
                Text("${(progressPercent * 100)} %")
              ],
            );
          });
    } else {
      return widget.imageUploaderBloc.newPicture != null
          ? FlatButton(
              color: Colors.blue.shade800,
              onPressed: _startUpload,
              child: Text(
                "UPLOAD PICTURE",
                style: Theme.of(context).textTheme.headline4,
              ),
            )
          : Container();
    }
  }

  _updateUserProfile(getUrl) async {
    isUpdating = true;
    print("updating profile");
    try {
      var photoUrl = await getUrl;
      var userInfo = UserUpdateInfo();
      userInfo.photoUrl = photoUrl;
      await _authService.updateProfile(widget.user, userInfo);
      await _userService.updateUserProfilePicture(
          userInfo.photoUrl, widget.firestoreUserDocId);
      widget.scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text("Picture changed!")));
    } catch (_) {
      widget.scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text("Can't change picture!")));
    }
  }
}

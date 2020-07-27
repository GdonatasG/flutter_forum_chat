import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterforum/bloc/add_post_page/add_post_page_bloc_export.dart';
import 'package:flutterforum/model/category.dart';
import 'package:flutterforum/model/post.dart';
import 'package:flutterforum/pages/auth/login_page.dart';
import 'package:flutterforum/pages/authenticated/post_detail_page.dart';
import 'package:flutterforum/services/auth_service.dart';
import 'package:flutterforum/services/post_service.dart';
import 'package:flutterforum/utils/constants.dart';
import 'package:flutterforum/utils/extensions.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatefulWidget {
  final Category category;
  final String currentUserId;

  const AddPostPage(
      {Key key, @required this.category, @required this.currentUserId})
      : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  FirebaseUser _user;
  PostService _postService;
  AuthService _authService;
  AddPostPageBloc _addPostPageBloc;
  bool isFormActionsEnabled = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final _titleFocus = FocusNode();

  final TextEditingController _contentController = TextEditingController();
  final _contentFocus = FocusNode();

  @override
  void initState() {
    this._postService = Provider.of<PostService>(context, listen: false);
    this._authService = Provider.of<AuthService>(context, listen: false);
    _addPostPageBloc = AddPostPageBloc(_postService, _authService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Posting in ${widget.category.name}"),
        actions: [
          Center(
            child: Container(
              width: 20,
              height: 20,
              child: StreamBuilder(
                  stream: _addPostPageBloc.progressIndicatorStream,
                  builder: (_, snapshot) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      setState(() {
                        isFormActionsEnabled =
                            snapshot.hasData ? !snapshot.data : true;
                      });
                    });
                    return Visibility(
                      visible: snapshot.hasData ? snapshot.data : false,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        backgroundColor: Colors.blue.shade800,
                      ),
                    );
                  }),
            ),
          ),
          IconButton(
            onPressed: () => _doValidations(),
            icon: Icon(Icons.done),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
            child: BlocListener<AddPostPageBloc, AddPostPageState>(
          bloc: _addPostPageBloc,
          listener: (_, state) {
            if (state is AddPostPageFirebaseUserLoaded) {
              _user = state.user;
              if (_user == null)
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  changePageWithReplacement(
                      context,
                      LoginPage(
                        snackBar: SnackBar(
                          content: Text("You have been logged out"),
                        ),
                      ));
                });
              else
                _addPost();
            }
            if (state is AddPostPagePostAdded) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.of(context).pushReplacement(new MaterialPageRoute(
                    builder: (context) => PostDetailPage(
                          currentUserId: widget.currentUserId,
                          category: widget.category,
                          postId: state.postId,
                        )));
              });
            }
            if (state is AddPostPageFirebaseUserLoadingError) {
              showSnackbar(_scaffoldKey, state.error);
            } else if (state is AddPostPagePostingError) {
              showSnackbar(_scaffoldKey, state.error);
            } else if (state is AddPostPageNoInternet) {
              showSnackbar(_scaffoldKey, state.error);
            }
          },
          child: BlocBuilder<AddPostPageBloc, AddPostPageState>(
              bloc: _addPostPageBloc,
              builder: (_, state) {
                return _buildPostForm();
              }),
        )),
      ),
    );
  }

  _buildPostForm() => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _titleController,
                  enabled: isFormActionsEnabled,
                  focusNode: _titleFocus,
                  validator: (input) => ((input.trim().length >
                              Constants.POST_TITLE_MIN_SYMBOLS) &&
                          input.trim().length <
                              Constants.POST_TITLE_MAX_SYMBOLS)
                      ? null
                      : "Enter title longer than ${Constants.POST_TITLE_MIN_SYMBOLS} symbols and shorter than ${Constants.POST_TITLE_MAX_SYMBOLS}",
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (t) =>
                      _fieldFocusChange(context, _titleFocus, _contentFocus),
                  style: Theme.of(context).textTheme.headline4,
                  decoration: InputDecoration(
                      suffixIcon: _titleController.value.text.length > 0
                          ? IconButton(
                              onPressed: () => _titleController.clear(),
                              icon: Icon(Icons.clear),
                            )
                          : Container(
                              width: 0,
                              height: 0,
                            ),
                      hintStyle: Theme.of(context).textTheme.headline4,
                      contentPadding: EdgeInsets.all(15),
                      hintText: "Enter post title"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _contentController,
                  enabled: isFormActionsEnabled,
                  focusNode: _contentFocus,
                  validator: (input) => input.trim().length >
                          Constants.POST_CONTENT_MIN_SYMBOLS
                      ? null
                      : "Enter longer content (more than ${Constants.POST_CONTENT_MIN_SYMBOLS} symbols)",
                  textInputAction: TextInputAction.done,
                  maxLines: 10,
                  style: Theme.of(context).textTheme.headline4,
                  decoration: InputDecoration(
                      suffixIcon: _contentController.value.text.length > 0
                          ? IconButton(
                              onPressed: () => _contentController.clear(),
                              icon: Icon(Icons.clear),
                            )
                          : Container(
                              width: 0,
                              height: 0,
                            ),
                      hintStyle: Theme.of(context).textTheme.headline4,
                      contentPadding: EdgeInsets.all(15),
                      hintText: "Enter post content"),
                )
              ],
            ),
          ),
        ),
      );

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  _doValidations() {
    if (_formKey.currentState.validate())
      _addPostPageBloc.add(ReloadCurrentUser());
  }

  _addPost() {
    Post post = Post(
        widget.category.id,
        _titleController.value.text,
        _contentController.value.text,
        _user.uid,
        [],
        Timestamp.now(),
        Timestamp.now());
    _addPostPageBloc.add(AddPostIntoFirestore(post));
  }
}

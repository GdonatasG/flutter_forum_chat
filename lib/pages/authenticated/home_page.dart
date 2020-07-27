import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterforum/bloc/home_page/home_page_bloc.dart';
import 'package:flutterforum/model/category.dart';
import 'package:flutterforum/model/user.dart';
import 'package:flutterforum/pages/auth/login_page.dart';
import 'package:flutterforum/pages/authenticated/category_posts_page.dart';
import 'package:flutterforum/pages/authenticated/user_chats_page.dart';
import 'package:flutterforum/services/auth_service.dart';
import 'package:flutterforum/services/category_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:flutterforum/utils/extensions.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final FirebaseUser user;

  const HomePage({Key key, @required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User _firestoreUser;
  List<Category> _listOfCategories;
  String appBarTitle = "";
  HomePageBloc _homePageBloc;
  AuthService _authService;
  UserService _userService;
  CategoryService _categoryService;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _authService = Provider.of<AuthService>(context, listen: false);
    _userService = Provider.of<UserService>(context, listen: false);
    _categoryService = Provider.of<CategoryService>(context, listen: false);
    _homePageBloc = HomePageBloc(_userService, _categoryService);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => UserChatsPage(
                      currentUserId: widget.user.uid,
                    ))),
            icon: Icon(Icons.chat),
          ),
          IconButton(
            onPressed: () => _showBottomSheet(),
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
            stream: _homePageBloc.streamFirestoreUser(widget.user.uid),
            builder: (BuildContext context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.exists) {
                  _firestoreUser = User.fromMap(snapshot.data.data);
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    setState(() {
                      appBarTitle = "Hi, " + _firestoreUser.username;
                    });
                  });
                  return _getCategories();
                } else {
                  _changePage(LoginPage(
                    snackBar: SnackBar(
                      content: Text("User not found"),
                    ),
                  ));
                  return Container();
                }
              } else {
                return _showLoadingLayout();
              }
            }),
      ));

  _showLoadingLayout() => Center(
        child: CircularProgressIndicator(),
      );

  _getCategories() => StreamBuilder<QuerySnapshot>(
        stream: _homePageBloc.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.documents.length > 0) {
              _listOfCategories = List<Category>();
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                _listOfCategories
                    .add(Category.fromMap(snapshot.data.documents[i].data));
                _listOfCategories[_listOfCategories.length - 1].id =
                    snapshot.data.documents[i].documentID;
              }
              return _buildCategoriesLayout();
            } else {
              _listOfCategories = List<Category>();
              return _buildEmptyListLayout();
            }
          } else
            return _showLoadingLayout();
        },
      );

  _buildEmptyListLayout() => Center(
        child: Text("List is empty ;("),
      );

  _buildCategoriesLayout() => ListView.builder(
      itemCount: _listOfCategories.length,
      itemBuilder: (context, i) {
        return _buildCategoryItem(_listOfCategories[i]);
      });

  _buildCategoryItem(Category category) => Container(
        margin: EdgeInsets.only(left: 10, right: 10, top: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.blue.shade800,
        ),
        child: ListTile(
          onTap: () => Navigator.of(context).push(new MaterialPageRoute(
              builder: (context) => CategoryPostsPage(
                    user: widget.user,
                    category: category,
                  ))),
          title: Text(
            category.name,
            style: Theme.of(context).textTheme.headline4,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
        ),
      );

  _showBottomSheet() => showModalBottomSheet(
      context: context,
      builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () => _authService.signOut().then((value) {
                  Navigator.of(context).pop();
                  changePageWithReplacement(context, LoginPage());
                }),
                leading: Icon(Icons.exit_to_app),
                title: Text("Sign out"),
              )
            ],
          ));

  _changePage(Widget page) =>
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        changePageWithReplacement(context, page);
      });
}

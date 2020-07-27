import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterforum/bloc/firebaseUserLoading/firebase_user_loading_bloc.dart';
import 'package:flutterforum/bloc/firebaseUserLoading/firebase_user_loading_bloc_export.dart';
import 'package:flutterforum/pages/auth/login_page.dart';
import 'package:flutterforum/pages/authenticated/home_page.dart';
import 'package:flutterforum/services/auth_service.dart';
import 'package:flutterforum/utils/extensions.dart';
import 'package:provider/provider.dart';

class WrapperPage extends StatefulWidget {
  @override
  _WrapperPageState createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  FirebaseUserLoadingBloc _firebaseUserLoadingBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _firebaseUserLoadingBloc = FirebaseUserLoadingBloc(
        Provider.of<AuthService>(context, listen: false));
    _firebaseUserLoadingBloc.add(LoadCurrentUser());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(
          child:
              BlocListener<FirebaseUserLoadingBloc, FirebaseUserLoadingState>(
            bloc: _firebaseUserLoadingBloc,
            listener: (_, state) {},
            child:
                BlocBuilder<FirebaseUserLoadingBloc, FirebaseUserLoadingState>(
              bloc: _firebaseUserLoadingBloc,
              builder: (_, state) {
                if (state is FirebaseUserLoaded)
                  _setPage(context, state.user);
                else if (state is FirebaseUserLoadingError)
                  _changePage(LoginPage(), context);
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  _setPage(BuildContext context, FirebaseUser user) => user == null
      ? _changePage(LoginPage(), context)
      : user.isEmailVerified
          ? _changePage(
              HomePage(
                user: user,
              ),
              context)
          : _changePage(LoginPage(), context);

  _changePage(page, context) =>
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        changePageWithReplacement(context, page);
      });
}

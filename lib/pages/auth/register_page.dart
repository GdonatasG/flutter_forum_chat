import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterforum/bloc/register/register_bloc.dart';
import 'package:flutterforum/bloc/register/register_bloc_export.dart';
import 'package:flutterforum/model/user.dart';
import 'package:flutterforum/pages/auth/login_page.dart';
import 'package:flutterforum/services/auth_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:flutterforum/utils/extensions.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final Function toggleView;

  const RegisterPage({Key key, this.toggleView}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  RegisterBloc _registerBloc;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final _nameFocus = FocusNode();

  final TextEditingController _lastnameController = TextEditingController();
  final _lastnameFocus = FocusNode();

  final TextEditingController _usernameController = TextEditingController();
  final _usernameFocus = FocusNode();

  final TextEditingController _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  final TextEditingController _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  final TextEditingController _passwordConfController = TextEditingController();
  final _passwordConfFocus = FocusNode();

  @override
  void initState() {
    _registerBloc = RegisterBloc(
        Provider.of<AuthService>(context, listen: false),
        Provider.of<UserService>(context, listen: false));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(
            child: BlocListener<RegisterBloc, RegisterState>(
          bloc: _registerBloc,
          listener: (_, state) {
            if (state is RegisterError) {
              showSnackbar(_scaffoldKey, state.error);
            }
          },
          child: BlocBuilder<RegisterBloc, RegisterState>(
            bloc: _registerBloc,
            builder: (_, state) {
              if (state is RegisterSuccessful) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  changePageWithReplacement(
                      context,
                      LoginPage(
                        snackBar: SnackBar(
                          content:
                              Text("Verification link was sent to your email!"),
                        ),
                      ));
                });
              }
              return _registerForm();
            },
          ),
        )),
      ),
    );
  }

  _registerForm() => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: StreamBuilder(
                stream: _registerBloc.progressIndicatorStream,
                builder: (_, snapshot) {
                  bool isFormActionsEnabled =
                      snapshot.hasData ? !snapshot.data : true;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        enabled: isFormActionsEnabled,
                        focusNode: _nameFocus,
                        validator: (input) => input.trim().length > 5
                            ? null
                            : "Enter name (more than 5 symbols)!",
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (t) => _fieldFocusChange(
                            context, _nameFocus, _lastnameFocus),
                        style: Theme.of(context).textTheme.headline4,
                        decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.headline4,
                            contentPadding: EdgeInsets.all(15),
                            hintText: "Enter your name"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _lastnameController,
                        focusNode: _lastnameFocus,
                        textInputAction: TextInputAction.next,
                        validator: (input) => input.trim().length > 5
                            ? null
                            : "Enter last name (more than 5 symbols)!",
                        onFieldSubmitted: (t) => _fieldFocusChange(
                            context, _lastnameFocus, _usernameFocus),
                        style: Theme.of(context).textTheme.headline4,
                        decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.headline4,
                            contentPadding: EdgeInsets.all(15),
                            hintText: "Enter your last name"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _usernameController,
                        focusNode: _usernameFocus,
                        textInputAction: TextInputAction.next,
                        validator: (input) => input.trim().length > 5
                            ? null
                            : "Enter username (more than 5 symbols)!",
                        onFieldSubmitted: (t) => _fieldFocusChange(
                            context, _usernameFocus, _emailFocus),
                        style: Theme.of(context).textTheme.headline4,
                        decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.headline4,
                            contentPadding: EdgeInsets.all(15),
                            hintText: "Enter username"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        textInputAction: TextInputAction.next,
                        validator: (input) =>
                            EmailValidator.validate(input.trim())
                                ? null
                                : "Enter valid email!",
                        onFieldSubmitted: (t) => _fieldFocusChange(
                            context, _emailFocus, _passwordFocus),
                        style: Theme.of(context).textTheme.headline4,
                        decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.headline4,
                            contentPadding: EdgeInsets.all(15),
                            hintText: "Enter your email"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        textInputAction: TextInputAction.next,
                        obscureText: true,
                        onFieldSubmitted: (t) => _fieldFocusChange(
                            context, _passwordFocus, _passwordConfFocus),
                        validator: (input) => input.trim().length > 8
                            ? null
                            : "Enter password (more than 8 symbols)!",
                        style: Theme.of(context).textTheme.headline4,
                        decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.headline4,
                            contentPadding: EdgeInsets.all(15),
                            hintText: "Enter password"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        controller: _passwordConfController,
                        focusNode: _passwordConfFocus,
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        validator: (input) => input.trim() ==
                                _passwordController.value.text.trim()
                            ? null
                            : "Passwords don't match!",
                        style: Theme.of(context).textTheme.headline4,
                        decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.headline4,
                            contentPadding: EdgeInsets.all(15),
                            hintText: "Confirm password"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FlatButton(
                        color: Colors.blue.shade800,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _registerUser();
                          }
                        },
                        child: Text(
                          "Register",
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () =>
                                changePageWithReplacement(context, LoginPage()),
                            child: Text(
                              "I have an account",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(color: Colors.blue.shade800),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: snapshot.hasData ? snapshot.data : false,
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  );
                }),
          ),
        ),
      );

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  _registerUser() {
    User firestoreUser = User(
        _nameController.value.text.trim(),
        _lastnameController.value.text.trim(),
        _usernameController.value.text.trim());
    _registerBloc.add(RegisterUser(
        firestoreUser,
        _emailController.value.text.trim(),
        _passwordController.value.text.trim()));
  }
}

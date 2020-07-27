import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterforum/bloc/login/login_bloc_export.dart';
import 'package:flutterforum/pages/auth/register_page.dart';
import 'package:flutterforum/pages/authenticated/home_page.dart';
import 'package:flutterforum/services/auth_service.dart';
import 'package:flutterforum/services/user_service.dart';
import 'package:flutterforum/utils/extensions.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final SnackBar snackBar;

  const LoginPage({Key key, this.snackBar}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  final TextEditingController _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  @override
  void initState() {
    _loginBloc = LoginBloc(Provider.of<AuthService>(context, listen: false),
        Provider.of<UserService>(context, listen: false));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.snackBar != null)
        _scaffoldKey.currentState.showSnackBar(widget.snackBar);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(
            child: BlocListener<LoginBloc, LoginState>(
          bloc: _loginBloc,
          listener: (_, state) {
            if (state is LoginError) {
              showSnackbar(_scaffoldKey, state.error);
            }
          },
          child: BlocBuilder<LoginBloc, LoginState>(
            bloc: _loginBloc,
            builder: (_, state) {
              if (state is LoginWithEmailAndPasswordSuccessful) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  changePageWithReplacement(
                      context, HomePage(user: state.user));
                });
              } else if (state is LoginWithGoogleSuccessful) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  changePageWithReplacement(
                      context, HomePage(user: state.user));
                });
              }
              return _loginForm();
            },
          ),
        )),
      ),
    );
  }

  _loginForm() => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Form(
            key: _formKey,
            child: StreamBuilder(
                stream: _loginBloc.progressIndicatorStream,
                builder: (_, snapshot) {
                  bool isFormActionsEnabled =
                      snapshot.hasData ? !snapshot.data : true;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        enabled: isFormActionsEnabled,
                        focusNode: _emailFocus,
                        validator: (input) =>
                            EmailValidator.validate(input.trim())
                                ? null
                                : "Enter valid email!",
                        textInputAction: TextInputAction.next,
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
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        style: Theme.of(context).textTheme.headline4,
                        decoration: InputDecoration(
                            hintStyle: Theme.of(context).textTheme.headline4,
                            contentPadding: EdgeInsets.all(15),
                            hintText: "Enter your password"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      FlatButton(
                        color: Colors.blue.shade800,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            _loginBloc.add(LoginWithEmailAndPassword(
                                _emailController.value.text.trim(),
                                _passwordController.value.text));
                          }
                        },
                        child: Text(
                          "Login",
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
                            onTap: () => Navigator.of(context).pushReplacement(
                                new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        RegisterPage())),
                            child: Text(
                              "Register Here",
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  .copyWith(color: Colors.blue.shade800),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "|",
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                .copyWith(color: Colors.blue.shade800),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          GestureDetector(
                            onTap: () => print("forgot tapped"),
                            child: Text(
                              "Forgot Password",
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
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          FlatButton(
                            color: Colors.blue.shade800,
                            onPressed: () {
                              _loginBloc.add(LoginWithGoogleAccount());
                            },
                            child: Text(
                              "GOOGLE SIGN IN",
                              style: Theme.of(context).textTheme.headline4,
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
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterforum/utils/extensions.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future signInWithEmailAndPassword(String email, String password) {
    return _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .timeout(Duration(seconds: 15));
  }

  Future signInWithGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
    return await _auth
        .signInWithCredential(credential)
        .timeout(Duration(seconds: 15));
  }

  Future createUserWithEmailAndPassword(String email, String password) {
    return _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .timeout(Duration(seconds: 15));
  }

  Future loadCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    // reloading user if exists and has internet connection
    // (to let user still use application if internet is off)
    if (user != null && await hasInternet()) await user.reload();
    return await _auth.currentUser();
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}

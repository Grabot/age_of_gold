import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi{
  static final _googleSignIn = GoogleSignIn(
    clientId: "you can enter your clientId.apps.googleusercontent.com",
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],);


  static Future<GoogleSignInAccount?> Login() => _googleSignIn.signIn();
  static Future<GoogleSignInAccount?>SignOut() => _googleSignIn.signOut();
}
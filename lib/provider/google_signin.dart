import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider with ChangeNotifier {
  GoogleSignInAccount? _user;
  GoogleSignInAccount? get user => _user;

  Future<void> googleLogin() async {
    try {
      
      await GoogleSignIn.instance.initialize(
        clientId: '1069072609963-11oj9ksvaf6rmljbut7smcqbg84od0r9.apps.googleusercontent.com',
       
      );

      final googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) return;

      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw "No ID token";

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);

      notifyListeners();
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }

  Future<void> logout() async {
    await GoogleSignIn.instance.signOut();
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }
}
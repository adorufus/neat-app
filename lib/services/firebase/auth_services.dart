import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:neat/config.dart';
import 'package:neat/services/firebase/database_services.dart';
import 'package:neat/services/localStorageService.dart';
import 'package:neat/views/home.dart';

class Authentication {
  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;

        Database.firestore
            .collection('users')
            .doc(user?.uid)
            .get()
            .then((value) async {
          if (!value.exists) {
            Database.post(reference: 'users', doc: user!.uid, data: {
              'username': user.email,
              'email': user.email,
              'full_name': user.displayName,
              'role': 'user'
            }).then((value) async {
              await LocalStorageService.save("username", user?.displayName);
              await LocalStorageService.save("uid", user?.uid);
              setWorkStartTime();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomeWidget()));
            });
          } else {
            await LocalStorageService.save("username", user?.displayName);
            await LocalStorageService.save("uid", user?.uid);
            setWorkStartTime();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => HomeWidget()));
          }
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          print(e.message);
          ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                  content:
                      'The account already exists with a different credential'));
        } else if (e.code == 'invalid-credential') {
          print(e.message);
          ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                  content:
                      'Error occurred while accessing credentials. Try again.'));
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context)
            .showSnackBar(Authentication.customSnackBar(content: e.toString()));
      }
    }

    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(Authentication.customSnackBar(
          content: 'Error signing out. Try again.'));
    }
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}

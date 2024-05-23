import 'dart:developer';
import 'dart:io';

import 'package:chat_app2/api/apis.dart';
import 'package:chat_app2/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../helpers/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handleGoogleBtnClick() async {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) {
      if (user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const Homescreen()));
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log('_signInWithGoogle: $e');
      // ignore: use_build_context_synchronously
      Dialogs.showSnackBar(context, 'Something went wrong');
      return null;
    }
  }

  _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 2,
          title: const Text('Welcome to Chat App'),
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () async {
                _handleGoogleBtnClick();

                if ((await APIs.userExists())) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const Homescreen()));
                }
                else{
                  APIs.createUser().then((value) {
                     Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const Homescreen()));
                  });
                }
                ;
              },
              child: const Text('Sign in with Google')),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';

class Bleh extends StatefulWidget {
  const Bleh({super.key});

  @override
  State<Bleh> createState() => _BlehState();
}

class _BlehState extends State<Bleh> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    signIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }

  Future<void> signIn() async {
    await GoogleSignIn().signOut();
    GoogleSignIn(scopes: [GmailApi.gmailReadonlyScope]).signIn().then((value) {
      // Handle success
    }).catchError((error) {
      // Handle error
      print('Error: $error');
    });
  }
}

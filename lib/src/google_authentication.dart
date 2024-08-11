import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:google_meet_sdk/src/utils/calendar_client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:http/io_client.dart';
import 'package:platform_metadata/platform_metadata.dart';

import '../google_meet_sdk.dart';

class GoogleAuthentication {
  ///to login via google
  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    var clientId = await PlatformMetadata.getMetaDataValue('clientId') ?? '';

    var serverClientId =
        await PlatformMetadata.getMetaDataValue('serverClientId');

    if (clientId.isEmpty) {
      customSnackBar(content: 'Enter clientId in manifest');
      return null;
    }

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: clientId,
      serverClientId: serverClientId,
      scopes: <String>[
        cal.CalendarApi.calendarScope,
        cal.CalendarApi.calendarEventsScope,
      ],
    );

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleAPIClient httpClient =
          GoogleAPIClient(await googleSignInAccount.authHeaders);
      CalendarClient.calendar = cal.CalendarApi(httpClient);

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          customSnackBar(
              content:
                  'The account already exists with a different credential');
        } else if (e.code == 'invalid-credential') {
          customSnackBar(
              content:
                  'Error occurred while accessing credentials. Try again.');
        }
      } catch (e) {
        customSnackBar(
            content: 'Error occurred using Google Sign In. Try again.');
      }
    }

    return user;
  }

  ///to logout from  google
  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Error signing out. Try again.');
    }
  }

  ///to show snackBar
  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}

class GoogleAPIClient extends IOClient {
  final Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(request) =>
      super.send(request..headers.addAll(_headers));
}

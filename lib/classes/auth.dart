import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:url_launcher/url_launcher.dart';

Future<AuthClient> getAuthenticatedClient() async {
  try {
    final jsonString = await rootBundle.loadString('assets/docs/client_secret.json');
    if (jsonString.isEmpty) {
      throw Exception('Failed to load client_secret.json');
    }

    final jsonMap = jsonDecode(jsonString);
    final credentials = ClientId(
      jsonMap['installed']['client_id'] as String,
      jsonMap['installed']['client_secret'] as String,
    );
    final scopes = [GmailApi.gmailReadonlyScope];

    return await clientViaUserConsent(credentials, scopes, (url) async {
      await launchUrl(Uri.parse(url));
      // if (await canLaunch(url)) {
      //   await launch(url, forceSafariVC: false, forceWebView: false);
      // } else {
      //   throw 'Could not launch $url';
      // }
    });
  } catch (e) {
    print('Error loading client_secret.json: $e');
    rethrow;
  }
}

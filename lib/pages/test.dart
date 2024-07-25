import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';

import '../main.dart';
import 'notification_callback_for_gmails.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final googleSignIn = GoogleSignIn(scopes: [GmailApi.gmailReadonlyScope]);
  String mailData = "";
  late GoogleSignInAccount? _currentUser;
  ListMessagesResponse mails = ListMessagesResponse();

  Future<void> _selectNotification(NotificationResponse payload) async {

    // Handle notification tap
    String p = payload.payload!;
    print("innnnn:\n$p");
    List<String> lines = p.split("\n");

    var from = lines[0];
    var body = "";

    lines.removeAt(0);

    for(var l in lines) {
      body += "$l ";
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NotificationCallbackForGmails(title: from, body: body),
      ),
    );
  }




  void initializeNotifications() {

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    print("jjjjj");
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: _selectNotification,);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('your_channel_id', 'your_channel_name',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);

    // Create a BigTextStyleInformation object to make the notification expandable
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: false,
      contentTitle: title,
      htmlFormatContentTitle: false,
    );

    // Create a new AndroidNotificationDetails object with the BigTextStyleInformation
    AndroidNotificationDetails updatedAndroidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      styleInformation: bigTextStyleInformation,
    );

    NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: updatedAndroidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics, payload: "$title\n$body");
  }

  readMails() async {
    final authClient = await googleSignIn.authenticatedClient();
    final gmailApi = GmailApi(authClient!);

    final unreadMails =
    await gmailApi.users.messages.list('me', q: 'is:unread');
    setState(() {
      mails = unreadMails;
    });

    var m = mails.messages;

    if (m != null && m.isNotEmpty) {
      final latestMail = m.first;
      final messageId = latestMail.id;
      final message =
      await gmailApi.users.messages.get('me', messageId!, format: 'full');
      final payload = message.payload;
      var sender = "";
      String bodyText = '';

      // Get the sender from the payload headers
      for (var header in payload!.headers!) {
        if (header.name == 'From') {
          sender = header.value!;
          break;
        }
      }

      for (var part in payload!.parts!) {
        bodyText += utf8.decode(base64Decode(part.body!.data!));
      }

      setState(() {
        mailData = bodyText;
      });

      initializeNotifications();
      showNotification(sender, mailData);

      print('Latest new mail body: $bodyText');
    }
  }

  googleSignInUser() {
    googleSignIn.signIn();
    googleSignIn.onCurrentUserChanged.listen((account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        readMails();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Gmail Listener'),
        ),
        body: Center(
          child: ListView(
            children: [
              ElevatedButton(
                onPressed: () async {
                  // final emails = await getUnreadEmails();
                  // for (var email in emails) {
                  //   showNotification('New Email', email.snippet ?? 'No content');
                  // }
                  await googleSignInUser();
                  // await _handleSignIn();
                  // await signInWithGoogle();
                  // print(mails.messages?.first.id);
                },
                child: const Text('Check for Unread Emails'),
              ),
              SelectableText(
                mailData,
              )
            ],
          ),
        ),
      ),
    );
  }
}
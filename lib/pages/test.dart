import 'dart:convert';

import 'package:background_fetch/background_fetch.dart' hide NetworkType;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gemailai/classes/shared_preferences_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/appengine/v1.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:workmanager/workmanager.dart';

import '../main.dart';
import 'notification_callback_for_gmails.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

// void callbackDispatcher() {
//   Workmanager().executeTask((task, x) async {
//     // This is the task that will be executed at a 10-second interval
//     await _TestState().readMails();
//     return Future.value(true);
//   });
// }

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     // Call your readMails() method here
//     // ...
//     await _TestState().readMails();
//     return Future.value(true);
//   });
// }



void callbackDispatch() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case "readMails":
        await readMailsTask();
        break;
    }
    return Future.value(true);
  });
}

Future<void> readMailsTask() async {
  // Call your readMails method here
  await _TestState().readMails();
}


class _TestState extends State<Test> {
  final googleSignIn = GoogleSignIn(scopes: [GmailApi.gmailReadonlyScope]);
  String mailData = "";
  late GoogleSignInAccount? _currentUser;
  ListMessagesResponse mails = ListMessagesResponse();


  Future<void> startBackgroundTask() async {
    await Workmanager().initialize(
      callbackDispatch,
      isInDebugMode: true,
    );
    Workmanager().registerPeriodicTask(
      "1",
      "readMails",
      frequency: const Duration(seconds: 10),
      constraints: Constraints(
        requiresBatteryNotLow: true, networkType: NetworkType.connected,
      ),
      inputData: {
        'key': 'value',
      },
    );
  }



  Future<void> _selectNotification(NotificationResponse payload) async {
    // Handle notification tap
    String p = payload.payload!;
    print("innnnn:\n$p");
    List<String> lines = p.split("\n");

    var from = lines[0];
    var body = "";

    lines.removeAt(0);

    for (var l in lines) {
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
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    print("jjjjj");
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _selectNotification,
    );
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
        0, title, body, platformChannelSpecifics,
        payload: "$title\n$body");
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


      SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
      if(await sharedPreferencesHelper.getKeyExistingApproval("latest mail") && await sharedPreferencesHelper.getStringFromSharedPreferences("latest mail") == bodyText) {
        return;
      }

      sharedPreferencesHelper.saveStringToSharedPreferences("latest mail", bodyText);

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



  ///////////////////////////////////////////////////////


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startBackgroundTask();
    initializeNotifications();
    // initWorkManager();
  }

  // initWorkManager() {
  //   Workmanager().initialize(
  //     callbackDispatcher,
  //     isInDebugMode: true,
  //   );
  //
  //   Workmanager().registerPeriodicTask(
  //     "1",
  //     "simplePeriodicTask",
  //     frequency: const Duration(seconds: 10),
  //   );
  // }

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
                  await googleSignInUser();
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
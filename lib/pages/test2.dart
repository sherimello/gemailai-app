import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gemailai/pages/dashboard.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import '../classes/shared_preferences_helper.dart';
import '../main.dart';
import 'notification_callback_for_gmails.dart';

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final socket = io.io("your-server-url", <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });
  socket.onConnect((_) {
    print('Connected. Socket ID: ${socket.id}');
    // Implement your socket logic here
    // For example, you can listen for events or send data
  });

  socket.onDisconnect((_) {
    print('Disconnected');
  });
  socket.on("event-name", (data) {
    //do something here like pushing a notification
  });
  service.on("stop").listen((event) {
    service.stopSelf();
    print("background process is now stopped");
  });

  service.on("start").listen((event) {});

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    socket.emit("event-name", "your-message");
    print("service is successfully running ${DateTime.now().second}");
    try {
      // await _Test2State().initAuthClient();
      _Test2State().initializeNotifications();
      _Test2State().readMails();
    } catch (e) {
      service.stopSelf();
    }
  });
}

class Test2 extends StatefulWidget {

  // final AuthClient authClient;

  // const Test2({super.key, required this.authClient});
  const Test2({super.key});

  @override
  State<Test2> createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  late AuthClient authClient;
  final googleSignIn = GoogleSignIn(scopes: [
    GmailApi.gmailReadonlyScope,
  ],);
  String mailData = "";
  late GoogleSignInAccount? _currentUser;
  ListMessagesResponse mails = ListMessagesResponse();
  double textOpacity = 0;
  Timer t = Timer(Duration.zero, () {});
  bool isMailServiceInitiated = false;
  String displayMessage = "is being initiated...";
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

  triggerTextOpacity() {
    t = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        textOpacity = 1;
      });
      triggerMailServiceInitiated();
    });
  }

  triggerMailServiceInitiated() {
    t = Timer(
        const Duration(milliseconds: 2000),
        () => setState(() {
              displayMessage = "initiated!";
              isMailServiceInitiated = true;
            }));
  }

  Future<User?> signInWithGoogle() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    try {
      // Triggering Google sign-in flow
      final GoogleSignInAccount? googleSignInAccount =
      await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        // Google sign-in successful, now authenticate with Firebase
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        // User canceled the sign-in
        print('Google sign-in aborted.');
        return null;
      }
    } catch (error) {
      print('Error signing in with Google: $error');
      return null;
    }
  }

  readMails() async {
    print("in read mails");
    // await initAuthClient();
    // authClient = (await googleSignIn.authenticatedClient())!;
    await googleSignIn.signInSilently();
    authClient = (await googleSignIn.authenticatedClient())!;
    final gmailApi = GmailApi(authClient);

    final unreadMails =
        await gmailApi.users.messages.list('me', q: 'is:unread');
    // setState(() {
    mails = unreadMails;
    // });

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

      // setState(() {
      mailData = bodyText;
      // });

      sharedPreferencesHelper.saveBoolToSharedPreferences("isMailAssistantActive", true);

      if (await sharedPreferencesHelper.getKeyExistingApproval("latest mail") &&
          await sharedPreferencesHelper
                  .getStringFromSharedPreferences("latest mail") ==
              bodyText) {
        return;
      }

      sharedPreferencesHelper.saveStringToSharedPreferences(
          "latest mail", bodyText);

      initializeNotifications();
      showNotification(sender, mailData);

      print('Latest new mail body: $bodyText');
    }
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

  Future<void> initAuthClient() async {
    // setState(() {
    //   authClient = widget.authClient;
    // });
    try {
      await googleSignIn.signIn(); // Try to sign in silently
      authClient = (await googleSignIn.authenticatedClient())!;
    } catch (e) {
      print(e);
      // If silent sign-in fails, prompt the user to sign in
      // await googleSignIn.signIn();

    }
  }

  // googleSignInUser() {
  //   googleSignIn.signIn();
  //   googleSignIn.onCurrentUserChanged.listen((account) async {
  //     setState(() {
  //       _currentUser = account;
  //     });
  //     if (_currentUser != null) {
  //       await initAuthClient();
  //       initializeService();
  //     }
  //   });
  // }

  googleSignInUser() {
    googleSignIn.onCurrentUserChanged.listen((account) async {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        await initAuthClient(); // Initialize authClient here
        triggerMailServiceInitiated();
        initializeService();
      }
    });
    googleSignIn.signIn(); // Start sign-in process
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

  void startBackgroundService() {
    final service = FlutterBackgroundService();
    service.startService();
  }

  void stopBackgroundService() {
    final service = FlutterBackgroundService();
    service.invoke("stop");
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        onStart: onStart,
        isForegroundMode: false,
        autoStartOnBoot: true,
      ),
    );
  }

  init() async{
    await initAuthClient(); // Initialize authClient here
    triggerMailServiceInitiated();
    initializeService();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    triggerTextOpacity();
    initializeNotifications();
    init();
    // googleSignInUser();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: AnimatedOpacity(
              curve: Curves.linearToEaseOut,
              duration: const Duration(milliseconds: 1000),
              opacity: textOpacity,
              child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(children: [
                    TextSpan(
                      text: "mail service",
                      style: TextStyle(
                          fontFamily: "SF-Pro",
                          fontWeight: FontWeight.bold,
                          color: Colors.purpleAccent,
                          fontSize: size.width * .13),
                    ),
                    TextSpan(
                      text: "\n$displayMessage",
                      style: TextStyle(
                          fontFamily: "SF-Pro",
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: size.width * .0515),
                    ),
                  ])),
            ),
          ),
          SizedBox(
            height: AppBar().preferredSize.height,
          ),
          isMailServiceInitiated
              ? GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (builder) => const DashBoard()));
                  },
                  child: Container(
                    width: size.width * .41,
                    height: AppBar().preferredSize.height,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100)),
                    child: const Center(
                      child: Text.rich(TextSpan(children: [
                        WidgetSpan(
                            child: Icon(Icons.done_all_outlined),
                            alignment: PlaceholderAlignment.middle),
                        TextSpan(
                          text: "  done",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "SF-Pro",
                              fontWeight: FontWeight.bold),
                        )
                      ])),
                    ),
                  ),
                )
              : const CircularProgressIndicator(
                  color: Colors.white,
                )
        ],
      ),
    );
  }
}

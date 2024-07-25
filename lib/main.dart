// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:gemailai/pages/home.dart';
// import 'package:gemailai/pages/sign_in.dart';
// import 'package:gemailai/pages/test.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   /// initializing the firebase app
//   await Firebase.initializeApp(
//       options: const FirebaseOptions(
//     apiKey: 'AIzaSyDK9meOMA78ZsdsIQ4Ow8vcDvDY0nzDlAA',
//     appId: 'appId',
//     messagingSenderId: 'messagingSenderId',
//     projectId: 'projectId',
//     storageBucket: 'storageBucket',
//   ));
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     // Change status bar color
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent, // Change it to any color you want
//     ));
//     return MaterialApp(
//         title: 'Flutter Demo',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//           useMaterial3: true,
//         ),
//         home: const SignIn());
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/gmail/v1.dart' as gmail;
// import 'package:http/http.dart' as http;
//
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: 'AIzaSyDK9meOMA78ZsdsIQ4Ow8vcDvDY0nzDlAA',
//         appId: 'appId',
//         messagingSenderId: 'messagingSenderId',
//         projectId: 'projectId',
//         storageBucket: 'storageBucket',
//       ));
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: GmailNotificationsLog(),
//     );
//   }
// }
//
// class GmailNotificationsLog extends StatefulWidget {
//   @override
//   _GmailNotificationsLogState createState() => _GmailNotificationsLogState();
// }
//
// class _GmailNotificationsLogState extends State<GmailNotificationsLog> {
//   List<gmail.Message> _log = [];
//   bool _loading = false;
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: [
//       gmail.GmailApi.gmailReadonlyScope,
//     ],
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
//       if (account != null) {
//         _fetchEmails();
//       }
//     });
//     _googleSignIn.signInSilently();
//   }
//
//   Future<Map<String, dynamic>> loadClientSecret() async {
//     final jsonString = await rootBundle.loadString('assets/client_secret.json');
//     return json.decode(jsonString);
//   }
//
//   Future<void> _fetchEmails() async {
//     if (_googleSignIn.currentUser == null) {
//       // User is not signed in, attempt to sign in
//       await _googleSignIn.signIn();
//     }
//
//     if (_googleSignIn.currentUser == null) {
//       // If the user is still not signed in, handle this case appropriately
//       setState(() {
//         _loading = false;
//       });
//       return;
//     }
//
//     setState(() {
//       _loading = true;
//     });
//
//     final authHeaders = await _googleSignIn.currentUser!.authHeaders;
//     final authenticatedClient = GoogleHttpClient(authHeaders);
//
//     final gmailApi = gmail.GmailApi(authenticatedClient);
//     final messages = await gmailApi.users.messages.list('me');
//     final messageList = messages.messages ?? [];
//
//     final List<gmail.Message> fullMessages = [];
//     for (var message in messageList) {
//       final msg = await gmailApi.users.messages.get('me', message.id!);
//       fullMessages.add(msg);
//     }
//
//     setState(() {
//       _log = fullMessages;
//       _loading = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Gmail Notifications'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               _googleSignIn.signOut();
//             },
//             icon: Icon(Icons.logout),
//           ),
//         ],
//       ),
//       body: Center(
//         child: _loading
//             ? CircularProgressIndicator()
//             : ListView.builder(
//           itemCount: _log.length,
//           reverse: true,
//           itemBuilder: (BuildContext context, int idx) {
//             final entry = _log[idx];
//             return ListTile(
//               title: Text(entry.snippet ?? "<<no snippet>>"),
//               subtitle: Text(entry.payload?.headers
//                   ?.firstWhere((header) => header.name == 'Subject')
//                   .value ??
//                   "<<no subject>>"),
//             );
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _fetchEmails,
//         tooltip: 'Fetch Emails',
//         child: Icon(Icons.refresh),
//       ),
//     );
//   }
// }
//
// class GoogleHttpClient extends http.BaseClient {
//   final Map<String, String> _headers;
//   final http.Client _client = http.Client();
//
//   GoogleHttpClient(this._headers);
//
//   @override
//   Future<http.StreamedResponse> send(http.BaseRequest request) {
//     return _client.send(request..headers.addAll(_headers));
//   }
// }

// import 'dart:async';
// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:googleapis/authorizedbuyersmarketplace/v1.dart';
// import 'package:googleapis/gmail/v1.dart' as gmail;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:googleapis_auth/auth_io.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: const FirebaseOptions(
//       apiKey: 'AIzaSyDK9meOMA78ZsdsIQ4Ow8vcDvDY0nzDlAA',
//       appId: 'appId',
//       messagingSenderId: 'messagingSenderId',
//       projectId: 'projectId',
//       storageBucket: 'storageBucket',
//     ),
//   );
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: GmailNotificationsLog(),
//     );
//   }
// }
//
// class GmailNotificationsLog extends StatefulWidget {
//   @override
//   _GmailNotificationsLogState createState() => _GmailNotificationsLogState();
// }
//
// class _GmailNotificationsLogState extends State<GmailNotificationsLog> {
//   List<gmail.Message> _log = [];
//   bool _loading = false;
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: [
//       gmail.GmailApi.gmailReadonlyScope,
//     ],
//   );
//   final String apiKey = 'AIzaSyDK9meOMA78ZsdsIQ4Ow8vcDvDY0nzDlAA';
//
//   @override
//   void initState() {
//     super.initState();
//     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
//       if (account != null) {
//         _initClient();
//       }
//     });
//     _googleSignIn.signInSilently();
//   }
//   final jsonString = rootBundle.loadString('assets/docs/client_secret.json');
//
//   // final _clientId = _clientSecretJson['web']['client_id'];
//   // final _clientSecret = _clientSecretJson['web']['client_secret'];
//   // final _redirectUri = _clientSecretJson['web']['redirect_uris'][0];
//
//   late AutoRefreshingAuthClient _client;

// Future<void> _initClient() async {
//   final clientSecretJson = jsonDecode(await jsonString);
//   final credentials = ServiceAccountCredentials(_googleSignIn.currentUser!.email, ClientId(clientSecretJson['installed']['client_id']), clientSecretJson['installed']['client_secret']);
//   // ClientId(_clientId, _clientSecret);
//   _client = await clientViaServiceAccount(credentials, [clientSecretJson['web']['redirect_uris'][0]]);
// }

// Future<void> _initClient() async {
//   final jsonString = await rootBundle.loadString('assets/docs/client_secret.json');
//   final clientSecretJson = jsonDecode(jsonString);
//
//   final clientId = clientSecretJson['installed']['client_id'];
//   final clientSecret = clientSecretJson['installed']['client_secret'];
//
//   final authClient = await clientViaOAuth2(
//     clientId,
//     clientSecret,
//     ['https://mail.google.com/'],
//   );
//
//   final httpClient = http.Client(authClient);
//   _client = gmail.v1.GmailApi(httpClient);
// }

//   Future<void> _fetchNewMessages() async {
//     setState(() {
//       _loading = true;
//     });
//     final gmailApi = gmail.GmailApi(_client);
//     final response = await gmailApi.users.messages.list('me', q: 'is:unread');
//     setState(() {
//       _log = response.messages!;
//       _loading = false;
//     });
//   }
//   Future<void> _fetchEmails() async {
//     setState(() {
//       _loading = true;
//     });
//
//     final url = 'https://gmail.googleapis.com/gmail/v1/users/me/messages?key=$apiKey';
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       final messages = gmail.ListMessagesResponse.fromJson(json.decode(response.body));
//       final messageList = messages.messages ?? [];
//
//       final List<gmail.Message> fullMessages = [];
//       for (var message in messageList) {
//         final msgUrl = 'https://gmail.googleapis.com/gmail/v1/users/me/messages/${message.id}?key=$apiKey';
//         final msgResponse = await http.get(Uri.parse(msgUrl));
//         if (msgResponse.statusCode == 200) {
//           final msg = gmail.Message.fromJson(json.decode(msgResponse.body));
//           fullMessages.add(msg);
//         }
//       }
//
//       setState(() {
//         _log = fullMessages;
//
//         _loading = false;
//       });
//     } else {
//       print("failed to validate!");
//       _googleSignIn.signOut();
//       setState(() {
//         _loading = false;
//       });
//       // Handle error
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Gmail Notifications'),
//       ),
//       body: Center(
//         child: _loading
//             ? CircularProgressIndicator()
//             : ListView.builder(
//           itemCount: _log.length,
//           reverse: true,
//           itemBuilder: (BuildContext context, int idx) {
//             final entry = _log[idx];
//             return ListTile(
//               title: Text(entry.snippet ?? "<<no snippet>>"),
//               subtitle: Text(entry.payload?.headers
//                   ?.firstWhere((header) => header.name == 'Subject')
//                   .value ??
//                   "<<no subject>>"),
//             );
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           if (_googleSignIn.currentUser == null) {
//             // User is not signed in, attempt to sign in
//             await _googleSignIn.signIn();
//           }
//           await _initClient();
//           _fetchNewMessages();
//           // await _googleSignIn.signOut();
//           // _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
//           //   if (account != null) {
//           //     _fetchEmails();
//           //   }
//           // });
//           // await _googleSignIn.signInSilently();
//           // _fetchEmails();
//         },
//         tooltip: 'Fetch Emails',
//         child: Icon(Icons.refresh),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'classes/email_listener.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final emailListener = EmailListener();
//   await emailListener.initialize();
//   runApp(MyApp(emailListener));
// }
//
// class MyApp extends StatelessWidget {
//   final EmailListener emailListener;
//
//   MyApp(this.emailListener);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Gmail Listener App'),
//         ),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () async {
//               await emailListener.listenForEmails();
//             },
//             child: Text('Listen for Emails'),
//           ),
//         ),
//       ),
//     );
//   }
// }
//

import 'dart:convert';

// import 'package:flutter_html/html_parser.dart' as html_parser;
import 'package:flutter_html/flutter_html.dart' as html_parser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gemailai/pages/notification_callback_for_gmails.dart';
import 'package:gemailai/pages/test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // initializeNotifications();
  runApp(const MyApp());
}

// Future<void> _selectNotification(NotificationResponse payload) async {
//
//   // Handle notification tap
//   // String p = payload.payload!;
//   // print("innnnn");
//   // final notificationData = jsonDecode(p);
//   // final title = notificationData['title'];
//   // final body = notificationData['body'];
//
//   await navigatorKey.currentState!.push(
//     MaterialPageRoute(
//       builder: (context) =>
//           NotificationCallbackForGmails(title: "title", body: "body"),
//     ),
//   );
// }
//
//
//
//
// void initializeNotifications() {
//
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//   flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
//
//   print("jjjjj");
//   const AndroidInitializationSettings initializationSettingsAndroid =
//   AndroidInitializationSettings('@mipmap/ic_launcher');
//
//   const InitializationSettings initializationSettings =
//   InitializationSettings(android: initializationSettingsAndroid);
//
//   flutterLocalNotificationsPlugin.initialize(initializationSettings,
//     onDidReceiveNotificationResponse: _selectNotification,);
// }

// Future<void> showNotification(String title, String body) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails('your_channel_id', 'your_channel_name',
//           importance: Importance.max, priority: Priority.high, showWhen: false);
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//       0, title, body, platformChannelSpecifics);
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Test(),
    );
  }
}

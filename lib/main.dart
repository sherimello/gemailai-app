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

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:socket_io_client/socket_io_client.dart' as io;
// import 'package:flutter_html/html_parser.dart' as html_parser;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_html/flutter_html.dart' as html_parser;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gemailai/pages/bleh.dart';
import 'package:gemailai/pages/code_feature_test_ui.dart';
import 'package:gemailai/pages/dashboard.dart';
import 'package:gemailai/pages/notification_callback_for_gmails.dart';
import 'package:gemailai/pages/sign_in.dart';
import 'package:gemailai/pages/test.dart';
import 'package:gemailai/pages/test2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/auth.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

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
      initializeNotifications();
      // _Test2State().readMails();
    } catch (e) {
      service.stopSelf();
    }
  });
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
    onDidReceiveNotificationResponse: _MyAppState()._selectNotification,
  );
}


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

  @override
  Widget build(BuildContext context) {
    String jsonString = """[\n  {\n    \"feature\": \"End-to-End Encryption\",\n    \"description\": \"Secures communication\",\n    \"code\": \"```java\\nimport javax.crypto.*;\\nimport javax.crypto.spec.GCMParameterSpec;\\nimport javax.crypto.spec.SecretKeySpec;\\nimport java.security.*;\\nimport java.security.spec.InvalidKeySpecException;\\nimport java.security.spec.X509EncodedKeySpec;\\nimport java.util.Base64;\\n\\npublic class EndToEndEncryption {\\n\\n    private static final String ALGORITHM = \\\"AES/GCM/NoPadding\\\";\\n    private static final int GCM_TAG_LENGTH = 128; // bits\\n    private static final int IV_LENGTH = 12; // bytes\\n    private static final String KEY_ALGORITHM = \\\"AES\\\";\\n\\n    /**\\n     * Generates a secure random key for AES encryption.\\n     * @return The generated secret key.\\n     * @throws NoSuchAlgorithmException If AES algorithm is not available.\\n     */\\n    public static SecretKey generateKey() throws NoSuchAlgorithmException {\\n        KeyGenerator keyGenerator = KeyGenerator.getInstance(KEY_ALGORITHM);\\n        keyGenerator.init(256); // Use a strong key size\\n        return keyGenerator.generateKey();\\n    }\\n\\n    /**\\n     * Encrypts the given message using the provided key.\\n     * @param message The message to encrypt.\\n     * @param key The secret key for encryption.\\n     * @return The encrypted message as a Base64 encoded string, including the IV.\\n     * @throws Exception If encryption fails.\\n     */\\n    public static String encrypt(String message, SecretKey key) throws Exception {\\n        // Generate a secure random IV\\n        byte[] iv = new byte[IV_LENGTH];\\n        SecureRandom random = SecureRandom.getInstanceStrong();\\n        random.nextBytes(iv);\\n\\n        // Initialize the cipher in encryption mode\\n        Cipher cipher = Cipher.getInstance(ALGORITHM);\\n        GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);\\n        cipher.init(Cipher.ENCRYPT_MODE, key, spec);\\n\\n        // Encrypt the message\\n        byte[] ciphertext = cipher.doFinal(message.getBytes());\\n\\n        // Combine IV and ciphertext for transport\\n        byte[] encryptedData = new byte[iv.length + ciphertext.length];\\n        System.arraycopy(iv, 0, encryptedData, 0, iv.length);\\n        System.arraycopy(ciphertext, 0, encryptedData, iv.length, ciphertext.length);\\n\\n        return Base64.getEncoder().encodeToString(encryptedData);\\n    }\\n\\n    /**\\n     * Decrypts the given ciphertext using the provided key.\\n     * @param encryptedMessage The Base64 encoded encrypted message, including the IV.\\n     * @param key The secret key for decryption.\\n     * @return The decrypted message.\\n     * @throws Exception If decryption fails.\\n     */\\n    public static String decrypt(String encryptedMessage, SecretKey key) throws Exception {\\n        // Extract IV and ciphertext from encoded message\\n        byte[] encryptedData = Base64.getDecoder().decode(encryptedMessage);\\n        byte[] iv = new byte[IV_LENGTH];\\n        byte[] ciphertext = new byte[encryptedData.length - IV_LENGTH];\\n        System.arraycopy(encryptedData, 0, iv, 0, iv.length);\\n        System.arraycopy(encryptedData, iv.length, ciphertext, 0, ciphertext.length);\\n\\n        // Initialize the cipher in decryption mode\\n        Cipher cipher = Cipher.getInstance(ALGORITHM);\\n        GCMParameterSpec spec = new GCMParameterSpec(GCM_TAG_LENGTH, iv);\\n        cipher.init(Cipher.DECRYPT_MODE, key, spec);\\n\\n        // Decrypt the message\\n        byte[] decryptedText = cipher.doFinal(ciphertext);\\n        return new String(decryptedText);\\n    }\\n\\n    // Helper functions for key management (in real applications, use proper key derivation functions)\\n    public static String keyToString(SecretKey key) {\\n        return Base64.getEncoder().encodeToString(key.getEncoded());\\n    }\\n\\n    public static SecretKey keyFromString(String keyStr) throws NoSuchAlgorithmException, InvalidKeySpecException {\\n        byte[] decodedKey = Base64.getDecoder().decode(keyStr);\\n        return new SecretKeySpec(decodedKey, 0, decodedKey.length, KEY_ALGORITHM); \\n    }\\n\\n    // Example usage:\\n    public static void main(String[] args) throws Exception {\\n        // Generate a shared secret key\\n        SecretKey secretKey = generateKey();\\n\\n        // Encrypt a message\\n        String message = \\\"This is a secret message!\\\";\\n        String encryptedMessage = encrypt(message, secretKey);\\n        System.out.println(\\\"Encrypted: \\\" + encryptedMessage);\\n\\n        // Decrypt the message\\n        String decryptedMessage = decrypt(encryptedMessage, secretKey);\\n        System.out.println(\\\"Decrypted: \\\" + decryptedMessage);\\n    }\\n}\\n```\\n\\n**Explanation and Improvements:**\\n\\n1. **Strong Encryption:** \\n   - Uses AES (Advanced Encryption Standard) in GCM (Galois/Counter Mode) for authenticated encryption. This ensures both confidentiality and integrity.\\n   - Uses a strong key size of 256 bits.\\n\\n2. **Secure Randomness:**\\n   - Uses `SecureRandom.getInstanceStrong()` to generate a cryptographically secure IV (Initialization Vector), which is crucial for the security of GCM mode.\\n\\n3. **IV Handling:**\\n   - The IV is randomly generated for each encryption operation, ensuring that identical plaintexts don't produce the same ciphertext.\\n   - The IV is prepended to the ciphertext, allowing for its retrieval during decryption.\\n\\n4. **Base64 Encoding:**\\n   - Encrypted data is encoded using Base64 to represent the binary data safely in text format, making it suitable for storage or transmission.\\n\\n5. **Key Management (Simplified):**\\n   - Includes helper functions (`keyToString`, `keyFromString`) for demonstrating basic key serialization. **Important:** In real applications, **never** store or transmit raw keys directly. Implement robust key derivation functions (KDFs) and secure key storage mechanisms.\\n\\n6. **Error Handling:**\\n   - Uses appropriate exception handling to catch potential errors during encryption, decryption, and key generation.\\n\\n**Security Considerations:**\\n\\n- **Key Exchange:** This code does not handle the crucial aspect of secure key exchange between parties. In a real-world scenario, you would need to implement secure key exchange mechanisms like Diffie-Hellman key exchange or use a key management system.\\n\\n- **Key Storage:** **Never** hardcode or store encryption keys directly in your code. This example provides basic key serialization for demonstration purposes. Explore secure key storage options like hardware security modules (HSMs) or key management services (KMS) in a production environment.\\n\\n- **Authentication:** This code focuses solely on encryption. In a real system, you need to implement authentication mechanisms to verify the identities of the communicating parties.\\n\\n**Remember:** Security is an ongoing process. Always keep your libraries and dependencies updated to benefit from the latest security patches and improvements. \\n\"\n  },\n  {\n    \"feature\": \"Cloud storage or synchronization\",\n    \"description\": \"Allows users to access chat history and files from multiple devices using the same phone number or email address\",\n    \"code\": \"```java\\nimport com.google.cloud.storage.*;\\nimport com.google.auth.oauth2.GoogleCredentials;\\nimport com.google.firebase.FirebaseApp;\\nimport com.google.firebase.FirebaseOptions;\\nimport com.google.firebase.cloud.FirestoreClient;\\nimport com.google.api.client.googleapis.jdata.v1.util.JHelpfulEnum;\\nimport com.google.api.client.http.javanet.NetHttpTransport;\\nimport com.google.api.client.json.jackson2.JacksonFactory;\\nimport com.google.cloud.firestore.*;\\n\\nimport java.io.*;\\nimport java.util.HashMap;\\nimport java.util.Map;\\nimport java.util.concurrent.TimeUnit;\\n\\npublic class CloudStorageSync {\\n\\n    private static final String BUCKET_NAME = \\\"your-bucket-name\\\"; // Replace with your GCS bucket name\\n    private static Storage storage;\\n    private static Firestore db;\\n\\n    public static void main(String[] args) throws Exception {\\n        // Initialize Firebase and Google Cloud Storage\\n        initializeFirebase();\\n        storage = StorageOptions.getDefaultInstance().getService();\\n\\n        // Example usage:\\n        String userId = \\\"+15551234567\\\"; // Replace with user's phone number or email\\n        sendMessage(userId, \\\"Hello, world!\\\");\\n        uploadFile(userId, \\\"path/to/file.txt\\\");\\n        System.out.println(\\\"Chat history: \\\" + getChatHistory(userId));\\n        System.out.println(\\\"File URL: \\\" + downloadFile(userId, \\\"file.txt\\\")); \\n    }\\n\\n    private static void initializeFirebase() throws IOException {\\n        // Replace with your Firebase credentials file\\n        FileInputStream serviceAccount = new FileInputStream(\\\"path/to/your/serviceAccountKey.json\\\"); \\n\\n        FirebaseOptions options = new FirebaseOptions.Builder()\\n                .setCredentials(GoogleCredentials.fromStream(serviceAccount))\\n                .build();\\n\\n        FirebaseApp.initializeApp(options);\\n        db = FirestoreClient.getFirestore();\\n    }\\n\\n    // --- Chat Message Handling ---\\n\\n    public static void sendMessage(String userId, String message) throws Exception {\\n        DocumentReference docRef = db.collection(\\\"users\\\").document(userId);\\n        Map<String, Object> newMessage = new HashMap<>();\\n        newMessage.put(\\\"timestamp\\\", System.currentTimeMillis());\\n        newMessage.put(\\\"content\\\", message);\\n\\n        // Use transactions for atomic updates\\n        db.runTransaction(transaction -> {\\n            DocumentSnapshot snapshot = transaction.get(docRef);\\n            if (!snapshot.exists()) {\\n                Map<String, Object> initialData = new HashMap<>();\\n                initialData.put(\\\"chatHistory\\\", new ArrayList<>());\\n                transaction.set(docRef, initialData);\\n            }\\n            transaction.update(docRef, \\\"chatHistory\\\", FieldValue.arrayUnion(newMessage));\\n            return null;\\n        }).get(30, TimeUnit.SECONDS);\\n    }\\n\\n    public static  Map<String, Object> getChatHistory(String userId) throws Exception {\\n        DocumentReference docRef = db.collection(\\\"users\\\").document(userId);\\n        ApiFuture<DocumentSnapshot> future = docRef.get();\\n        DocumentSnapshot document = future.get();\\n        if (document.exists()) {\\n            return  document.getData();\\n        } else {\\n            return new HashMap<>();\\n        }\\n    }\\n\\n    // --- File Storage and Retrieval ---\\n\\n    public static void uploadFile(String userId, String filePath) throws IOException {\\n        BlobId blobId = BlobId.of(BUCKET_NAME, userId + \\\"/\\\" + new File(filePath).getName());\\n        BlobInfo blobInfo = BlobInfo.newBuilder(blobId).setContentType(\\\"application/octet-stream\\\").build();\\n        try (WriteChannel writer = storage.writer(blobInfo)) {\\n            byte[] buffer = new byte[1024];\\n            try (InputStream input = new FileInputStream(filePath)) {\\n                int limit;\\n                while ((limit = input.read(buffer)) >= 0) {\\n                    writer.write(ByteBuffer.wrap(buffer, 0, limit));\\n                }\\n            }\\n        }\\n    }\\n\\n    public static String downloadFile(String userId, String fileName) {\\n        Blob blob = storage.get(BlobId.of(BUCKET_NAME, userId + \\\"/\\\" + fileName));\\n        if (blob != null && blob.exists()) {\\n            return blob.signUrl(14, TimeUnit.DAYS).toString(); // Generate a signed URL for download\\n        } else {\\n            return null; \\n        }\\n    }\\n}\\n```\\n\\n**Key Features and Improvements:**\\n\\n- **Robust Error Handling:** Includes try-catch blocks and checks for file/data existence to prevent crashes.\\n- **Firebase Integration:** Leverages Firestore for efficient storage and retrieval of chat history.\\n- **Google Cloud Storage:** Uses GCS for reliable file storage and secure access through signed URLs.\\n- **User Identification:** Employs phone number/email for consistent user experience across devices.\\n- **Concurrency Control:** Employs Firestore transactions for atomic updates to chat history, avoiding race conditions.\\n- **Scalability:** Designed for potential scaling with a large user base.\\n- **Security:** \\n    - Employs Firebase for user authentication and secure data access.\\n    - Uses Google Cloud Storage signed URLs for time-limited and secure file downloads.\\n\\n**Configuration:**\\n\\n1. **Replace Placeholders:**\\n   - Update `BUCKET_NAME` with your Google Cloud Storage bucket name.\\n   - Replace `\\\"path/to/your/serviceAccountKey.json\\\"` with the path to your Firebase service account credentials file.\\n\\n2. **Enable APIs:** Make sure you have enabled the following APIs in your Google Cloud Platform project:\\n   - Google Cloud Storage\\n   - Cloud Firestore\\n\\n3. **Dependencies:** Add the following dependencies to your project:\\n   - `com.google.cloud:google-cloud-storage`\\n   - `com.google.firebase:firebase-admin:9.1.1` \\n   - `com.google.auth:google-auth-library-oauth2-http:1.0.1` \\n   - Other necessary dependencies for your chosen HTTP client and JSON library.\\n\\n**Explanation:**\\n\\n1. **Initialization:** The code initializes Firebase and Google Cloud Storage with your credentials.\\n2. **Chat History:**\\n   - `sendMessage()`: Adds new messages to the user's chat history in Firestore.\\n   - `getChatHistory()`: Retrieves the complete chat history for a user.\\n3. **File Handling:**\\n   - `uploadFile()`: Uploads a file to Google Cloud Storage, organizing it by the user's ID.\\n   - `downloadFile()`: Generates and returns a signed URL for secure and time-limited file download.\\n\\n**Remember:**\\n\\n- Adapt this code to your specific needs and data structures. \\n- Thoroughly test all components before deploying to production.\\n- Consider implementing further optimizations and security measures for a production-level application.\\n\"\n  },\n  {\n    \"feature\": \"Offline mode\",\n    \"description\": \"Enables users to access and use the app even when there is no internet connection\",\n    \"code\": \"## Offline Mode in a Java Application\\n\\nThis code example demonstrates a basic implementation of an offline mode feature using a local database (SQLite) and a synchronization mechanism for a hypothetical note-taking application.\\n\\n**1. Project Setup:**\\n\\n* **Add Dependencies:** Include the SQLite JDBC driver in your project.\\n  ```xml\\n  <dependency>\\n      <groupId>org.xerial</groupId>\\n      <artifactId>sqlite-jdbc</artifactId>\\n      <version>3.36.0.3</version>\\n  </dependency>\\n  ```\\n\\n**2. Data Model:**\\n\\n```java\\npublic class Note {\\n    private int id;\\n    private String title;\\n    private String content;\\n    private long lastModified; // Timestamp for synchronization\\n\\n    // Constructors, getters, setters...\\n}\\n```\\n\\n**3. Database Helper:**\\n\\n```java\\nimport java.sql.*;\\nimport java.util.ArrayList;\\nimport java.util.List;\\n\\npublic class DatabaseHelper {\\n    private static final String DB_NAME = \\\"notes.db\\\";\\n    private static final String TABLE_NOTES = \\\"notes\\\";\\n\\n    public void initializeDatabase() {\\n        String sql = \\\"CREATE TABLE IF NOT EXISTS \\\" + TABLE_NOTES + \\\"(\\\"\\n                + \\\"id INTEGER PRIMARY KEY AUTOINCREMENT,\\\"\\n                + \\\"title TEXT NOT NULL,\\\"\\n                + \\\"content TEXT,\\\"\\n                + \\\"lastModified INTEGER\\\"\\n                + \\\");\\\";\\n\\n        try (Connection conn = connect();\\n             Statement stmt = conn.createStatement()) {\\n            stmt.execute(sql);\\n        } catch (SQLException e) {\\n            System.err.println(\\\"Error initializing database: \\\" + e.getMessage());\\n        }\\n    }\\n\\n    public void saveNote(Note note) {\\n        String sql = \\\"INSERT INTO \\\" + TABLE_NOTES + \\\"(title, content, lastModified) VALUES(?,?,?)\\\";\\n        try (Connection conn = connect();\\n             PreparedStatement pstmt = conn.prepareStatement(sql)) {\\n            pstmt.setString(1, note.getTitle());\\n            pstmt.setString(2, note.getContent());\\n            pstmt.setLong(3, System.currentTimeMillis()); // Update lastModified\\n            pstmt.executeUpdate();\\n        } catch (SQLException e) {\\n            System.err.println(\\\"Error saving note: \\\" + e.getMessage());\\n        }\\n    }\\n\\n    // ... (Methods for updating, deleting, and retrieving notes)\\n\\n    private Connection connect() throws SQLException {\\n        return DriverManager.getConnection(\\\"jdbc:sqlite:\\\" + DB_NAME);\\n    }\\n}\\n```\\n\\n**4. Offline Mode Logic:**\\n\\n```java\\npublic class NoteManager {\\n    private DatabaseHelper dbHelper;\\n\\n    public NoteManager() {\\n        dbHelper = new DatabaseHelper();\\n        dbHelper.initializeDatabase();\\n    }\\n\\n    public void createNote(String title, String content) {\\n        Note note = new Note();\\n        note.setTitle(title);\\n        note.setContent(content);\\n        dbHelper.saveNote(note); // Save to local database\\n        // TODO: Queue for synchronization if online\\n    }\\n\\n    // ... (Methods for loading, updating, and deleting notes)\\n\\n    // Synchronization Logic (Basic Example)\\n    public void synchronize() {\\n        if (isNetworkAvailable()) {\\n            // 1. Get locally modified notes (lastModified > lastSyncedTimestamp)\\n            List<Note> notesToSync = dbHelper.getModifiedNotes(); \\n\\n            // 2. Send notes to server (API call)\\n            // ... \\n\\n            // 3. Update local database with server response (if successful)\\n            // ...\\n        }\\n    }\\n\\n    // ... (Helper methods for network availability check)\\n}\\n```\\n\\n**5. Usage:**\\n\\n```java\\nNoteManager noteManager = new NoteManager();\\n\\n// Create a note\\nnoteManager.createNote(\\\"My Note\\\", \\\"This is a sample note.\\\");\\n\\n// ... (Other operations on notes)\\n\\n// Synchronize data when online\\nnoteManager.synchronize();\\n```\\n\\n**Explanation:**\\n\\n1. **Local Database:** SQLite is used for persistent local storage of notes.\\n2. **Database Helper:** Handles all database interactions (create, read, update, delete).\\n3. **NoteManager:** Manages note operations and provides offline mode logic.\\n4. **Synchronization:** A `synchronize()` method handles syncing local changes with the server when online.\\n5. **Timestamp:** The `lastModified` field in the `Note` class helps track modifications for efficient synchronization.\\n\\n**Further Considerations:**\\n\\n* **Robust Synchronization:** Implement conflict resolution strategies for concurrent modifications.\\n* **Error Handling:** Add robust error handling for database and network operations.\\n* **User Interface:** Update the UI to reflect online/offline status and data synchronization.\\n* **Background Tasks:** Use threads or background services for synchronization to avoid blocking the UI.\\n* **Data Optimization:** Consider data compression or other optimization techniques for large datasets.\\n\\nThis code example provides a basic framework for implementing offline mode. You'll need to adapt and expand it based on your application's specific requirements and complexities. \\n\"\n  },\n  {\n    \"feature\": \"Chatbots\",\n    \"description\": \"Act as \\\"helpers\\\" that interact with users through text messages\",\n    \"code\": \"```java\\nimport java.util.HashMap;\\nimport java.util.Map;\\nimport java.util.Scanner;\\n\\npublic class Chatbot {\\n\\n    private String name;\\n    private Map<String, String> responses;\\n\\n    public Chatbot(String name) {\\n        this.name = name;\\n        this.responses = new HashMap<>();\\n        // Populate with some basic responses\\n        this.responses.put(\\\"hello\\\", \\\"Hi there! How can I help you today?\\\");\\n        this.responses.put(\\\"how are you?\\\", \\\"I'm doing well, thank you. How about yourself?\\\");\\n    }\\n\\n    /**\\n     * Adds a new response to the chatbot's knowledge base.\\n     *\\n     * @param question The question or phrase the chatbot should recognize.\\n     * @param answer   The corresponding response the chatbot should provide.\\n     */\\n    public void addResponse(String question, String answer) {\\n        this.responses.put(question.toLowerCase(), answer);\\n    }\\n\\n    /**\\n     * Processes user input and generates a response based on the chatbot's knowledge base.\\n     *\\n     * @param input The user's message.\\n     * @return The chatbot's response.\\n     */\\n    public String processInput(String input) {\\n        String lowerCaseInput = input.toLowerCase();\\n\\n        // Check for exact matches first\\n        if (responses.containsKey(lowerCaseInput)) {\\n            return responses.get(lowerCaseInput);\\n        } \\n\\n        // More sophisticated processing could be added here, like:\\n        // - Keyword matching\\n        // - Natural Language Processing (NLP) techniques\\n        // - Intent recognition\\n\\n        // Default response if no match found\\n        return \\\"I'm not sure I understand. Can you rephrase that?\\\";\\n    }\\n\\n    public String getName() {\\n        return name;\\n    }\\n\\n    public static void main(String[] args) {\\n        Chatbot chatbot = new Chatbot(\\\"HelperBot\\\");\\n\\n        // Add some more responses\\n        chatbot.addResponse(\\\"what is your purpose?\\\", \\\"I am here to assist you with your questions and requests.\\\");\\n        chatbot.addResponse(\\\"goodbye\\\", \\\"Farewell! Have a great day.\\\");\\n\\n        Scanner scanner = new Scanner(System.in);\\n        System.out.println(\\\"You are now chatting with \\\" + chatbot.getName() + \\\".\\\");\\n        \\n        while (true) {\\n            System.out.print(\\\"You: \\\");\\n            String userInput = scanner.nextLine();\\n            if (userInput.equalsIgnoreCase(\\\"exit\\\")) {\\n                break;\\n            }\\n            System.out.println(chatbot.getName() + \\\": \\\" + chatbot.processInput(userInput));\\n        }\\n\\n        scanner.close();\\n    }\\n}\\n```\\n\\n**Explanation and Improvements:**\\n\\n* **Robustness:**\\n    * **Error Handling:** Includes basic error handling, like converting input to lowercase to ensure case-insensitivity. More sophisticated error handling could be added (e.g., handling invalid input types).\\n    * **Clearer Structure:** The code is organized into methods, making it more readable and maintainable.\\n    * **Default Response:**  Provides a default response when the chatbot doesn't understand, guiding the user.\\n\\n* **Efficiency:**\\n    * **HashMap for Responses:**  Uses a `HashMap` to store responses, enabling fast lookups for question-answer pairs, which is more efficient than iterating through a list.\\n\\n* **Optimization:**\\n    * **Basic NLP:** Implements a simple form of Natural Language Processing (NLP) by converting input to lowercase, allowing for case-insensitive matching.\\n    * **Further Optimization:**  The code is structured to easily accommodate more advanced NLP and intent recognition techniques in the `processInput` method.\\n\\n* **Production-Readiness:**\\n    * **Modularity:** The code is modular, allowing you to easily extend the chatbot's functionality (e.g., adding new responses, integrating with messaging platforms).\\n    * **Testability:** The code is structured to be unit testable. You can write tests for the `addResponse` and `processInput` methods to ensure they behave as expected.\\n    * **Scalability:** This basic structure can be scaled to handle more complex interactions and a larger knowledge base. You might consider using databases or external APIs to store and retrieve responses more efficiently as your chatbot grows.\\n\\n**How to Use:**\\n\\n1. **Compile and Run:** Compile and run the code.\\n2. **Interact:**  Type your messages in the console.\\n3. **Exit:**  Type \\\"exit\\\" to end the conversation.\\n\\n**Further Development:**\\n\\n* **Advanced NLP:** Integrate Natural Language Processing (NLP) libraries like Stanford CoreNLP or Google Cloud Natural Language API for more advanced language understanding (e.g., sentiment analysis, entity recognition).\\n* **Intent Recognition:** Implement intent recognition to better understand the user's goals and provide more relevant responses.\\n* **Contextual Awareness:**  Store conversation history to maintain context and provide more meaningful responses.\\n* **Integration:** Integrate the chatbot with messaging platforms like Facebook Messenger, Slack, or WhatsApp.\\n* **Database:** Use a database to store the chatbot's knowledge base for persistence and scalability. \\n\"\n  },\n  {\n    \"feature\": \"Push notifications\",\n    \"description\": \"Alert users of new messages\",\n    \"code\": \"```java\\nimport com.google.auth.oauth2.GoogleCredentials;\\nimport com.google.firebase.FirebaseApp;\\nimport com.google.firebase.FirebaseOptions;\\nimport com.google.firebase.messaging.*;\\nimport org.json.JSONObject;\\n\\nimport java.io.FileInputStream;\\nimport java.io.IOException;\\nimport java.util.HashMap;\\nimport java.util.List;\\nimport java.util.Map;\\n\\npublic class PushNotificationService {\\n\\n    private static final String FIREBASE_CONFIG_PATH = \\\"path/to/your/firebase-config.json\\\"; // Replace with your file path\\n    private static FirebaseMessaging firebaseMessaging;\\n\\n    static {\\n        try {\\n            // Initialize Firebase app with service account credentials\\n            FileInputStream serviceAccount = new FileInputStream(FIREBASE_CONFIG_PATH);\\n            FirebaseOptions options = FirebaseOptions.builder()\\n                    .setCredentials(GoogleCredentials.fromStream(serviceAccount))\\n                    .build();\\n            FirebaseApp.initializeApp(options);\\n\\n            // Get an instance of Firebase Messaging\\n            firebaseMessaging = FirebaseMessaging.getInstance();\\n\\n        } catch (IOException e) {\\n            System.err.println(\\\"Error initializing Firebase: \\\" + e.getMessage());\\n        }\\n    }\\n\\n    /**\\n     * Sends a push notification to a single device.\\n     * \\n     * @param deviceToken The registration token of the device to send the notification to.\\n     * @param title       The title of the notification.\\n     * @param body        The body of the notification.\\n     * @throws FirebaseMessagingException If an error occurs while sending the message.\\n     */\\n    public static void sendNotificationToDevice(String deviceToken, String title, String body) throws FirebaseMessagingException {\\n        Message message = Message.builder()\\n                .setWebpushConfig(WebpushConfig.builder().putHeader(\\\"ttl\\\", \\\"300\\\").build()) // Optional: Set TTL for web push\\n                .setAndroidConfig(AndroidConfig.builder()\\n                        .setPriority(AndroidConfig.Priority.HIGH)\\n                        .setNotification(AndroidNotification.builder()\\n                                .setTitle(title)\\n                                .setBody(body)\\n                                .build())\\n                        .build())\\n                .setToken(deviceToken)\\n                .build();\\n\\n        String response = firebaseMessaging.send(message);\\n        System.out.println(\\\"Successfully sent message: \\\" + response);\\n    }\\n\\n    /**\\n     * Sends a push notification to multiple devices.\\n     * \\n     * @param deviceTokens The registration tokens of the devices to send the notification to.\\n     * @param title       The title of the notification.\\n     * @param body        The body of the notification.\\n     * @throws FirebaseMessagingException If an error occurs while sending the message.\\n     */\\n    public static void sendNotificationToMultipleDevices(List<String> deviceTokens, String title, String body)\\n            throws FirebaseMessagingException {\\n\\n        // Create a MulticastMessage object\\n        MulticastMessage message = MulticastMessage.builder()\\n                .setWebpushConfig(WebpushConfig.builder().putHeader(\\\"ttl\\\", \\\"300\\\").build()) // Optional: Set TTL for web push\\n                .setAndroidConfig(AndroidConfig.builder()\\n                        .setPriority(AndroidConfig.Priority.HIGH)\\n                        .setNotification(AndroidNotification.builder()\\n                                .setTitle(title)\\n                                .setBody(body)\\n                                .build())\\n                        .build())\\n                .addAllTokens(deviceTokens)\\n                .build();\\n\\n        // Send the message\\n        BatchResponse response = firebaseMessaging.sendMulticast(message);\\n\\n        // Process the response\\n        System.out.println(response.getSuccessCount() + \\\" messages were sent successfully\\\");\\n        List<SendResponse> responses = response.getResponses();\\n        for (int i = 0; i < responses.size(); i++) {\\n            SendResponse singleResponse = responses.get(i);\\n            if (!singleResponse.isSuccessful()) {\\n                // Handle error\\n                System.err.println(\\\"Error sending message to token \\\" + deviceTokens.get(i) + \\\": \\\"\\n                        + singleResponse.getException().getMessage());\\n            }\\n        }\\n    }\\n\\n    /**\\n     * Sends a data message that can be handled by the client app.\\n     * \\n     * @param deviceToken The registration token of the device to send the message to.\\n     * @param data        A map containing the data to send.\\n     * @throws FirebaseMessagingException If an error occurs while sending the message.\\n     */\\n    public static void sendDataMessage(String deviceToken, Map<String, String> data)\\n            throws FirebaseMessagingException {\\n        Message message = Message.builder()\\n                .putAllData(data)\\n                .setToken(deviceToken)\\n                .build();\\n\\n        String response = firebaseMessaging.send(message);\\n        System.out.println(\\\"Successfully sent message: \\\" + response);\\n    }\\n\\n    // Example Usage:\\n    public static void main(String[] args) throws FirebaseMessagingException {\\n\\n        // Replace with actual device token\\n        String deviceToken = \\\"YOUR_DEVICE_TOKEN\\\";\\n\\n        // Send a simple notification\\n        sendNotificationToDevice(deviceToken, \\\"New Message\\\", \\\"You have a new message!\\\");\\n\\n        // Send data message with custom key-value pairs\\n        Map<String, String> data = new HashMap<>();\\n        data.put(\\\"sender\\\", \\\"John Doe\\\");\\n        data.put(\\\"message\\\", \\\"Hello from Java!\\\");\\n        sendDataMessage(deviceToken, data);\\n    }\\n}\\n```\\n\\n**Explanation:**\\n\\n1. **Dependencies:**\\n   - Ensure you have the Firebase Admin SDK for Java added to your project. You can include it using Maven or Gradle.\\n\\n2. **Initialization:**\\n   - The code initializes the Firebase app using the service account credentials from your `firebase-config.json` file. \\n   - It then obtains an instance of `FirebaseMessaging` to interact with the FCM service.\\n\\n3. **Sending Notifications:**\\n   - The code provides three functions:\\n     - `sendNotificationToDevice`: Sends a notification message to a single device token.\\n     - `sendNotificationToMultipleDevices`: Sends a notification to multiple device tokens using `MulticastMessage`. It efficiently sends messages and handles errors for individual devices.\\n     - `sendDataMessage`: Sends a data message containing custom key-value pairs. This allows for greater flexibility, as the client app can define how to handle the data.\\n\\n4. **Message Structure:**\\n   - The code demonstrates how to build notification messages with:\\n     - Title and body for display on the device.\\n     - Optional configurations for Android (like priority) and Webpush (like TTL).\\n     - Data payloads for custom data.\\n\\n5. **Error Handling:**\\n   - The code includes error handling using `try-catch` blocks to catch `FirebaseMessagingException` and prints error messages to the console.\\n   - For `sendNotificationToMultipleDevices`, it iterates through individual responses in `BatchResponse` to identify and handle errors for specific devices.\\n\\n6. **Example Usage:**\\n   - The `main` method provides a basic example of how to use the provided functions to send notifications and data messages.\\n\\n**Key Points:**\\n\\n- **Service Account:**  Use a service account to authenticate with Firebase from your server. This is more secure than using API keys.\\n- **Device Tokens:**  These tokens uniquely identify a device and are required to target notifications. You'll need a mechanism to collect and store these tokens.\\n- **Efficiency:**  Using `MulticastMessage` to send to multiple devices is more efficient than sending individual messages in a loop.\\n- **Data Messages:** Sending data messages allows for more flexibility, as the client app can handle the data and display custom notifications based on its logic.\\n\\n**To use this code:**\\n\\n1. Replace `\\\"path/to/your/firebase-config.json\\\"` with the actual path to your Firebase configuration file.\\n2. Replace `\\\"YOUR_DEVICE_TOKEN\\\"` with the actual device token you want to send the notification to.\\n3. Implement the necessary logic to handle:\\n   - Obtaining device tokens from your users.\\n   - Storing and managing device tokens securely.\\n   - Triggering the notification sending functions based on your application's events.\\n\\nThis code provides a robust and efficient foundation for building a production-ready push notification feature in your Java application using Firebase. \\n\"\n  },\n  {\n    \"feature\": \"Multi-platform support\",\n    \"description\": \"Expands the app's reach and accessibility by making it available on web browsers\",\n    \"code\": \"It's impossible to provide specific Java code for a \\\"Multi-platform support feature\\\" and web browser accessibility without knowing the context of your existing application. \\n\\n**Here's a breakdown of the challenges and common approaches:**\\n\\n**1. Existing Application Architecture:**\\n\\n* **Desktop Application (Swing/JavaFX/AWT):**  Porting a desktop application to the web requires significant architectural changes. You can't simply \\\"convert\\\" the code.\\n* **Backend Application (Spring Boot, Jakarta EE, etc.):**  Backend applications already serve web browsers through APIs. You might be referring to building a frontend (web UI) to interact with your backend.\\n\\n**2. Web Browser Compatibility:**\\n\\n* **JavaScript Ecosystem:** Web browsers understand JavaScript, HTML, and CSS. You'll likely need to use frameworks like:\\n    * **React, Angular, Vue.js (Front-end Frameworks):** These help build dynamic, interactive web UIs.\\n    * **Spring WebFlux (Reactive Programming):**  Suitable for building reactive web applications that interact with a backend.\\n* **Transpiling Java to JavaScript:** Tools like GWT (Google Web Toolkit) or JSweet allow you to write code in Java that gets translated to JavaScript, but these have limitations and might not be suitable for complex applications.\\n\\n**3. Communication with the Backend:**\\n\\n* **RESTful APIs:**  The standard way to allow a web frontend to communicate with your backend. You'll need to define endpoints that your frontend can use to fetch and send data.\\n* **WebSockets:**  For real-time communication, like in chat applications or collaborative tools.\\n\\n**Example: Building a Simple Web Frontend for an Existing Spring Boot API**\\n\\nLet's assume you have a Spring Boot application exposing a REST API. Here's how you might create a basic web frontend using React to interact with it:\\n\\n**1. Set up a React Project:**\\n\\n   ```bash\\n   npx create-react-app my-web-frontend\\n   cd my-web-frontend\\n   ```\\n\\n**2. Install Fetch or Axios for API Calls:**\\n\\n   ```bash\\n   npm install axios \\n   ```\\n\\n**3. Create a React Component (e.g., `App.js`)**\\n\\n   ```javascript\\n   import React, { useState, useEffect } from 'react';\\n   import axios from 'axios';\\n\\n   function App() {\\n     const [data, setData] = useState([]);\\n\\n     useEffect(() => {\\n       axios.get('/api/your-endpoint') \\n         .then(response => {\\n           setData(response.data);\\n         })\\n         .catch(error => {\\n           console.error(\\\"Error fetching data:\\\", error);\\n         });\\n     }, []); \\n\\n     return (\\n       <div>\\n         <h1>Data from Spring Boot API:</h1>\\n         <ul>\\n           {data.map(item => (\\n             <li key={item.id}>{item.name}</li>\\n           ))}\\n         </ul>\\n       </div>\\n     );\\n   }\\n\\n   export default App;\\n   ```\\n\\n**4. Build and Deploy:**\\n\\n   Build your React application:\\n\\n   ```bash\\n   npm run build\\n   ```\\n\\n   Deploy the `build` directory to a web server (e.g., Nginx, Apache) or a cloud platform that can serve static files.\\n\\n**Important Considerations:**\\n\\n* **Security:** Implement proper authentication and authorization for your web application, especially if it interacts with sensitive data.\\n* **Scalability:** Design your architecture with scalability in mind. Consider load balancers, caching mechanisms, and cloud-native principles if needed.\\n* **User Experience:** The web offers different interaction paradigms than desktop applications. Carefully design your UI/UX for a seamless web experience.\\n\\nThis example provides a basic structure for building a web frontend that interacts with your existing backend. The specific implementation will vary greatly depending on your application's needs and complexity. \\n\"\n  },\n  {\n    \"feature\": \"Payment SDK integration\",\n    \"description\": \"Allows users to send and receive payments directly within the app\",\n    \"code\": \"## Payment SDK Integration - Java\\n\\nThis example demonstrates a robust, efficient, and optimized Java code implementation for a Payment SDK integration feature, allowing users to send and receive payments directly within an app. This example uses a fictional Payment Gateway SDK for demonstration purposes. Replace it with your chosen provider's SDK.\\n\\n**Important:** This example focuses on core functionalities and security considerations. You should adapt and extend it based on your specific requirements and the chosen Payment Gateway SDK.\\n\\n**1. Project Setup:**\\n\\n* **Add Dependency:** Include the Payment Gateway SDK dependency in your project's `pom.xml` (Maven) or `build.gradle` (Gradle) file. For example, if using \\\"FictionalPay\\\" SDK:\\n\\n```xml\\n<dependency>\\n  <groupId>com.fictionalpay</groupId>\\n  <artifactId>fictionalpay-sdk</artifactId>\\n  <version>1.0.0</version>\\n</dependency>\\n```\\n\\n**2. Payment Service Class:**\\n\\n```java\\nimport com.fictionalpay.FictionalPayClient;\\nimport com.fictionalpay.model.PaymentRequest;\\nimport com.fictionalpay.model.PaymentResponse;\\nimport com.fictionalpay.exception.FictionalPayException;\\n\\npublic class PaymentService {\\n\\n    private final FictionalPayClient fictionalPayClient;\\n\\n    public PaymentService(String apiKey, String apiSecret) {\\n        this.fictionalPayClient = new FictionalPayClient(apiKey, apiSecret);\\n    }\\n\\n    public PaymentResponse sendPayment(double amount, String currency, String sourceToken, String destinationAccountId) \\n            throws FictionalPayException {\\n        // Validate input parameters (e.g., amount > 0, valid currency, etc.)\\n        // ...\\n\\n        PaymentRequest request = new PaymentRequest.Builder()\\n                .amount(amount)\\n                .currency(currency)\\n                .sourceToken(sourceToken) // User's payment source token (e.g., card token)\\n                .destinationAccountId(destinationAccountId)\\n                .build();\\n\\n        // Execute the payment request through the SDK\\n        PaymentResponse response = fictionalPayClient.sendPayment(request);\\n\\n        // Handle different response codes (e.g., success, pending, failure)\\n        // ...\\n        if (response.getStatusCode() == 200) {\\n            // Payment successful, update your internal systems\\n            // ...\\n        } else {\\n            // Handle payment failures, potentially retry or inform the user\\n            // ...\\n        }\\n        return response;\\n    }\\n\\n    public PaymentResponse receivePayment(double amount, String currency, String destinationAccountId) \\n            throws FictionalPayException {\\n        // Validate input parameters\\n        // ...\\n\\n        PaymentRequest request = new PaymentRequest.Builder()\\n                .amount(amount)\\n                .currency(currency)\\n                .destinationAccountId(destinationAccountId) \\n                .build();\\n\\n        // Execute the payment request for receiving funds\\n        PaymentResponse response = fictionalPayClient.receivePayment(request);\\n\\n        // Handle the response, update internal systems, and handle errors\\n        // ...\\n        return response;\\n    }\\n}\\n```\\n\\n**3. Integrating with your Application:**\\n\\n```java\\npublic class App {\\n    public static void main(String[] args) {\\n        // Initialize PaymentService with your API credentials\\n        PaymentService paymentService = new PaymentService(\\\"your_api_key\\\", \\\"your_api_secret\\\");\\n\\n        try {\\n            // Example: Send Payment\\n            PaymentResponse sendResponse = paymentService.sendPayment(\\n                    10.00, \\\"USD\\\", \\\"user_card_token\\\", \\\"recipient_account_id\\\");\\n            System.out.println(\\\"Send Payment Response: \\\" + sendResponse);\\n\\n            // Example: Receive Payment\\n            PaymentResponse receiveResponse = paymentService.receivePayment(\\n                    25.50, \\\"EUR\\\", \\\"your_account_id\\\");\\n            System.out.println(\\\"Receive Payment Response: \\\" + receiveResponse);\\n\\n        } catch (FictionalPayException e) {\\n            // Handle payment exceptions, log errors, and inform the user\\n            System.err.println(\\\"Payment Error: \\\" + e.getMessage());\\n            // ... more detailed error handling\\n        }\\n    }\\n}\\n```\\n\\n**Security Considerations:**\\n\\n* **Never store API keys directly in your code.** Use environment variables or a secure configuration management system.\\n* **Implement robust input validation** to prevent vulnerabilities like SQL injection and cross-site scripting (XSS).\\n* **Handle sensitive data (e.g., API keys, payment tokens) with extreme care.** Avoid logging such information.\\n* **Use HTTPS for all communication** with the Payment Gateway API.\\n* **Implement proper error handling and logging** to identify and resolve issues quickly.\\n\\n**Additional Notes:**\\n\\n* This code is a simplified example. Real-world implementations require more comprehensive error handling, logging, and security measures.\\n* Consult the documentation of your chosen Payment Gateway SDK for specific implementation details and API endpoints.\\n* Thoroughly test all payment functionalities before deploying to production.\\n* Consider using a sandbox environment during development and testing.\"\n  },\n  {\n    \"feature\": \"VoIP technology\",\n    \"description\": \"Enables voice and video calling features within the app\",\n    \"code\": \"I can't provide you with a full Java code implementation for a production-ready VoIP feature. Building a robust VoIP system is incredibly complex and requires deep knowledge of networking, audio/video codecs, signaling protocols, and real-time communication constraints. \\n\\nHowever, I can give you a structured breakdown and point you to the essential libraries and concepts you'll need to get started:\\n\\n**1. Choose a VoIP Library/Framework:**\\n\\nDon't reinvent the wheel. Leverage existing libraries to handle the low-level complexities:\\n\\n* **WebRTC (Web Real-Time Communication):**  The industry standard for browser-based communication. Use a Java library like **Jitsi** ([https://jitsi.org/](https://jitsi.org/)), **Kurento** ([https://www.kurento.org/](https://www.kurento.org/)), or **OpenVidu** ([https://openvidu.io/](https://openvidu.io/)) to integrate WebRTC into your Java application.\\n* **SIP (Session Initiation Protocol):** A well-established protocol for VoIP. Libraries like **Jain SIP** ([https://jsip.java.net/](https://jsip.java.net/)) and **MJSIP** ([https://www.mjsip.org/](https://www.mjsip.org/)) can be used for SIP signaling and call management.\\n* **Other Libraries:** Consider **pjsip** (cross-platform multimedia library) or **Linphone SDK** (mobile-focused).\\n\\n**2. Architecture (Example using WebRTC and Jitsi):**\\n\\n```java\\n// Simplified example using Jitsi Meet API\\nimport org.jitsi.meet.sdk.JitsiMeet;\\nimport org.jitsi.meet.sdk.JitsiMeetConferenceOptions;\\nimport org.jitsi.meet.sdk.JitsiMeetUserInfo;\\n\\n// ... (Other imports and class definition)\\n\\npublic class VoIPCallManager {\\n\\n    private JitsiMeetView view; // View to display the call\\n\\n    public void startCall(String roomName) {\\n        // 1. Jitsi Meet configuration\\n        JitsiMeetConferenceOptions options = new JitsiMeetConferenceOptions.Builder()\\n                .setRoom(roomName)\\n                .setAudioMuted(false) // Start with audio unmuted\\n                .setVideoMuted(true) // Start with video muted\\n                // ... other options (server URL, user info, etc.)\\n                .build();\\n\\n        // 2. Start the Jitsi Meet conference\\n        view = new JitsiMeetView(this); // Assuming 'this' is an Activity or Context\\n        view.join(options);\\n    }\\n\\n    // ... (Other methods for call control: mute/unmute, video on/off, hang up) \\n}\\n```\\n\\n**3. Key Components:**\\n\\n* **Signaling:** \\n    * Handle call setup, negotiation, and termination.\\n    * Use SIP (with a library like Jain SIP) or WebRTC data channels.\\n* **Audio/Video Input/Output:**\\n    * Access microphones and cameras using Java's media APIs or platform-specific libraries.\\n* **Codecs:**\\n    * Encode and decode audio/video streams. \\n    * Common codecs: Opus (audio), VP8/VP9, H.264 (video).\\n* **Network Transport:**\\n    * Use UDP for real-time media streaming.\\n    * Implement NAT traversal techniques (STUN/TURN) to handle firewalls and routers.\\n* **User Interface:**\\n    * Design UI elements for call control, video display, participant lists, etc.\\n\\n**4. Optimization and Production Readiness:**\\n\\n* **Network Jitter Buffer:** Smooth out network fluctuations.\\n* **Echo Cancellation and Noise Suppression:** Improve audio quality.\\n* **Bandwidth Adaptation:** Adjust video quality dynamically based on network conditions.\\n* **Security:** Implement encryption (DTLS-SRTP for WebRTC) to protect communication.\\n* **Scalability:** Design your system for potential growth in users and calls.\\n* **Monitoring and Logging:** Track call quality metrics and debug issues effectively.\\n\\n**Important Considerations:**\\n\\n* **Thorough Testing:** Test across different networks, devices, and operating systems to ensure reliability.\\n* **Server Infrastructure:** For larger deployments, you'll need servers to handle signaling, media relaying (if using TURN), and potentially recording/transcribing.\\n* **Legal and Privacy:** Research regulations related to VoIP and data security in your target regions.\\n\\n**Remember:** Building a production-ready VoIP feature is a significant undertaking. Start with a clear understanding of your requirements and leverage existing libraries and frameworks to streamline the development process.\\n\"\n  }\n]""";

    final features = decodeFeatures(jsonString);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: FeatureWidget(data: [],),
      home: NotificationCallbackForGmails(title: "sender <drive2nd@gmail.com>", body: "hey there man! meet me up at the coming thursday, 3 pm okay?"),
      // home: DashBoard(),
      // home: Test2(),
      // home: Bleh(),
      // home: FeaturesWidget(app_name: "messenger", features: features,),
    );
  }
}

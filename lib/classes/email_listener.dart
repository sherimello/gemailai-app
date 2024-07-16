// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:googleapis/gmail/v1.dart' as gmail;
// import 'auth.dart';
// import 'notification_service.dart';
//
// class EmailListener {
//   final GmailAuth _auth = GmailAuth();
//   late gmail.GmailApi _gmailApi;
//
//   Future<void> initialize() async {
//     final httpClient = await _auth.getHttpClient();
//     _gmailApi = gmail.GmailApi(httpClient);
//   }
//
//   Future<void> listenForEmails() async {
//     final response = await _gmailApi.users.messages.list('me', q: 'is:unread');
//     if (response.messages != null && response.messages!.isNotEmpty) {
//       final message = response.messages!.first;
//       final messageDetails = await _gmailApi.users.messages.get('me', message.id!);
//       final payload = messageDetails.payload;
//       final subjectHeader = payload?.headers?.firstWhere((h) => h.name == 'Subject').value;
//       final body = utf8.decode(base64.decode(payload!.body!.data!));
//       NotificationService().showNotification(subjectHeader ?? 'New Email', body);
//     }
//   }
// }

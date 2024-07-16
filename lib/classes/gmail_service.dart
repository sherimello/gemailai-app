import 'package:googleapis/gmail/v1.dart';
import 'auth.dart';

Future<List<Message>> getUnreadEmails() async {
  final client = await getAuthenticatedClient();
  final gmailApi = GmailApi(client);

  final messages = await gmailApi.users.messages.list('me', q: 'is:unread');
  return messages.messages ?? [];
}

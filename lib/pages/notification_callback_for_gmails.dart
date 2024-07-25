import 'package:flutter/material.dart';

class NotificationCallbackForGmails extends StatefulWidget {

  final String title, body;

  const NotificationCallbackForGmails({super.key, required this.title, required this.body});

  @override
  State<NotificationCallbackForGmails> createState() => _NotificationCallbackForGmailsState();
}

class _NotificationCallbackForGmailsState extends State<NotificationCallbackForGmails> {
  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Center(
          child: Text(
            widget.body
          )
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:gemailai/classes/shared_preferences_helper.dart';
import 'package:gemailai/pages/dashboard.dart';
import 'package:gemailai/widgets/sparkling_dot.dart';
import 'package:gemailai/widgets/text_field.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NotificationCallbackForGmails extends StatefulWidget {
  final String title, body;

  const NotificationCallbackForGmails(
      {super.key, required this.title, required this.body});

  @override
  State<NotificationCallbackForGmails> createState() =>
      _NotificationCallbackForGmailsState();
}

class _NotificationCallbackForGmailsState
    extends State<NotificationCallbackForGmails> with TickerProviderStateMixin {
  TextEditingController tecEmailSender = TextEditingController(),
      tecGeneratedMail = TextEditingController();
  late AnimationController _controller;
  String scheduleMessage = "";
  bool isMailGenerated = false;
  bool mailSuccessfullySent = true;
  bool sendingMail = false;
  late DateTime startDate;
  String errorMessage = "",
      _response = "",
      appPassword = "",
      userMail = "",
      generatedSubject = "",
      displayMessage = "\ndetecting schedules\nand generating response",
      generatedBody = "";
  bool errorEncountered = true;
  bool mailGenerated = false;
  bool generating = false;
  bool shouldSchedule = false;
  bool showPostSchedulePrompt = false;
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();
  late Timer t;

  DateTime getDateTimeFromString(String s) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final dateTime = dateFormat.parse(s);

    return dateTime;
  }

  DateTime getEndDateTime() {
    final newDateTime = startDate.add(const Duration(hours: 1));

    return newDateTime;
  }

  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();

  initProcessingAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: false);
  }

  initUserMailInfo() async {
    await sharedPreferencesHelper
        .saveStringToSharedPreferences("appPassword", "qvtq elkc kiyf uxds")
        .whenComplete(() async {
      appPassword = (await sharedPreferencesHelper
          .getStringFromSharedPreferences("appPassword"))!;
    });
    await sharedPreferencesHelper
        .saveStringToSharedPreferences("userMail", "s.r.1769karega@gmail.com")
        .whenComplete(() async {
      userMail = (await sharedPreferencesHelper
          .getStringFromSharedPreferences("userMail"))!;
    });
  }

  Future<void> sendMail(String subject, String body, String fromEmail,
      String toEmail, String appPassword) async {
    setState(() {
      sendingMail = true;
    });

    final url = Uri.parse(
        'http://192.168.0.236:5000/send?subject=$subject&body=$body&from_email=$fromEmail&to_email=$toEmail&app_password=$appPassword');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      // setState(() {
      //   mailSuccessfullySent = true;
      //   sendingMail = false;
      //
      //   final jsonResponse = json.decode(response.body);
      //   _response = jsonResponse['message'] ?? 'No output key in response';
      //
      //   errorMessage = _response;
      //   errorEncountered = true;
      //   mailGenerated = false;
      //   generating = false;
      // });

      if (shouldSchedule) {
        displayMessage = "mail delivered!";
        t = Timer(
            const Duration(seconds: 1),
            () => setState(() {
                  displayMessage += "\nredirecting to Google Calendar";
                }));
        t = Timer(const Duration(seconds: 1), () {
          createGoogleCalendarTask();
          setState(() {
            showPostSchedulePrompt = true;
          });
        });
      }
      // else {
        redirectToDashboard();
      // }
    } else {
      setState(() {
        _response =
            'Failed to load response: ${response.statusCode}: ${response.reasonPhrase}';
        errorMessage = _response;
        errorEncountered = true;
        mailGenerated = false;
        generating = false;
        sendingMail = false;
      });
      // debugPrint detailed error message
      debugPrint('Error ${response.statusCode}: ${response.reasonPhrase}');
      debugPrint('Response body: ${response.body}');
    }
    debugPrint(_response);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initUserMailInfo();
    generateMail(widget.body);
    checkMeeting(widget.body);
    initProcessingAnimation();
  }

  Future<void> createGoogleCalendarTask() async {
    final Event event = Event(
      title: 'Event title',
      description: 'Event description',
      location: 'Event location',
      startDate: startDate,
      endDate: getEndDateTime(),
      iosParams: const IOSParams(
        reminder: Duration(/* Ex. hours:1 */),
        // on iOS, you can set alarm notification after your event.
        url:
            'https://www.example.com', // on iOS, you can set url to your event.
      ),
      androidParams: const AndroidParams(
        emailInvites: [
          "drive2nd@gmail.com",
          "shahriarr.inan@gmail.com"
        ], // on Android, you can add invite emails to your event.
      ),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  String? getSenderMail() {
    RegExp regExp = RegExp(r'<([^<>]+)?>');
    Iterable<Match> matches = regExp.allMatches(widget.title);
    String? extractedString;
    for (Match match in matches) {
      extractedString = match.group(1);
      debugPrint(extractedString); // debugPrints "world" and "test"
    }
    return extractedString;
  }

  generateMail(String mail) async {
    final url =
        Uri.parse('http://192.168.0.213:5000/process_input/?user_input=$mail');
    final client = http.Client();
    final request = http.Request('POST', url);
    final response = await client.send(request);

    if (response.statusCode == 307) {
      // 307 Temporary Redirect
      final redirectLocation = response.headers['location'];
      if (redirectLocation != null) {
        final redirectUrl = Uri.parse(redirectLocation);
        final redirectRequest = http.Request('POST', redirectUrl)
          ..bodyFields = {'user_input': mail};
        final redirectResponse = await client.send(redirectRequest);
        if (redirectResponse.statusCode == 200) {
          final jsonData =
              jsonDecode(await redirectResponse.stream.bytesToString());
          final body =
              jsonData['body']; // Extract the "body" part from the JSON data
          setState(() {
            generatedSubject = jsonData['subject'];
            generatedBody = jsonData['body'];
            tecEmailSender.text = getSenderMail() ?? ''; // Update the UI
            tecGeneratedMail.text = body; // Update the UI
            isMailGenerated = true;
          });
          debugPrint(body); // debugPrint the extracted body
        } else {
          debugPrint('Error: ${redirectResponse.statusCode}');
        }
      } else {
        debugPrint('Error: No redirect location found');
      }
    } else if (response.statusCode == 200) {
      final jsonData = jsonDecode(await response.stream.bytesToString());
      final body =
          jsonData['body']; // Extract the "body" part from the JSON data
      setState(() {
        tecEmailSender.text = getSenderMail() ?? '';
        tecGeneratedMail.text = body;
        isMailGenerated = true;
      });
      debugPrint(body); // debugPrint the extracted body
    } else {
      debugPrint('Error: ${response.statusCode}');
    }
  }

  Future<void> checkMeeting(String emailContent) async {
    final url = Uri.parse('http://192.168.0.213:5000/check_meeting/');
    final requestBody = jsonEncode({'content': emailContent});

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      scheduleMessage = "";
      final jsonData = jsonDecode(response.body);
      final meetingRequested = jsonData['meeting_requested'];
      final proposedTimes = jsonData['proposed_times'];

      if (meetingRequested) {
        debugPrint('Meeting requested!');
        scheduleMessage += '⬤   Meeting requested!\n';
        if (proposedTimes != null) {
          getAllProposedTimes(proposedTimes);
          debugPrint('Proposed times: $proposedTimes');
          scheduleMessage += '⬤   Proposed times: $proposedTimes\n';
        } else {
          debugPrint('No specific time proposed.');
          scheduleMessage += '⬤   No specific time proposed.\n';
        }
      } else {
        debugPrint('No meeting requested.');
        scheduleMessage += '⬤   No meeting requested.\n';
      }
    } else {
      debugPrint('Error: ${response.statusCode}');
    }
    setState(() {
      scheduleMessage = scheduleMessage;
    });
  }

  sendMailWithoutScheduling() {
    setState(() {
      displayMessage = "sending mail to:\n${tecEmailSender.text}";
    });
    sendMail(generatedSubject, generatedBody, userMail,
        tecEmailSender.text, appPassword);
    _fabKey.currentState?.toggle();
  }

  sendScheduledMail() {
    setState(() {
      shouldSchedule = true;
      displayMessage = "sending mail to:\n${tecEmailSender.text}";
    });
    sendMail(generatedSubject, generatedBody, userMail,
        tecEmailSender.text, appPassword);
    _fabKey.currentState?.toggle();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size,
        appBarHeight = AppBar().preferredSize.height;

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 555),
        opacity: !isMailGenerated || sendingMail ? 0 : 1,
        child: ExpandableFab(
          key: _fabKey,
          overlayStyle: const ExpandableFabOverlayStyle(blur: 7),
          childrenAnimation: ExpandableFabAnimation.none,
          distance: 65,
          openButtonBuilder: DefaultFloatingActionButtonBuilder(
            child: const Icon(Icons.send),
            fabSize: ExpandableFabSize.regular,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
          ),
          closeButtonBuilder: DefaultFloatingActionButtonBuilder(
            child: const Icon(Icons.close),
            fabSize: ExpandableFabSize.regular,
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            // shape: const RoundedRectangleBorder(),
          ),
          children: [
            FloatingActionButton.extended(
              backgroundColor: Colors.purple,
              heroTag: const Text(
                "schedule & send",
                style: TextStyle(color: Colors.black),
              ),
              icon: const Icon(
                Icons.schedule_send,
                color: Colors.white,
              ),
              onPressed: () {
                sendScheduledMail();
              },
              label: const Text(
                "schedule & send",
                style: TextStyle(color: Colors.white),
              ),
            ),
            FloatingActionButton.extended(
              backgroundColor: Colors.purple,
              heroTag: const Text(
                "send mail",
                style: TextStyle(color: Colors.black),
              ),
              icon: const Icon(
                Icons.outgoing_mail,
                color: Colors.white,
              ),
              onPressed: () {
                sendMailWithoutScheduling();
              },
              label: const Text(
                "send mail",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 555),
            opacity: !isMailGenerated || sendingMail ? 1 : 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      width: size.width,
                      height: size.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: const [0.0, 1.0],
                          colors: [
                            Colors.purple.withOpacity(0.5),
                            Colors.purple.withOpacity(0.0),
                          ],
                          transform: GradientRotation(
                              _controller.value * 2.0 * 3.141592653589793),
                        ),
                      ),
                    );
                  },
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      width: size.width,
                      height: size.height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          end: Alignment.topLeft,
                          begin: Alignment.bottomRight,
                          stops: const [0.0, 1.0],
                          colors: [
                            Colors.cyan.withOpacity(0.5),
                            Colors.cyan.withOpacity(0.0),
                          ],
                          transform: GradientRotation(
                              _controller.value * 2.0 * 3.141592653589793),
                        ),
                      ),
                    );
                  },
                ),
                Opacity(
                    opacity: .5,
                    child: HalftoneBackground(
                      dotSize: 3,
                      spacing: 7,
                    )),
                Positioned(
                    left: -size.width * .25,
                    top: 0,
                    child: SizedBox(
                        width: size.width * .65,
                        height: size.width * .65,
                        child: HalftoneBackground(
                          dotSize: 3,
                          spacing: 7,
                        ))),
                Positioned(
                    bottom: -size.width * .425,
                    right: (size.width * .163),
                    child: SizedBox(
                        width: size.width * .85,
                        height: size.width * .85,
                        child: HalftoneBackground(
                          dotSize: 3,
                          spacing: 7,
                        ))),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: size.width * .057,
                      height: size.width * .057,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: appBarHeight / 2,),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 555),
                      style: TextStyle(
                          height: 0,
                          color: Colors.white,
                          fontFamily: "SF-Pro",
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * .055),
                      child: Text(
                        displayMessage,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: appBarHeight / 2,),
                    Padding(
                      padding: EdgeInsets.all(showPostSchedulePrompt ? 7.0 : 0),
                      child: InkWell(
                        onTap: () {
                          print("samalama");
                          redirectToDashboard();
                        },
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 555),
                            curve: Curves.linearToEaseOut,
                            height: showPostSchedulePrompt ? appBarHeight : 0,
                            width: showPostSchedulePrompt ? size.width * .51 : 0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.purple),
                            child: Center(
                              child: Text.rich(TextSpan(children: [
                                WidgetSpan(
                                    child: Icon(
                                      Icons.done_all,
                                      color: Colors.white,
                                      size: size.width * .049,
                                    ),
                                    alignment: PlaceholderAlignment.middle),
                                TextSpan(
                                    text: "  done",
                                    style: TextStyle(
                                        height: 0,
                                        fontFamily: "SF-pro",
                                        fontSize: size.width * 0.039,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))
                              ])),
                            )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => sendMailWithoutScheduling,
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 555),
                          curve: Curves.linearToEaseOut,
                          height: showPostSchedulePrompt ? appBarHeight : 0,
                          width: showPostSchedulePrompt ? size.width * .51 : 0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white),
                          child: Center(
                            child: Text.rich(TextSpan(children: [
                              WidgetSpan(
                                  child: Icon(
                                    Icons.restore_rounded,
                                    color: Colors.black,
                                    size: size.width * .049,
                                  ),
                                  alignment: PlaceholderAlignment.middle),
                              TextSpan(
                                  text: "  reschedule",
                                  style: TextStyle(
                                      height: 0,
                                      fontFamily: "SF-pro",
                                      fontSize: size.width * 0.039,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black))
                            ])),
                          )),
                    ),

                    Padding(
                      padding: EdgeInsets.all(showPostSchedulePrompt ? 7.0 : 0),
                      child: GestureDetector(
                        onTap: () => sendScheduledMail,
                        child: AnimatedContainer(
                            duration: const Duration(milliseconds: 555),
                            curve: Curves.linearToEaseOut,
                            height: showPostSchedulePrompt ? appBarHeight : 0,
                            width: showPostSchedulePrompt ? size.width * .51 : 0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white),
                            child: Center(
                              child: Text.rich(TextSpan(children: [
                                WidgetSpan(
                                    child: Icon(
                                      Icons.repeat,
                                      color: Colors.black,
                                      size: size.width * .049,
                                    ),
                                    alignment: PlaceholderAlignment.middle),
                                TextSpan(
                                    text: "  regenerate mail",
                                    style: TextStyle(
                                        height: 0,
                                        fontFamily: "SF-pro",
                                        fontSize: size.width * 0.039,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black))
                              ])),
                            )),
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 555),
              opacity: isMailGenerated && !sendingMail ? 1 : 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "stella",
                          style: TextStyle(
                            fontFamily: "SF-Pro",
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: size.width * .075,
                          ),
                        ),
                        SizedBox(
                          height: appBarHeight / 2,
                        ),
                        Text(
                          scheduleMessage,
                          style: TextStyle(
                            fontFamily: "SF-Pro",
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic,
                            color: Colors.white54,
                            fontSize: size.width * .035,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            createGoogleCalendarTask();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.white),
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text.rich(TextSpan(children: [
                                WidgetSpan(
                                    child: Icon(
                                      Icons.schedule,
                                      color: Colors.black,
                                    ),
                                    alignment: PlaceholderAlignment.middle),
                                TextSpan(
                                    text: "  schedule  ",
                                    style: TextStyle(
                                        fontFamily: "SF-Pro",
                                        fontWeight: FontWeight.bold))
                              ])),
                            ),
                          ),
                        ),
                        CustomTextField(
                            fieldName: "sender's mail address:",
                            hint: "abc@mail.com",
                            lines: 1,
                            textEditingController: tecEmailSender),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextField(
                            fieldName: "generated mail:",
                            hint: "hello bro...",
                            lines: 5,
                            textEditingController: tecGeneratedMail),
                        const SizedBox(
                          height: 17,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getAllProposedTimes(proposedTimes) {
    // Use regular expression to extract the date-time strings
    RegExp regExp = RegExp(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}');
    Iterable<Match> matches = regExp.allMatches(proposedTimes.toString());

    // Convert the matches to a list of strings
    List<String> result = matches.map((match) => match.group(0)!).toList();

    setState(() {
      startDate = getDateTimeFromString(result.first);
    });
  }

  void redirectToDashboard() {
    print("in redirect");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (builder) => const DashBoard()));
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }

  @override
  void close() {
    _client.close();
  }
}

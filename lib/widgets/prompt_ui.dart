import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gemailai/widgets/text_field.dart';
import 'package:http/http.dart' as http;

class PromptUI extends StatefulWidget {
  final bool startButtonClicked;

  const PromptUI({super.key, required this.startButtonClicked});

  @override
  State<PromptUI> createState() => _PromptUIState();
}

class _PromptUIState extends State<PromptUI> with TickerProviderStateMixin {
  bool generating = false, mailGenerated = false;
  double radius = 100;
  late Timer timer;
  late AnimationController _controller;
  String _response = "";
  final TextEditingController _textEditingControllerSender =
          TextEditingController(),
      _textEditingControllerReceiver = TextEditingController(),
      _textEditingControllerPrompt = TextEditingController(),
      _textEditingControllerSubject = TextEditingController(),
      _textEditingControllerBody = TextEditingController();

  Future<void> generateMail(String userInput) async {
    final url = Uri.parse(
        'https://gemailai.onrender.com/process_input?user_input=$userInput');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      setState(() {
        // Assuming the API returns a JSON object
        final jsonResponse = json.decode(response.body);
        _response = jsonResponse['subject'] ??
            'No output key in response'; // Adjust this line based on your JSON structure

        mailGenerated = true;
        _textEditingControllerSubject.text = jsonResponse['subject'];
        _textEditingControllerBody.text = jsonResponse['body'];
      });
    } else {
      setState(() {
        _response = 'Failed to load response: ${response.statusCode}';
      });
    }
    print(_response);
  }

  Future<void> sendMail(String subject, body, from_email, to_email, app_password) async {
    final url = Uri.parse(
        'https://gemailai.onrender.com/send?subject=$subject&body=$body&from_email=$from_email&to_email=$to_email&app_password=$app_password');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      setState(() {
        // Assuming the API returns a JSON object
        final jsonResponse = json.decode(response.body);
        _response = jsonResponse['message'] ??
            'No output key in response';
      });
    } else {
      setState(() {
        _response = 'Failed to load response: ${response.statusCode}';
      });
    }
    print(_response);
  }

  initProcessingAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Stack(
      children: [
        AnimatedOpacity(
          duration: const Duration(seconds: 1),
          opacity: mailGenerated
              ? 0
              : widget.startButtonClicked
                  ? 1
                  : 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(19.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Gemailai",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "SF-Pro",
                          fontSize: size.width * .081),
                    ),
                    SizedBox(
                      height: AppBar().preferredSize.height * .5,
                    ),
                    CustomTextField(
                        fieldName: "sender's email",
                        hint: "your.email@hmail.com",
                        lines: 1,
                        textEditingController: _textEditingControllerSender),
                    SizedBox(
                      height: AppBar().preferredSize.height * .25,
                    ),
                    CustomTextField(
                        fieldName: "receiver's email",
                        hint: "their.email@hmail.com",
                        lines: 1,
                        textEditingController: _textEditingControllerReceiver),
                    SizedBox(
                      height: AppBar().preferredSize.height * .25,
                    ),
                    CustomTextField(
                        fieldName: "email prompt",
                        hint: "a love letter to my arabian muslim waifu who...",
                        lines: 3,
                        textEditingController: _textEditingControllerPrompt),
                  ],
                ),
              ),
            ),
          ),
        ),
        generating && !mailGenerated
            ? AnimatedBuilder(
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
              )
            : const SizedBox(),
        generating && !mailGenerated
            ? AnimatedBuilder(
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
              )
            : const SizedBox(),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 900),
          curve: Curves.fastEaseInToSlowEaseOut,
          bottom: mailGenerated
              ? 19
              : generating
                  ? (size.height - AppBar().preferredSize.height) / 2
                  : 0,
          left: mailGenerated
              ? 19
              : generating
                  ? (size.width - AppBar().preferredSize.height) / 2
                  : 19,
          right: mailGenerated
              ? 19
              : generating
                  ? (size.width - AppBar().preferredSize.height) / 2
                  : 19,
          top: mailGenerated
              ? 19 + MediaQuery.of(context).padding.top
              : generating
                  ? (size.height - AppBar().preferredSize.height) / 2
                  : (size.height - AppBar().preferredSize.height),
          child: GestureDetector(
            onTap: () {
              setState(() {
                print(_textEditingControllerPrompt.text);
                generateMail(_textEditingControllerPrompt.text);
                generating
                    ? {
                        _controller.dispose(),
                        generating = false,
                      }
                    : {
                        initProcessingAnimation(),
                        generating = true,
                      };
              });
            },
            child: AnimatedOpacity(
              duration: const Duration(seconds: 1),
              opacity: widget.startButtonClicked ? 1 : 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: AppBar().preferredSize.height,
                // width: generating ? AppBar().preferredSize.height : size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(mailGenerated
                        ? 41
                        : generating
                            ? 100
                            : 17),
                    color:
                        mailGenerated ? const Color(0xff000000) : Colors.white),
                child: mailGenerated
                    ? Padding(
                        padding: const EdgeInsets.all(19.0),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomTextField(
                                    fieldName: "subject",
                                    hint: "",
                                    lines: 1,
                                    textEditingController:
                                        _textEditingControllerSubject),
                                SizedBox(
                                  height: AppBar().preferredSize.height * .25,
                                ),
                                CustomTextField(
                                    fieldName: "body",
                                    hint: "",
                                    lines: 10,
                                    textEditingController:
                                        _textEditingControllerBody),
                              ],
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: AnimatedContainer(
                                duration: const Duration(seconds: 1),
                                height: AppBar().preferredSize.height,
                                // width: generating ? AppBar().preferredSize.height : size.width,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(17),
                                    color: Colors.white),
                                child: Center(
                                  child: Text.rich(TextSpan(children: [
                                    const WidgetSpan(
                                        child: Icon(Icons.send,
                                            color: Colors.black),
                                        alignment: PlaceholderAlignment.middle),
                                    TextSpan(
                                      text: "  send",
                                      style: TextStyle(
                                          height: 0,
                                          fontWeight: FontWeight.bold,
                                          fontSize: size.width * .045,
                                          fontFamily: "SF-Pro",
                                          color: Colors.black),
                                    )
                                  ])),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : Center(
                        child: Text.rich(TextSpan(children: [
                          WidgetSpan(
                              child: generating
                                  ? const CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                  : Icon(Icons.auto_fix_high,
                                      color: generating
                                          ? Colors.white
                                          : Colors.black),
                              alignment: PlaceholderAlignment.middle),
                          TextSpan(
                            text: generating ? "" : "  generate",
                            style: TextStyle(
                                height: 0,
                                fontWeight: FontWeight.bold,
                                fontSize: size.width * .045,
                                fontFamily: "SF-Pro",
                                color:
                                    generating ? Colors.white : Colors.black),
                          )
                        ])),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gemailai/classes/shared_preferences_helper.dart';
import 'package:gemailai/widgets/prompt_ui.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  bool startButtonClicked = false;
  double radius = 100;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper().saveBoolToSharedPreferences("isOldUser", true);
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(seconds: 1),
                      height: AppBar().preferredSize.height * .25,
                    ),
                    Image.asset(
                      "assets/images/app_icon1.png",
                      height: size.width * .11,
                    ),
                    SizedBox(
                      height: AppBar().preferredSize.height * .5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(21.0),
                      child: Text.rich(
                        TextSpan(
                          children: const [
                            TextSpan(
                              text: "Welcome to",
                            ),
                            TextSpan(
                                text: "\nGemailai.",
                                style: TextStyle(color: Colors.deepPurpleAccent)),
                            TextSpan(
                              text: "\nLet's start making\nsome emails.",
                            ),
                          ],
                          style: TextStyle(
                              height: 0,
                              fontFamily: "SF-Pro",
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: size.width * .081),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: AppBar().preferredSize.height,
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: startButtonClicked
                ? () {}
                : () async {
                    setState(() {
                      startButtonClicked = true;
                    });
                    timer = Timer(const Duration(milliseconds: 900), () {
                      setState(() {
                        radius = 0;
                      });
                    });
                  },
            child: AnimatedContainer(
              curve: Curves.linearToEaseOut,
              duration: const Duration(seconds: 1),
              height: startButtonClicked ? size.height : size.width * .19,
              width: startButtonClicked ? size.width : size.width * .19,
              decoration: BoxDecoration(
                color: startButtonClicked
                    ? const Color(0xff000000)
                    : Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Stack(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: startButtonClicked ? 0 : 1,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(size.width * .05),
                        child: Icon(
                          Icons.arrow_forward,
                          size: size.width * .085,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  AbsorbPointer(
                    absorbing: !startButtonClicked,
                    child: SizedBox(
                        height: size.height,
                        child: PromptUI(startButtonClicked: startButtonClicked)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

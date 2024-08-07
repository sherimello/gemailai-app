import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter_inset_shadow/flutter_inset_shadow.dart';
import 'package:gemailai/classes/shared_preferences_helper.dart';
import 'package:gemailai/pages/dashboard.dart';
import 'package:gemailai/pages/gmail_assistant_success_confirmation.dart';
import 'package:gemailai/pages/home.dart';
import 'package:gemailai/pages/test2.dart';
import 'package:gemailai/widgets/prompt_ui.dart';
import 'package:gemailai/widgets/text_field.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  String APP_PASS_LINK = "https://myaccount.google.com/apppasswords";
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation1;
  bool signInClicked = false,
      signedIn = false,
      proceed = false,
      shouldLoadPromptPage = false,
      isOldUser = false,
      loadPromptUI = false,
      startIntervalOngoing = true,
      triggerBorderRadius = false;

  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

  TextEditingController textEditingControllerAppPassword =
      TextEditingController();

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth auth = FirebaseAuth.instance;

  Timer timer = Timer(const Duration(seconds: 0), () {}),
      timerForBorderRadiusTriggerInit =
          Timer(const Duration(seconds: 0), () {}),
      timerForStartAwaitTrigger = Timer(const Duration(seconds: 0), () {}),
      timerForAwaitingOldUserTrigger = Timer(const Duration(seconds: 0), () {});

  double textOpacity = 0;
  Timer t = Timer(Duration.zero, (){});

  triggerTextOpacity() {
    t = Timer(const Duration(milliseconds: 500), () =>
        setState(() {
          textOpacity = 1;
        }));
  }

  signOut() async {
    try {
      // Sign out from Google
      await googleSignIn.signOut();

      // Sign out from Firebase
      await auth.signOut();

      print('User signed out successfully');
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  Future<void> _openLink(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      rethrow;
    }
  }

  checkUserState() async {
    timerForStartAwaitTrigger = Timer(const Duration(seconds: 3), () async {
      // await sharedPreferencesHelper.getKeyExistingApproval("isOldUser") == true
      //     ? isOldUser = (await sharedPreferencesHelper
      //         .getBoolFromSharedPreferences("isOldUser"))!
      //     : isOldUser = false;

      setState(() {
        startIntervalOngoing = false;
        // isOldUser = isOldUser;
      });

      // if (isOldUser) {
      //   timerForAwaitingOldUserTrigger =
      //       Timer(const Duration(seconds: 2), () {
      //         setState(() {
      //           shouldLoadPromptPage = true;
      //         });
      //         Future.delayed(const Duration(milliseconds: 755), () {
      //           setState((){
      //             triggerBorderRadius = true;
      //           });
      //         });
      //       });
      // }
    });
  }

  @override
  void initState() {
    super.initState();
    triggerTextOpacity();
    signOut();

    checkUserState();

    _controller = AnimationController(
      animationBehavior: AnimationBehavior.preserve,
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _colorAnimation1 = ColorTween(
      begin: Colors.white,
      end: Colors.black,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    textEditingControllerAppPassword.dispose();
    timer.cancel();
    timerForBorderRadiusTriggerInit.cancel();
    timerForStartAwaitTrigger.cancel();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // Function to sign in with Google using Firebase
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

        // Authenticate with Firebase using the credential
        final UserCredential authResult =
            await auth.signInWithCredential(credential);

        // User object from Firebase
        final User? user = authResult.user;

        sharedPreferencesHelper.saveStringToSharedPreferences("user_mail", user!.email!);

        return user;
      } else {
        setState(() {
          signInClicked = !signInClicked;
        });
        // User canceled the sign-in
        print('Google sign-in aborted.');
        return null;
      }
    } catch (error) {
      print('Error signing in with Google: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: !shouldLoadPromptPage,
        child: Stack(
          children: [
            AnimatedOpacity(
              // curve: Curves.linearToEaseOut,
              duration: const Duration(milliseconds: 1000),
              opacity: signInClicked ? 1 : 0,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 555),
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(-10, -10),
                          blurRadius: 60,
                          spreadRadius: 3,
                          blurStyle: BlurStyle.inner,
                          color: _colorAnimation1.value!,
                          inset: true,
                        ),
                        BoxShadow(
                          offset: const Offset(10, 10),
                          blurRadius: 60,
                          blurStyle: BlurStyle.inner,
                          spreadRadius: 3,
                          color: _colorAnimation1.value!,
                          inset: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: AnimatedOpacity(
                    curve: Curves.linearToEaseOut,
                    duration: const Duration(milliseconds: 1000),
                    opacity: signInClicked ? 0 : textOpacity,
                    child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(children: [
                          TextSpan(
                            text: "hello there,",
                            style: TextStyle(
                                fontFamily: "SF-Pro",
                                fontWeight: FontWeight.bold,
                                color: Colors.purpleAccent,
                                fontSize: size.width * .13),
                          ),
                          TextSpan(
                            text: "\nlet\'s get you all set up...",
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
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(seconds: 1),
              curve: Curves.linearToEaseOut,
              bottom: !shouldLoadPromptPage && (isOldUser || startIntervalOngoing)
                  ? (size.height - AppBar().preferredSize.height) / 2
                  : shouldLoadPromptPage
                      ? 0
                      : proceed
                          ? (size.height - AppBar().preferredSize.height * 3) /
                              2
                          : signedIn
                              ? (size.height - AppBar().preferredSize.height) /
                                  6
                              : signInClicked
                                  ? (size.height -
                                          AppBar().preferredSize.height) /
                                      2
                                  : 19,
              left: !shouldLoadPromptPage && (isOldUser || startIntervalOngoing)
                  ? (size.width - AppBar().preferredSize.height) / 2
                  : shouldLoadPromptPage
                      ? 0
                      : proceed
                          ? (size.width - AppBar().preferredSize.height * 3) / 2
                          : signedIn
                              ? 19
                              : signInClicked
                                  ? (size.width -
                                          AppBar().preferredSize.height) /
                                      2
                                  : 19,
              right: !shouldLoadPromptPage && (isOldUser || startIntervalOngoing)
                  ? (size.width - AppBar().preferredSize.height) / 2
                  : shouldLoadPromptPage
                      ? 0
                      : proceed
                          ? (size.width - AppBar().preferredSize.height * 3) / 2
                          : signedIn
                              ? 19
                              : signInClicked
                                  ? (size.width -
                                          AppBar().preferredSize.height) /
                                      2
                                  : 19,
              child: GestureDetector(
                onTap: signedIn || isOldUser || shouldLoadPromptPage || startIntervalOngoing
                    ? () {}
                    : () {
                        setState(() {
                          signInClicked = !signInClicked;
                        });
                        signInWithGoogle().then((user) {
                          if (user != null) {
                            // Sign in successful
                            print('User signed in: ${user.displayName}');
                            setState(() {
                              signedIn = true;
                            });
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => const Home()));
                          } else {
                            // Sign in failed
                            print('Sign in failed');
                          }
                        });
                      },
                child: AnimatedContainer(
                  curve: Curves.linearToEaseOut,
                  duration: const Duration(seconds: 1),
                  height: shouldLoadPromptPage
                      ? size.height
                      : proceed
                          ? AppBar().preferredSize.height * 3
                          : signedIn
                              ? size.height -
                                  ((size.height -
                                          AppBar().preferredSize.height) /
                                      3)
                              : AppBar().preferredSize.height,
                  width: proceed
                      ? AppBar().preferredSize.height * 3
                      : signInClicked
                          ? AppBar().preferredSize.height
                          : size.width - 38,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(!shouldLoadPromptPage && (isOldUser || startIntervalOngoing)
                            ? 100
                            : triggerBorderRadius
                                ? 0
                                : proceed
                                    ? 1000
                                    : signedIn
                                        ? 55
                                        : signInClicked
                                            ? 100
                                            : 31),
                    color: startIntervalOngoing || proceed
                        ? Colors.transparent
                        : signInClicked ? Colors.black : Colors.white,
                    boxShadow: const [],
                  ),
                  child: Stack(
                    children: [
                      proceed
                          ? AnimatedOpacity(
                              curve: Curves.linearToEaseOut,
                              opacity: proceed ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Center(
                                child:
                                    Image.asset("assets/images/done_icon.gif"),
                              ),
                            )
                          : const SizedBox(),
                      AnimatedOpacity(
                        curve: Curves.linearToEaseOut,
                        opacity: proceed ? 0 : 1,
                        duration: const Duration(milliseconds: 255),
                        child: AbsorbPointer(
                          absorbing: proceed,
                          child: Center(
                            child: signedIn
                                ? SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(19.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                    text: "click ",
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(.57),
                                                      fontSize:
                                                          size.width * .051,
                                                      fontFamily: "SF-Pro",
                                                    )),
                                                TextSpan(
                                                    text: "generate ",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          size.width * .051,
                                                      fontFamily: "SF-Pro",
                                                    )),
                                                TextSpan(
                                                    text:
                                                        "to sign in and generate a password. once done, copy it, paste it below, and click proceed.",
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(.57),
                                                      fontSize:
                                                          size.width * .051,
                                                      fontFamily: "SF-Pro",
                                                    )),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(
                                            height: 11,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _openLink(APP_PASS_LINK);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(11),
                                                  color: Colors.white),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(7.0),
                                                child: Text(" generate ",
                                                    style: TextStyle(
                                                        height: 0,
                                                        color: Colors.black,
                                                        fontSize:
                                                            size.width * .041,
                                                        fontFamily: "SF-Pro",
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 19,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 19),
                                            child: CustomTextField(
                                                fieldName: "app password",
                                                hint: "xx-xxx-xxxx-xxxxx",
                                                lines: 1,
                                                textEditingController:
                                                    textEditingControllerAppPassword),
                                          ),
                                          const SizedBox(
                                            height: 19,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 19),
                                            child: GestureDetector(
                                              onTap: () async {
                                                SharedPreferencesHelper()
                                                    .saveStringToSharedPreferences(
                                                        "app_password",
                                                        textEditingControllerAppPassword
                                                            .text);
                                                // Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => const Home()));
                                                setState(() {
                                                  proceed = true;
                                                });
                                                var authClient = await (googleSignIn.authenticatedClient()).then((v) {
                                                  timer = Timer(
                                                      const Duration(seconds: 1),
                                                          () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => Test2()))
                                                  );
                                                });

                                                    // () => setState(() {
                                                    //       shouldLoadPromptPage =
                                                    //           true;
                                                    //     }));
                                                timerForBorderRadiusTriggerInit =
                                                    Timer(
                                                        const Duration(
                                                            milliseconds: 1500),
                                                        () => setState(() {
                                                              triggerBorderRadius =
                                                                  true;
                                                            }));
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 500),
                                                height: AppBar()
                                                    .preferredSize
                                                    .height,
                                                // width: generating ? AppBar().preferredSize.height : size.width,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            17),
                                                    color: Colors.white),
                                                child: Center(
                                                  child: Text(
                                                    "proceed",
                                                    style: TextStyle(
                                                        height: 0,
                                                        color: Colors.black,
                                                        fontSize:
                                                            size.width * .055,
                                                        fontFamily: "SF-Pro",
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : (isOldUser || signInClicked) & !shouldLoadPromptPage
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Text.rich(TextSpan(children: [
                                        TextSpan(
                                          text: "sign in with Google",
                                          style: TextStyle(
                                              height: 0,
                                              fontWeight: FontWeight.bold,
                                              fontSize: size.width * .045,
                                              fontFamily: "SF-Pro",
                                              color: startIntervalOngoing ||
                                                      isOldUser
                                                  ? Colors.transparent
                                                  : Colors.black),
                                        )
                                      ])),
                          ),
                        ),
                      ),
                      shouldLoadPromptPage
                          ? AnimatedOpacity(
                              duration: const Duration(milliseconds: 555),
                              opacity: shouldLoadPromptPage ? 1 : 0,
                              child: isOldUser ? SizedBox(
                                  height: size.height,
                                  width: size.width,
                                  child: const PromptUI(startButtonClicked: true)) : const GmailAssistantSuccessConfirmation())
                          : const SizedBox()
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

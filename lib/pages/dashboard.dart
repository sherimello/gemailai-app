import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemailai/classes/shared_preferences_helper.dart';
import 'package:gemailai/pages/code_generation_ui.dart';
import 'package:gemailai/pages/data_visualization.dart';
import 'package:gemailai/pages/presentation_generation.dart';
import 'package:gemailai/pages/sign_in.dart';
import 'package:gemailai/widgets/feature_card.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {

  bool isMailAssistantActive = false;
  SharedPreferencesHelper sharedPreferencesHelper = SharedPreferencesHelper();

  checkActiveStatus() async{
    if(await sharedPreferencesHelper.getKeyExistingApproval("isMailAssistantActive")) {
      isMailAssistantActive = (await sharedPreferencesHelper.getBoolFromSharedPreferences("isMailAssistantActive"))!;
      setState(() {
        isMailAssistantActive = isMailAssistantActive;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkActiveStatus();

  }


  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size,
    appBarHeight = AppBar().preferredSize.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: Text(
                  "Stella",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: "SF-Pro",
                      fontSize: size.width * .081),
                ),
              ),
              // SizedBox(height: appBarHeight,),
              Row(
                children: [
                  FeatureCard(icon: Icons.mail, tag: "\nmail\nassistant", w: const SignIn(), isActive: isMailAssistantActive,),
                  const FeatureCard(icon: Icons.code, tag: "\ngenerate\ncodes", w: CodeGenerationUi(), isActive: false,),
                ],
              ),
              const Row(
                children: [
                  FeatureCard(icon: Icons.query_stats, tag: "\nvisualize\ndata", w: DataVisualization(), isActive: false,),
                  FeatureCard(icon: Icons.co_present, tag: "\ngenerate\npresentation", w: PresentationGeneration(), isActive: false,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

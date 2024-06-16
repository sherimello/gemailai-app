import 'package:flutter/material.dart';
import 'package:gemailai/widgets/prompt_ui.dart';

class ErrorPromptUi extends StatefulWidget {
  final String errorMessage;
  final Function(bool b) f;

  const ErrorPromptUi({super.key, required this.errorMessage, required this.f});

  @override
  State<ErrorPromptUi> createState() => _ErrorPromptUiState();
}

class _ErrorPromptUiState extends State<ErrorPromptUi> {
  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Icon(Icons.error,
                    size: size.width * .087,
                  ),
                  Text(" error", style: TextStyle(color: Colors.black,
                      fontFamily: "SF-Pro",
                      fontSize: size.width * .077,
                      fontWeight: FontWeight.bold,
                      height: 0
                  ))
                ],
              ),
              SizedBox(
                height: 11,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 19.0),
                child: Text(widget.errorMessage + "\nsuggested action: \"check the receiver's mail for any typo and/or check your internet connection.", style: TextStyle(color: Colors.black,
                fontSize: size.width * .051
                ),
                textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: AppBar().preferredSize.height / 2,
              ),
              GestureDetector(
                onTap: () {
                  // widget.f(false);
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(11),
                      color: Colors.black),
                  child: Padding(
                    padding:
                    const EdgeInsets.all(11.0),
                    child: Text(" got it! ",
                        style: TextStyle(
                            height: 0,
                            color: Colors.white,
                            fontSize:
                            size.width * .041,
                            fontFamily: "SF-Pro",
                            fontWeight:
                            FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

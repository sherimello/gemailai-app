import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';

import '../widgets/processing_screen.dart';

class PresentationGeneration extends StatefulWidget {
  const PresentationGeneration({super.key});

  @override
  State<PresentationGeneration> createState() => _PresentationGenerationState();
}

class _PresentationGenerationState extends State<PresentationGeneration> {
  bool processing = false, done = false;
  String? selectedPdfPath;
  String buttonText = "  upload a pdf file";
  Timer t = Timer(Duration.zero, () {});

  Future<void> _pickPdf() async {
    print("opening file selector");
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        selectedPdfPath = result.files.single.path;
        processing = true;
      });
      t = Timer(const Duration(seconds: 5), () {
        setState(() {
          buttonText = "  download pptx file";
          processing = false;
          done = true;
        });
      });
      print("Selected PDF Path: $selectedPdfPath");
    } else {
      // User canceled the picker
      print("No file selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size,
        appBarHeight = AppBar().preferredSize.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Visibility(visible: processing, child: const ProcessingScreen()),
          Visibility(
            visible: !processing,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Text(
                      "GemAide",
                      style: TextStyle(
                          fontFamily: "SF-Pro",
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * .077,
                          color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(31.0),
                    child: Text(
                      "start generating powerpoint presentations from your documents",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "SF-Pro",
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * .067,
                          color: Colors.white.withOpacity(0.75)),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(21.0),
                      child: GestureDetector(
                        onTap: () {
                          !done
                              ? _pickPdf()
                              : setState(() {
                                  buttonText = "  file downloaded!";
                                });
                        },
                        child: Container(
                          width: size.width,
                          height: appBarHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text.rich(TextSpan(children: [
                              WidgetSpan(
                                  child: Icon(
                                    done ? Icons.download : Icons.upload_file,
                                    color: Colors.purple,
                                  ),
                                  alignment: PlaceholderAlignment.middle),
                              TextSpan(
                                  text: buttonText,
                                  style: const TextStyle(
                                    fontFamily: "SF-Pro",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ))
                            ])),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

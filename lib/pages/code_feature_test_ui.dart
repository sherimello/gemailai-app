import 'dart:convert';

import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:markdown/markdown.dart' hide Text;

class FeaturesWidget extends StatefulWidget {
  final List<Feature> features;
  final String app_name;

  FeaturesWidget({required this.features, required this.app_name});

  @override
  State<FeaturesWidget> createState() => _FeaturesWidgetState();
}

class _FeaturesWidgetState extends State<FeaturesWidget> {
  late List<CodeController> _codeControllers;

  String extractAfterLastCodeBlock(String input) {
    final RegExp regex = RegExp(r'```', dotAll: true);
    final matches = regex.allMatches(input);

    if (matches.length >= 2) {
      final lastMatch = matches.last;
      return input.substring(lastMatch.end).trim();
    }

    return '';
  }

  String extractCodeBlock(String input) {
    final RegExp regex = RegExp(r'```(.*?)```', dotAll: true);
    final match = regex.firstMatch(input);
    return match != null ? match.group(1)!.trim() : '';
  }

  String extractCodeBlockWithoutFirstLine(String input) {
    final RegExp regex = RegExp(r'```(.*?)```', dotAll: true);
    final match = regex.firstMatch(input);

    if (match != null) {
      String codeBlock = match.group(1)!.trim();
      List<String> lines = codeBlock.split('\n');
      if (lines.length > 1) {
        // Remove the first line and join the rest
        return lines.sublist(1).join('\n').trim();
      } else {
        // If there's only one line or none, return an empty string
        return '';
      }
    }

    return '';
  }

  getCodeLanguage(String codeBlock) {
    List<String> lines = codeBlock.split('\n');
    if (lines.isNotEmpty) {
      return lines.first.trim();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the _codeControllers list with the correct length
    _codeControllers = List<CodeController>.generate(
      widget.features.length,
      (index) => CodeController(
          text: extractCodeBlockWithoutFirstLine(widget.features[index].code),
          language:
              getCodeLanguage(extractCodeBlock(widget.features[index].code)) ==
                      "java"
                  ? java
                  : getCodeLanguage(
                              extractCodeBlock(widget.features[index].code)) ==
                          "python"
                      ? python
                      : cpp
          // theme: monokaiSublimeTheme,
          ),
    );
  }

  @override
  void dispose() {
    // Dispose of each CodeController
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView.builder(
        itemCount: widget.features.length,
        itemBuilder: (context, index) {
          final feature = widget.features[index];
          // print(extractAfterLastCodeBlock(feature.code));
          return Padding(
            padding: const EdgeInsets.all(11.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                index == 0 ? Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Text.rich(
                      textAlign: TextAlign.start,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${widget.app_name} app",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: "SF-Pro",
                              fontSize: size.width * .067
                          ),
                        ),
                        TextSpan(
                          text: "\ns o u r c e   c o d e :",
                          style: TextStyle(
                              color: Colors.white,
                              // fontWeight: FontWeight.bold,
                              fontFamily: "SF-Pro",
                              // fontStyle: FontStyle.italic,
                              fontSize: size.width * .047
                          ),
                        ),
                      ]
                    )
                  ),
                ) : const SizedBox(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11.0),
                  child: Container(
                    width: size.width,
                    height: size.height * .77,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(41), color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(17.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(41),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(17),
                                child: Text.rich(
                                  textAlign: TextAlign.center,
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Feature: ${feature.feature}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "SF-Pro",
                                            fontSize: size.width * .045),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(41),
                                  child:
                                      CodeField(
                                          // expands: true,
                                          textStyle: TextStyle(
                                            fontSize: size.width * .035,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "SF-Pro"
                                          ),
                                          controller: _codeControllers[index])),
                              SizedBox(
                                height: size.height * .5,
                                child: Markdown(
                                  selectable: true,
                                    shrinkWrap: true,
                                    data: extractAfterLastCodeBlock(feature.code),),
                              )
                              // SelectableText(markdownToHtml(extractAfterLastCodeBlock(feature.code)))
                              // Text('Description: ${feature.description}'),
                              // Text('Code: ${feature.code}'),
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
        },
      ),
    );
  }
}

class Feature {
  String feature;
  String description;
  String code;

  Feature(
      {required this.feature, required this.description, required this.code});

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      feature: json['feature'],
      description: json['description'],
      code: json['code'],
    );
  }
}

List<Feature> decodeFeatures(String jsonString) {
  final jsonData = jsonDecode(jsonString);
  final List<Feature> features = (jsonData as List)
      .map((item) => Feature.fromJson(item as Map<String, dynamic>))
      .toList();
  return features;
}

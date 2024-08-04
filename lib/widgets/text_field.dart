import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String fieldName, hint;
  final int lines;
  final TextEditingController textEditingController;
  const CustomTextField({super.key, required this.fieldName, required this.hint, required this.lines, required this.textEditingController});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return ClipRRect(
      borderRadius: BorderRadius.circular(17),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "\n${widget.fieldName}",
            style: TextStyle(
              fontFamily: "SF-Pro",
              fontSize: size.width * .035,
              color: Colors.white
            ),
            ),
            const SizedBox(
              height: 9,
            ),
            TextField(
              controller: widget.textEditingController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.15), // Set opacity here
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(.35),
                  fontFamily: "SF-Pro",
                  // fontStyle: FontStyle.italic,
                  fontSize: size.width * .037,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21.0),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: widget.lines > 1 ?  TextInputType.multiline :TextInputType.emailAddress,
              maxLines: widget.lines, // Set the maximum lines
              minLines: widget.lines, // Set the minimum lines
              style: TextStyle(
                color: Colors.white,
                fontFamily: "SF-Pro",
                fontSize: size.width * .037
              ),
            ),
          ],
        ),
      ),
    );
  }
}

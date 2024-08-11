import 'package:flutter/material.dart';
import 'package:gemailai/widgets/feature_card_background.dart';
import 'package:gemailai/widgets/sparkling_dot.dart';

class FeatureCard extends StatefulWidget {

  final IconData icon;
  final String tag;
  final Widget w;
  final bool isActive;

  const FeatureCard({super.key, required this.icon, required this.tag, required this.w, required this.isActive});

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {

  @override
  Widget build(BuildContext context) {

    var size =MediaQuery.of(context).size;

    return Flexible(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (builder) => widget.w));
          },
          child: Container(
            width: size.width,
            height: size.width * .5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(41),
                color: Colors.white.withOpacity(.15)
            ),
            child: FeatureCardBackground(icon: widget.icon, tag: widget.tag, isActive: widget.isActive,),
          ),
        ),
      ),
    );
  }
}

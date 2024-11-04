import 'package:flutter/material.dart';

class RoundedContainer extends StatefulWidget {
  final double width;
  final BoxConstraints constraints;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color backgroundcolor;
  final bool boxshadow;
  final Widget child;

  const RoundedContainer({
    Key? key,
    required this.width,
    required this.constraints,
    required this.margin,
    required this.padding,
    this.backgroundcolor = Colors.white,
    this.boxshadow = false,
    required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoundedContainerState();
}

class _RoundedContainerState extends State<RoundedContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
      width: widget.width,
      constraints: widget.constraints,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        boxShadow: (widget.boxshadow)
          ? [BoxShadow(blurRadius: 8.0, spreadRadius: 0.0, color: Colors.black.withOpacity(.16))]
          : [],
        color: widget.backgroundcolor,
      ),
    );
  }
}

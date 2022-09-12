import 'package:flutter/material.dart';

class GC {
  static const String sTitle = '8 Queens Performance Benchmark';
}

class RoundedContainer extends StatefulWidget {
  final Widget child;
  final double width;
  final BoxConstraints constraints;
  final EdgeInsets margin;
  final EdgeInsets padding;

  const RoundedContainer(
      {Key? key,
      required this.child,
      required this.width,
      required this.constraints,
      required this.margin,
      required this.padding})
      : super(key: key);

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
        boxShadow: [
          BoxShadow(blurRadius: 8.0, spreadRadius: 0.0, color: Colors.black.withOpacity(.16))
        ],
        color: Colors.white,
      ),
    );
  }
}

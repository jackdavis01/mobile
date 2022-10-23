import 'package:flutter/material.dart';
import 'package:renderer_switcher/renderer_switcher.dart';

class GC {
  static const String sTitle = '8 Queens Performance Benchmark';
  static const List<String> lsWebRenderers = ['Auto', 'HTML', 'CanvasKit'];
  static WebRenderer wrSwitch = WebRenderer.auto;
}

class RoundedContainer extends StatefulWidget {
  final double width;
  final BoxConstraints constraints;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final Color backgroundcolor;
  final Widget child;

  const RoundedContainer({
    Key? key,
    required this.width,
    required this.constraints,
    required this.margin,
    required this.padding,
    this.backgroundcolor = Colors.white,
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
        boxShadow: [
          BoxShadow(blurRadius: 8.0, spreadRadius: 0.0, color: Colors.black.withOpacity(.16))
        ],
        color: widget.backgroundcolor,
      ),
    );
  }
}

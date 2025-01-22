import 'package:flutter/material.dart';

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final double offsetX;
  final double offsetY;

  CustomFloatingActionButtonLocation(this.offsetX, this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX = scaffoldGeometry.scaffoldSize.width - scaffoldGeometry.floatingActionButtonSize.width - 16.0 + offsetX;
    final double fabY = scaffoldGeometry.scaffoldSize.height - scaffoldGeometry.floatingActionButtonSize.height - 16.0 + offsetY;
    return Offset(fabX, fabY);
  }
}

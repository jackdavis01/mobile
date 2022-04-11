import 'package:flutter/material.dart';

//---- ChessBox ----

class ChessBox extends StatefulWidget {
  final Color backGroundColor;
  final Widget wInside;
  final double dLeft;
  final double dTop;
  final double dWidth;
  final double dHeight;

  const ChessBox(
      {Key? key,
      required this.backGroundColor,
      required this.wInside,
      required this.dLeft,
      required this.dTop,
      required this.dWidth,
      required this.dHeight})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChessBoxState();
}

class _ChessBoxState extends State<ChessBox> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.dLeft,
        top: widget.dTop,
        child: Container(
          width: widget.dWidth,
          height: widget.dHeight,
          decoration: BoxDecoration(
            color: widget.backGroundColor,
          ),
          child: Center(
            child: widget.wInside,
          ),
        ));
  }
}

//---- ChessTableRow ----

class ChessTableRow extends StatefulWidget {
  final Widget wQueen;
  final int iWInside;
  final double dLeft;
  final double dTop;
  final double dChessBoxFullSize;
  final bool bBrightFirst;

  const ChessTableRow(
      {Key? key,
      required this.wQueen,
      required this.iWInside,
      required this.dLeft,
      required this.dTop,
      required this.dChessBoxFullSize,
      required this.bBrightFirst})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChessTableRowState();
}

class _ChessTableRowState extends State<ChessTableRow> {
  @override
  Widget build(BuildContext context) {
    double dChessBoxFullSize = widget.dChessBoxFullSize;
    double dChessBoxSize = dChessBoxFullSize * 0.92;
    bool bBrightFirst = widget.bBrightFirst;
    Widget wQueen = Transform.scale(scale: dChessBoxSize / 40, child: widget.wQueen);
    return Stack(
      children: [
        ChessBox(
            backGroundColor: Colors.brown.withAlpha((bBrightFirst) ? 32 : 96),
            wInside: (1 == widget.iWInside) ? wQueen : const SizedBox.shrink(),
            dLeft: widget.dLeft,
            dTop: widget.dTop,
            dWidth: dChessBoxSize,
            dHeight: dChessBoxSize),
        ChessBox(
            backGroundColor: Colors.brown.withAlpha((bBrightFirst) ? 96 : 32),
            wInside: (2 == widget.iWInside) ? wQueen : const SizedBox.shrink(),
            dLeft: widget.dLeft + dChessBoxFullSize,
            dTop: widget.dTop,
            dWidth: dChessBoxSize,
            dHeight: dChessBoxSize),
        ChessBox(
            backGroundColor: Colors.brown.withAlpha((bBrightFirst) ? 32 : 96),
            wInside: (3 == widget.iWInside) ? wQueen : const SizedBox.shrink(),
            dLeft: widget.dLeft + 2 * dChessBoxFullSize,
            dTop: widget.dTop,
            dWidth: dChessBoxSize,
            dHeight: dChessBoxSize),
        ChessBox(
            backGroundColor: Colors.brown.withAlpha((bBrightFirst) ? 96 : 32),
            wInside: (4 == widget.iWInside) ? wQueen : const SizedBox.shrink(),
            dLeft: widget.dLeft + 3 * dChessBoxFullSize,
            dTop: widget.dTop,
            dWidth: dChessBoxSize,
            dHeight: dChessBoxSize),
        ChessBox(
            backGroundColor: Colors.brown.withAlpha((bBrightFirst) ? 32 : 96),
            wInside: (5 == widget.iWInside) ? wQueen : const SizedBox.shrink(),
            dLeft: widget.dLeft + 4 * dChessBoxFullSize,
            dTop: widget.dTop,
            dWidth: dChessBoxSize,
            dHeight: dChessBoxSize),
        ChessBox(
            backGroundColor: Colors.brown.withAlpha((bBrightFirst) ? 96 : 32),
            wInside: (6 == widget.iWInside) ? wQueen : const SizedBox.shrink(),
            dLeft: widget.dLeft + 5 * dChessBoxFullSize,
            dTop: widget.dTop,
            dWidth: dChessBoxSize,
            dHeight: dChessBoxSize),
        ChessBox(
            backGroundColor: Colors.brown.withAlpha((bBrightFirst) ? 32 : 96),
            wInside: (7 == widget.iWInside) ? wQueen : const SizedBox.shrink(),
            dLeft: widget.dLeft + 6 * dChessBoxFullSize,
            dTop: widget.dTop,
            dWidth: dChessBoxSize,
            dHeight: dChessBoxSize),
        ChessBox(
            backGroundColor: Colors.brown.withAlpha((bBrightFirst) ? 96 : 32),
            wInside: (8 == widget.iWInside) ? wQueen : const SizedBox.shrink(),
            dLeft: widget.dLeft + 7 * dChessBoxFullSize,
            dTop: widget.dTop,
            dWidth: dChessBoxSize,
            dHeight: dChessBoxSize),
      ],
    );
  }
}

//---- ChessTable ----

class ChessTable extends StatefulWidget {
  final Widget wQueen;
  final List<int> liPlace;
  final double dScreenSize;

  const ChessTable({Key? key, required this.wQueen, required this.liPlace, required this.dScreenSize})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChessTableState();
}

class _ChessTableState extends State<ChessTable> {
  @override
  Widget build(BuildContext context) {
    double dMarginSize = widget.dScreenSize * 0.04;
    double dScreenSizeInside = widget.dScreenSize - 1.75 * dMarginSize;
    double dChessBoxFullSize = dScreenSizeInside / 8;
    if (8 != widget.liPlace.length) {
      widget.liPlace.clear();
      for (int i = 0; i < 8; i++) {
        widget.liPlace[0];
      }
    }
    return Stack(
      children: [
        ChessTableRow(
            wQueen: widget.wQueen,
            iWInside: widget.liPlace[0],
            dLeft: dMarginSize,
            dTop: dMarginSize,
            dChessBoxFullSize: dChessBoxFullSize,
            bBrightFirst: true),
        ChessTableRow(
            wQueen: widget.wQueen,
            iWInside: widget.liPlace[1],
            dLeft: dMarginSize,
            dTop: dMarginSize + dChessBoxFullSize,
            dChessBoxFullSize: dChessBoxFullSize,
            bBrightFirst: false),
        ChessTableRow(
            wQueen: widget.wQueen,
            iWInside: widget.liPlace[2],
            dLeft: dMarginSize,
            dTop: dMarginSize + 2 * dChessBoxFullSize,
            dChessBoxFullSize: dChessBoxFullSize,
            bBrightFirst: true),
        ChessTableRow(
            wQueen: widget.wQueen,
            iWInside: widget.liPlace[3],
            dLeft: dMarginSize,
            dTop: dMarginSize + 3 * dChessBoxFullSize,
            dChessBoxFullSize: dChessBoxFullSize,
            bBrightFirst: false),
        ChessTableRow(
            wQueen: widget.wQueen,
            iWInside: widget.liPlace[4],
            dLeft: dMarginSize,
            dTop: dMarginSize + 4 * dChessBoxFullSize,
            dChessBoxFullSize: dChessBoxFullSize,
            bBrightFirst: true),
        ChessTableRow(
            wQueen: widget.wQueen,
            iWInside: widget.liPlace[5],
            dLeft: dMarginSize,
            dTop: dMarginSize + 5 * dChessBoxFullSize,
            dChessBoxFullSize: dChessBoxFullSize,
            bBrightFirst: false),
        ChessTableRow(
            wQueen: widget.wQueen,
            iWInside: widget.liPlace[6],
            dLeft: dMarginSize,
            dTop: dMarginSize + 6 * dChessBoxFullSize,
            dChessBoxFullSize: dChessBoxFullSize,
            bBrightFirst: true),
        ChessTableRow(
            wQueen: widget.wQueen,
            iWInside: widget.liPlace[7],
            dLeft: dMarginSize,
            dTop: dMarginSize + 7 * dChessBoxFullSize,
            dChessBoxFullSize: dChessBoxFullSize,
            bBrightFirst: false),
      ],
    );
  }
}

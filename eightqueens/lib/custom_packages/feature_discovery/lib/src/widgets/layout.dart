import 'package:flutter/material.dart';

class CenterAbout extends StatelessWidget {
  final Offset? position;
  final Widget? child;

  const CenterAbout({super.key, this.position, this.child});

  @override
  Widget build(BuildContext context) => Positioned(
        top: position!.dy,
        left: position!.dx,
        child: FractionalTranslation(
          translation: const Offset(-0.5, -0.5),
          child: child,
        ),
      );
}

class AnchoredOverlay extends StatelessWidget {
  final bool? showOverlay;
  final Widget Function(BuildContext, Offset anchor)? overlayBuilder;
  final Widget? child;

  const AnchoredOverlay(
      {super.key, this.showOverlay, this.overlayBuilder, this.child});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => OverlayBuilder(
          showOverlay: showOverlay,
          overlayBuilder: (BuildContext overlayContext) {
            /// calculate center and path to up
            final box = context.findRenderObject() as RenderBox;
            final center = box.size.center(box.localToGlobal(
              const Offset(0.0, 0.0),
            ));
            return overlayBuilder!(context, center);
          },
          child: child,
        ),
      );
}

class OverlayBuilder extends StatefulWidget {
  final bool? showOverlay;
  final Function(BuildContext context)? overlayBuilder;
  final Widget? child;

  const OverlayBuilder(
      {super.key, this.showOverlay = false, this.overlayBuilder, this.child});

  @override
  OverlayBuilderState createState() => OverlayBuilderState();
}

class OverlayBuilderState extends State<OverlayBuilder> {
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.showOverlay!) showOverlay();
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    syncWidgetAndOverlay();
  }

  @override
  void reassemble() {
    super.reassemble();
    syncWidgetAndOverlay();
  }

  @override
  void dispose() {
    if (isShowingOverlay()) hideOverlay();
    super.dispose();
  }

  bool isShowingOverlay() => overlayEntry != null;

  void showOverlay() {
    overlayEntry = OverlayEntry(
      builder: widget.overlayBuilder as Widget Function(BuildContext),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Overlay.of(context).insert(overlayEntry!);
    });
  }

  void hideOverlay() {
    overlayEntry!.remove();
    overlayEntry = null;
  }

  void syncWidgetAndOverlay() {
    if (isShowingOverlay() && !widget.showOverlay!) {
      hideOverlay();
    } else if (!isShowingOverlay() && widget.showOverlay!) { showOverlay(); }
  }

  void buildOverlay() async => overlayEntry?.markNeedsBuild();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      buildOverlay();
    });
    return widget.child!;
  }
}

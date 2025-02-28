import 'package:flutter/material.dart';
import 'package:feature_discovery/feature_discovery.dart';
import '../middleware/localstorage.dart';

class HomeFeatureDiscovery {
  final BuildContext context;
  final List<String> lskFeatureIds;
  final bool Function() getMounted;

  HomeFeatureDiscovery({required this.context, required this.lskFeatureIds, required this.getMounted});

  bool bFirstShowDiscovery = true;  
  bool bHasPreviouslyCompleted = false;

  Future<bool> getHasPreviousCompleted() async { return ('true' == (await lsBHasPreviousCompleted.get())) ? true : false; }

  Future<void> showDiscovery() async {
    if (!bFirstShowDiscovery) { await checkDiscoveryCompleted(); } else { bFirstShowDiscovery = false; }
    bHasPreviouslyCompleted = await getHasPreviousCompleted();
    if (!getMounted()) return;
    // ! Start feature discovery
    FeatureDiscovery.discoverFeatures(
      context,
      // Feature ids for every feature that you want to showcase in order.
      <String>{...lskFeatureIds},
   );
  }

  Future<void> _clearDiscovery() async {
    await FeatureDiscovery.clearPreferences(
      context,
      <String>{...lskFeatureIds},
    );
  }

  Future<void> checkDiscoveryCompleted() async {
    bool isPreviousCompleted = await getHasPreviousCompleted();
    if (!isPreviousCompleted) {
      bool isCompleted = true;
      for (int i = 0; i < lskFeatureIds.length; i++) { 
        final isShown = await FeatureDiscovery.hasPreviouslyCompleted(context, lskFeatureIds[i]);
        isCompleted = isCompleted && isShown;
      }
      setHasPreviousCompleted(isCompleted);
    }
  }

  void setHasPreviousCompleted(bool value) {
    bHasPreviouslyCompleted = value;
    lsBHasPreviousCompleted.set((bHasPreviouslyCompleted) ? 'true' : 'false');
    if (!value) _clearDiscovery();  
  }

}

class StartButtonDescribedFeatureOverlay extends StatefulWidget {
  final String featureId;
  final Widget child;

  const StartButtonDescribedFeatureOverlay({Key? key, required this.featureId, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StartButtonDescribedFeatureOverlayState();
  
}

class _StartButtonDescribedFeatureOverlayState extends State<StartButtonDescribedFeatureOverlay> {
  @override
  Widget build(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: widget.featureId,
      tapTarget: ElevatedButton(child: const Padding(padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: Text('Start', style: TextStyle(fontSize: 20))),
        onPressed: null,
        style: ButtonStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) { return Colors.white; }
            return null; // Use the default color
          }),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
            if (states.contains(WidgetState.disabled)) { return Theme.of(context).primaryColor; }
            return null; // Use the default color
          }),
        ),
      ),
      contentLocation: ContentLocation.above,
      title: const Text('Start button', style: TextStyle(fontSize: 18)),
      description:
          const Text('Tap the Start button to start the speed test.', style: TextStyle(fontSize: 17)),
      backgroundColor: Theme.of(context).primaryColor,
      child: widget.child
    );
  }
}

class ThreadDropdownDescribedFeatureOverlay extends StatefulWidget {
  final String featureId;
  final ContentLocation contentLocation;
  final Widget child;

  const ThreadDropdownDescribedFeatureOverlay({Key? key, required this.featureId, required this.contentLocation, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ThreadDropdownDescribedFeatureOverlayState();
  
}

class _ThreadDropdownDescribedFeatureOverlayState extends State<ThreadDropdownDescribedFeatureOverlay> {
  @override
  Widget build(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: widget.featureId,
      tapTarget: TextButton(
        onPressed: null,
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return Theme.of(context).textTheme.bodyMedium?.color; // Disabled text color
              }
              return null; // Default text color
            },
          ),
        ),
        child: const Padding(padding: EdgeInsets.fromLTRB(0, 8, 0, 8), child: Text('Thread', style: TextStyle(fontSize: 17))),
      ),
      contentLocation: widget.contentLocation,
      title: const Text('Thread selection', style: TextStyle(fontSize: 18)),
      description: const Text('Tap the Thread selection dropdown to choose from 1, 2, 4 or 8 threads speed test.', style: TextStyle(fontSize: 17)),
      backgroundColor: Theme.of(context).primaryColor,
      child: Align(alignment: Alignment.topLeft, child: widget.child),
    );
  }
}

class NavMenuDescribedFeatureOverlay extends StatefulWidget {
  final String featureId;
  final Widget child;

  const NavMenuDescribedFeatureOverlay({Key? key, required this.featureId, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NavMenuDescribedFeatureOverlayState();
  
}

class _NavMenuDescribedFeatureOverlayState extends State<NavMenuDescribedFeatureOverlay> {
  @override
  Widget build(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: widget.featureId,
      tapTarget: const Icon(Icons.menu_rounded, size: 28),
      contentLocation: ContentLocation.below,
      title: const Text('Lists of the fastest and slowest mobiles.', style: TextStyle(fontSize: 18)),
      description: const Text('Tap the Hamburger icon to choose from many different Lists: Top performers, worst performers phones, You can also see who tested the most phones and who collected the most crowns.', style: TextStyle(fontSize: 17)),
      backgroundColor: Theme.of(context).primaryColor,
      child: Align(alignment: Alignment.topLeft, child: widget.child),
    );
  }
}

class CrownCollectDescribedFeatureOverlay extends StatefulWidget {
  final String featureId;
  final Widget wCrown;
  final Widget child;

  const CrownCollectDescribedFeatureOverlay({Key? key, required this.featureId, required this.wCrown, required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CrownCollectDescribedFeatureOverlayState();
  
}

class _CrownCollectDescribedFeatureOverlayState extends State<CrownCollectDescribedFeatureOverlay> {
  @override
  Widget build(BuildContext context) {
    return DescribedFeatureOverlay(
      featureId: widget.featureId,
      tapTarget: IntrinsicWidth(
        child: IntrinsicHeight(
          child: Padding(padding: const EdgeInsets.only(bottom: 4), child: SizedBox.fromSize(child: widget.wCrown, size: const Size(28, 28))),
      )),
      contentLocation: ContentLocation.below,
      title: const Text('Collect crowns.', style: TextStyle(fontSize: 18)),
      description: const Text('Tap the crown and collect crowns, you will get surprises later for the crowns.', style: TextStyle(fontSize: 17)),
      backgroundColor: Theme.of(context).primaryColor,
      child: Align(alignment: Alignment.topLeft, child: widget.child),
    );
  }
}

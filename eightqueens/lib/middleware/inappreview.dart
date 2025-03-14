import 'package:eightqueens/middleware/localstorage.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/widgets.dart';
import '../parameters/globals.dart';
import '../widgets/messagedialogs.dart';

class InAppReviewController {

  final InAppReview inAppReview = InAppReview.instance;
  
  Future<bool> getEnabled() async { return (Duration(days: GV.iInAppReviewDelayDays) < DateTime.now().toUtc().difference((await getInAppReviewLocalDate()))); }

  Future<void> _requestReview(BuildContext context) async {
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing(
        appStoreId: 'id1621191695',
      );
    }
  }

  Future<void> _showPlacementQuestion(BuildContext context, int placement) async {
    String sPlacement = (1 == placement) ? "1st" : (2 == placement) ? "2nd" : (3 == placement) ? "3rd" : "";
    if (context.mounted) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        await info2ButtonDialog(
          context,
          false,
          MainAxisAlignment.spaceBetween,
          "Congratulation!",
          "You are on the $sPlacement place in this list. Do you like this App?",
          "No",
          "Yes, I like it",
          () {},
          () { _requestReview(context); },
          insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        );
      }
    }
  }

  Future<void> callPlacementAndRequestReview(BuildContext context, int placement) async {
    if ([1, 2, 3].contains(placement) && (await getEnabled())) {
      setEnabledInAppReviewLocalDateToNow();
      _showPlacementQuestion(context, placement);
    }
  }

}

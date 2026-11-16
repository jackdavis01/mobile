# 8 Queens Performance Benchmark

A Flutter project that demonstrates the power, versatility and multi-platform nature of the Flutter development environment.

## Getting Started

This project contains the source code for the 8 Queens App and all the resources needed to build it on the 6 available platforms.

## 8 Queens: Instructions

8 Queens Performance Benchmark Test And Meter App is a Visual CPU Performance App. You can meter your smart mobile device's speed with the Eight Queens Chess Problem solving.

### The App runs on, and you can download from

1. Android: Google Play
2. iOS: iPhones, iPads, on M1, M2, M3, M4 Macintosh desktops, and on M1, M2, M3, M4 MacBook notebooks.'
3. Windows desktop: <https://is.gd/8Queens>
4. MacOS desktop: App Store
5. Linux desktop: Snap Store
6. Web version on any platform: <https://jackdavis01.github.io/mobile>

Search for "8 Queens" or "8 Queens Performance".

### 8 Queens Problem

The App finds the 92 right solutions from the 16 million variations where the eight queens don't threaten each other on the 8x8 chessboard.

### App information

Finding the 92 right solutions with an up-to-date, decent smart mobile phone lasts less than a half minute.
If you would like to see the right solutions, please choose '1 sec' or '5 sec' wait at 'No Wait'.
If you would like to check your smart phone's multithreaded CPU performance please, choose 2 or 4 or '8 Threads'.

The App uses brute force method to find the right solutions. Since this App is a Performance Benchmark, it was not intended to use an algorithm faster than the brute force method. Any more efficient algorithm would run too fast on a flagship device.

Not all iterations are displayed. Only about every 5000th iteration is displayed. Therefore, outputing to the display slows down max. 10% on the algorithm.

The Web version is not suitable for comparative speed testing, so download the App for the platform. The Web version runs at different speeds in different browsers. For example, in Firefox it's extremely slow and Chrome can produce surprising results even on slow devices in multi-threaded mode.

### Statistics periods

User and model statistics, run-count lists, and worst-result lists offer Weekly,
Monthly, Quarterly, Yearly, and 3-yearly tabs. Each period shows records updated
within that rolling window, retaining their accumulated run counts and best,
average, and worst results. These are not calendar periods or statistics limited
to runs performed during the selected period.

Yearly uses backend interval `5`; 3-yearly uses interval `6` (backend v0.3.5 or
later). Existing thread and Android/iOS filters are unchanged. Cached results
from the original three periods are retained when the two new periods are added.

To check period selection, backend interval mapping, and cache compatibility:

```sh
flutter test test/statistics_intervals_test.dart
```

### App Stats

On **Android and iOS only**, open **App Stats** from the drawer to see current
recorded benchmark runs, **Auto-registered users**, and device models across
all platforms. Counts use space thousands separators, such as `31 161`.
The web/desktop versions do not expose this feature or request its summary.

The screen uses backend v0.3.6's authenticated aggregate GET, caches validated
totals for five minutes, and keeps saved values and their local-time "Last
updated" timestamp when offline or a refresh fails. Completed tests persistently
expire the cache. Final confirmed result storage marks it expired again so an
older in-flight request cannot mark pre-upload totals fresh. Neither event
fetches statistics: fresh totals are requested on the next App Stats visit or
through its Refresh control.

The result screen has no App Stats feedback box or upload-retry action.
The Recorded benchmark runs card shows only its label and total, without
change information below the number. Positive user/model changes shown after a
later refresh compare global snapshots and can include other users' activity.

See the [screen plan and implementation notes](docs/APP_STATS_SCREEN_PLAN.md).
To verify summary validation, persistent cache expiry, in-flight races,
registration recovery, deferred retrieval, and the responsive screen:

```sh
flutter test test/app_stats_api_test.dart test/app_stats_test.dart test/app_stats_submission_test.dart test/app_stats_widgets_test.dart
```

### Result sharing

On **Android and iOS only**, the Result page has a fixed sharing panel below the
app bar. Results and existing controls scroll underneath it.

Both buttons use Contribution's rounded corners and font size, with centered
two-line labels. The TikTok button has a visible blue outline. The centered
result preview also uses two lines, with the Rank
Ranges text size; copied/shared text stays on one line. Narrow or enlarged-text
layouts stack the buttons without shrinking the labels. Short-height layouts
still omit the optional preview to leave room for the results.

- **Copy & open TikTok** copies the short result text and opens the configured
  video. The user opens comments, pastes, and posts; TikTok may require sign-in.
  This does not automatically open comments or publish anything.
- **Share result** opens the standard OS text share sheet. The user chooses a
  compatible installed app, recipient, and sends. Cancellation is normal;
  opening a share target is not proof of delivery.

Both actions use the same text, for example:

```text
8 Queens | Blue Tiger | 4 threads | 12.345 s
```

There is no weekly rank, attachment, or added download link. Sharing requires a
completed measurement and an actual saved username, never the placeholder `Me`.
First registration saves the username before announcing completion. A local
username retry does not resubmit the benchmark. Once a sharing action or retry
starts, that Result visit's delayed auto-scroll/crown navigation is suppressed.
Sharing does not request App Stats or change upload/cache-expiry ordering.

The main video comes from backend v0.3.7's authenticated configuration endpoint,
controlled by Railway's `TIKTOK_RESULT_VIDEO_URL`. On mobile Result entry, the
app retains a validated cache for up to seven days and refreshes it when at least
24 hours old. Without an acceptable cache it uses the single bundled fallback
in [resultshare.dart](lib/parameters/resultshare.dart) immediately. Sharing taps
do not fetch configuration or wait for a refresh. Both initial URLs target the
same video, so fallback cannot recover a deleted/restricted video.

`share_plus` 11.1.0 was selected to match the existing native tooling without
upgrading it. iPad sharing uses the tapped button's bounds as its popover anchor.
The web/desktop versions do not show the panel or request sharing configuration.

See the [sharing plan and verification notes](docs/RESULT_SHARE_SCREEN_PLAN.md).
Focused sharing and submission regression checks:

```sh
flutter test test/result_share_test.dart test/result_share_api_test.dart test/result_share_widgets_test.dart test/app_stats_submission_test.dart
```

Android's native chooser, TikTok handoff, fixed panel, and return-to-Result were
device-tested without sending/posting. Android, web, and unsigned iOS builds
passed before the final retry/error-display refinements; the final source passed
focused tests and analysis. The user will run iOS and Web verification.
TikTok comment entry and iPhone/iPad native sharing remain manual
verification gates; an iOS build or widget anchor check does not verify them.

### License

MIT license: <https://choosealicense.com/licenses/mit>

### Feedback, contribute

emailto: jackdavis01@gmail.com

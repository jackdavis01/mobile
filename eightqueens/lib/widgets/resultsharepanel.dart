import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../middleware/appstats.dart';
import '../middleware/autoregistration.dart';
import '../middleware/resultshare.dart';
import '../parameters/resultshare.dart';
import 'globalwidgets.dart';

class ResultSharePanel extends StatefulWidget {
  final int threads;
  final Duration elapsed;
  final bool completed;
  final double availableHeight;
  final Future<String> Function() readUsername;
  final VoidCallback onInteraction;
  final AppStatsMeasurement? measurement;
  final ResultShareConfigStore? config;
  final ResultShareActions? actions;

  const ResultSharePanel({
    super.key,
    required this.threads,
    required this.elapsed,
    required this.completed,
    required this.availableHeight,
    required this.readUsername,
    required this.onInteraction,
    this.measurement,
    this.config,
    this.actions,
  });

  @override
  State<ResultSharePanel> createState() => _ResultSharePanelState();
}

class _ResultSharePanelState extends State<ResultSharePanel>
    with WidgetsBindingObserver {
  late ResultShareConfigStore _config;
  late ResultShareActions _actions;
  final _shareButtonKey = GlobalKey();
  String? _username;
  String? _usernameError;
  bool _readingUsername = true;
  bool _busy = false;
  int _usernameGeneration = 0;
  AppLifecycleState? _lifecycle;

  bool get _validResult =>
      widget.completed && widget.threads > 0 && widget.elapsed > Duration.zero;
  bool get _hasUsername =>
      _username?.trim().isNotEmpty == true &&
      _username!.trim() != AutoRegLocal.sMe;
  bool get _waitingForSubmission =>
      widget.measurement?.status == AppStatsSubmission.pending ||
      widget.measurement?.status == AppStatsSubmission.uploading;
  bool get _canProceed =>
      mounted &&
      (_lifecycle == null || _lifecycle == AppLifecycleState.resumed) &&
      ModalRoute.of(context)?.isCurrent == true;

  @override
  void initState() {
    super.initState();
    if (!resultSharingSupported) return;
    _config = widget.config ?? ResultShareConfigStore.instance;
    _actions = widget.actions ?? ResultShareActions();
    _lifecycle = WidgetsBinding.instance.lifecycleState;
    WidgetsBinding.instance.addObserver(this);
    _config.addListener(_onConfigChanged);
    widget.measurement?.addListener(_onMeasurementChanged);
    unawaited(_loadUsername());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_config.refreshIfNeeded());
    });
  }

  @override
  void didUpdateWidget(covariant ResultSharePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!resultSharingSupported) return;
    if (oldWidget.measurement != widget.measurement) {
      oldWidget.measurement?.removeListener(_onMeasurementChanged);
      widget.measurement?.addListener(_onMeasurementChanged);
      unawaited(_loadUsername());
    }
  }

  @override
  void dispose() {
    if (resultSharingSupported) {
      _config.removeListener(_onConfigChanged);
      widget.measurement?.removeListener(_onMeasurementChanged);
      WidgetsBinding.instance.removeObserver(this);
    }
    _usernameGeneration++;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    if (state == AppLifecycleState.resumed) unawaited(_loadUsername());
  }

  void _onConfigChanged() {
    if (mounted) setState(() {});
  }

  void _onMeasurementChanged() => unawaited(_loadUsername());

  Future<void> _loadUsername() async {
    final generation = ++_usernameGeneration;
    String? name;
    String? error;
    try {
      name = await widget.readUsername();
    } on PlatformException {
      debugPrint('Result sharing: username storage read failed.');
      error = 'The username could not be read.';
    } on MissingPluginException {
      debugPrint('Result sharing: username storage is unavailable.');
      error = 'The username is unavailable on this device.';
    }
    if (!mounted || generation != _usernameGeneration) return;
    setState(() {
      _username = name;
      _usernameError = error;
      _readingUsername = false;
    });
  }

  Future<void> _share({required bool tikTok}) async {
    if (_busy || !_validResult || !_canProceed) return;
    setState(() {
      _busy = true;
    });
    widget.onInteraction();
    try {
      await _loadUsername();
      if (!_canProceed) return;
      if (!_hasUsername) {
        throw const ResultShareException(
            'Your username is not ready. Please try again shortly.');
      }
      final text = formatResultShare(
          username: _username!,
          threads: widget.threads,
          elapsed: widget.elapsed);
      if (tikTok) {
        final opened = await _actions.copyAndOpenTikTok(
            text, _config.selectedUri,
            canProceed: () => _canProceed);
        if (opened && _canProceed) {
          _notify('Result copied. Open comments, paste, and post.');
        }
      } else {
        final render = _shareButtonKey.currentContext?.findRenderObject();
        if (render is! RenderBox || !render.hasSize || render.size.isEmpty) {
          throw const ResultShareException(
              'Sharing is not ready. Please try again.');
        }
        final origin = render.localToGlobal(Offset.zero) & render.size;
        await _actions.shareText(text, origin);
      }
    } on ResultShareException catch (error) {
      if (_canProceed) _notify(error.message);
    } on FormatException {
      if (_canProceed) {
        _notify('A completed result and actual username are required.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (!resultSharingSupported) return const SizedBox.shrink();
    return LayoutBuilder(builder: (context, constraints) {
      final compact = widget.availableHeight < 400;
      const margin = EdgeInsets.fromLTRB(12, 8, 12, 4);
      const padding = EdgeInsets.all(12);
      const buttonPadding = EdgeInsets.symmetric(horizontal: 4, vertical: 16);
      const buttonSpacing = 8.0;
      const buttonTextStyle = TextStyle(fontSize: 20, height: 1);
      final theme = Theme.of(context);
      final labelWidth = TextPainter.computeWidth(
        text: TextSpan(
          text: 'Copy & open',
          style: theme.textTheme.labelLarge?.merge(buttonTextStyle) ??
              buttonTextStyle,
        ),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      );
      final buttonWidth = (constraints.maxWidth -
              margin.horizontal -
              padding.horizontal -
              buttonSpacing) /
          2;
      final stackButtons = buttonWidth < labelWidth + buttonPadding.horizontal;
      final buttonStyle = ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        padding: const WidgetStatePropertyAll(buttonPadding),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      );
      final ready = _validResult && _hasUsername && !_busy;
      final tikTokButton = Tooltip(
        message:
            'Copy your result, then paste it in the TikTok video comments.',
        child: OutlinedButton(
          style: buttonStyle.copyWith(
            side: WidgetStateProperty.resolveWith((states) => BorderSide(
                  width: 2,
                  color: states.contains(WidgetState.disabled)
                      ? theme.colorScheme.onSurface.withValues(alpha: .12)
                      : theme.colorScheme.primary,
                )),
          ),
          onPressed: ready ? () => _share(tikTok: true) : null,
          child: const Text(
            'Copy & open\nTikTok',
            style: buttonTextStyle,
            semanticsLabel: 'Copy result and open TikTok',
            textAlign: TextAlign.center,
            softWrap: false,
          ),
        ),
      );
      final shareButton = FilledButton(
        key: _shareButtonKey,
        style: buttonStyle,
        onPressed: ready ? () => _share(tikTok: false) : null,
        child: const Text(
          'Share\nresult',
          style: buttonTextStyle,
          semanticsLabel: 'Share result with another app',
          textAlign: TextAlign.center,
          softWrap: false,
        ),
      );
      String? status;
      if (!_validResult) {
        status = 'Complete a benchmark to share its result.';
      } else if (!_hasUsername) {
        status = _usernameError ??
            (_readingUsername || _waitingForSubmission
                ? 'Preparing username...'
                : 'Username unavailable. Retry the local read.');
      }
      final canRetry = status != null &&
          !_busy &&
          !_readingUsername &&
          !_waitingForSubmission &&
          _validResult;
      return RoundedContainer(
        width: double.infinity,
        constraints: const BoxConstraints(),
        margin: margin,
        padding: padding,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (stackButtons)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                tikTokButton,
                const SizedBox(height: buttonSpacing),
                shareButton,
              ],
            )
          else
            Row(children: [
              Expanded(child: tikTokButton),
              const SizedBox(width: buttonSpacing),
              Expanded(child: shareButton),
            ]),
          if (status != null)
            Row(children: [
              Expanded(
                  child: Text(status,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall)),
              if (canRetry)
                IconButton(
                  tooltip: 'Retry reading username',
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    widget.onInteraction();
                    setState(() {
                      _readingUsername = true;
                    });
                    unawaited(_loadUsername());
                  },
                ),
            ]),
          if (!compact && _hasUsername && _validResult)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                  formatResultShare(
                      username: _username!,
                      threads: widget.threads,
                      elapsed: widget.elapsed,
                      multiline: true),
                  maxLines: 2,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17)),
            ),
          if (_config.usingFallback || _config.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                  _config.usingFallback
                      ? 'Using fallback video'
                      : _config.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall),
            ),
        ]),
      );
    });
  }
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../apinetisolates/appstatsapicontroller.dart';
import '../middleware/appstats.dart';
import '../widgets/adhandler.dart';

class AppStatsPage extends StatefulWidget {
  final AppStatsStore? store;

  const AppStatsPage({Key? key, this.store}) : super(key: key);

  @override
  State<AppStatsPage> createState() => _AppStatsPageState();
}

class _AppStatsPageState extends State<AppStatsPage> {
  late final AppStatsStore _store = widget.store ?? AppStatsStore.instance;
  Timer? _cooldown;

  @override
  void initState() {
    super.initState();
    _store.addListener(_changed);
    _scheduleCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _store.refresh();
    });
  }

  void _scheduleCooldown() {
    _cooldown?.cancel();
    if (!_store.expired) {
      _cooldown = Timer(_store.cooldownRemaining, () {
        if (mounted) setState(() {});
      });
    }
  }

  void _changed() {
    _scheduleCooldown();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cooldown?.cancel();
    _store.removeListener(_changed);
    super.dispose();
  }

  Widget _card(String label, int value, int? before) {
    final increased = before != null && value > before;
    final formatted = formatAppStatsCount(value);
    final change = increased
        ? '${formatAppStatsCount(before)} -> $formatted (+${formatAppStatsCount(value - before)})'
        : null;
    return Semantics(
      label:
          '$label: $formatted${change == null ? '' : '. Change since the previous snapshot: $change'}',
      excludeSemantics: true,
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(formatted,
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800)),
                ),
              ),
              if (change != null) ...[
                const SizedBox(height: 8),
                FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(change, maxLines: 1)),
                const Text('Change since the previous snapshot'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _lastUpdated(DateTime utc) {
    final local = utc.toLocal();
    final localization = MaterialLocalizations.of(context);
    return '${localization.formatMediumDate(local)}, '
        '${localization.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat)}';
  }

  @override
  Widget build(BuildContext context) {
    final summary = _store.summary;
    final measurement = _store.lastMeasurement;
    final baseline =
        measurement?.refreshedSummary != null ? measurement?.baseline : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Stats'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _store.loading
                ? 'Refreshing statistics'
                : _store.canRefresh
                    ? 'Refresh statistics'
                    : 'Refresh available after five minutes',
            icon: const Icon(Icons.refresh),
            onPressed: _store.canRefresh ? () => _store.refresh() : null,
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        top: false,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('The 8 Queens community',
                    style: Theme.of(context).textTheme.headlineSmall),
                Text('All platforms',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                if (summary == null)
                  if (_store.loading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    const Text('Statistics are unavailable right now.'),
                    TextButton(
                        onPressed: () => _store.refresh(force: true),
                        child: const Text('Retry')),
                  ]
                else ...[
                  if (_store.loading) const LinearProgressIndicator(),
                  _card('Recorded benchmark runs',
                      summary.recordedBenchmarkRuns, null),
                  LayoutBuilder(builder: (context, constraints) {
                    final users = _card(
                        'Auto-registered users',
                        summary.autoRegisteredUsers,
                        baseline?.autoRegisteredUsers);
                    final models = _card('Benchmarked device models', summary.deviceModels,
                        baseline?.deviceModels);
                    if (constraints.maxWidth >= 600 &&
                        MediaQuery.textScalerOf(context).scale(1) <= 1.3) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: users),
                          Expanded(child: models),
                        ],
                      );
                    }
                    return Column(children: [users, models]);
                  }),
                  const SizedBox(height: 8),
                  Text('Last updated: ${_lastUpdated(summary.generatedAt)}', style: Theme.of(context).textTheme.titleMedium),
                  if (_store.errorMessage != null)
                    Semantics(
                        liveRegion: true, child: Text(_store.errorMessage!, style: Theme.of(context).textTheme.titleMedium)),
                  const SizedBox(height: 12),
                ],
                ListTileTheme.merge(
                  titleTextStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.apply(fontSizeFactor: 1.2),
                  subtitleTextStyle: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w400).apply(fontSizeFactor: 1.1),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 16),
                    title: Text('About these numbers', style: Theme.of(context).textTheme.titleLarge),
                    children: const [
                      ListTile(
                          title: Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('Recorded benchmark runs')),
                          subtitle: Text(
                              "Individual benchmark results currently recorded in the backend's result log. Unsubmitted runs are not included.")),
                      ListTile(
                          title: Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('Auto-registered users')),
                          subtitle: Text(
                              'Backend user records automatically registered by the app, not distinct people or currently active users.')),
                      ListTile(
                          title: Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text('Benchmarked device models')),
                          subtitle: Text(
                              'Different device models registered through benchmark submissions. Multiple devices and repeated tests using the same model and operating system count as one entry.')),
                      ListTile(
                          subtitle: Text(
                              'These are current recorded totals across all platforms. Cleanup can reduce them. Changes between snapshots can include other users and are not attributed exclusively to your benchmark.')),
                    ],
                  ),
                ),
                const AdBannerSpace(),
              ],
            ),
            const AdBanner(),
          ],
        ),
      ),
    );
  }
}

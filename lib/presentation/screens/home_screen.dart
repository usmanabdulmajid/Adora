import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../l10n/app_localizations.dart';
import '../providers/location_providers.dart';
import '../widgets/location_display_widget.dart';
import '../widgets/permission_indicator_widget.dart';
import '../widgets/tracking_history_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(locationHistoryProvider);
      ref.invalidate(permissionStatusProvider);
      ref.invalidate(currentLocationStreamProvider);
      _handleResume();
    }
  }

  Future<void> _handleResume() async {
    final pending = ref.read(pendingPermissionDialogProvider);
    if (pending) {
      final repository = ref.read(locationRepositoryProvider);
      final either = await repository.hasBackgroundPermission();
      final hasPerm = either.fold((_) => false, (has) => has);
      if (hasPerm) {
        ref.read(pendingPermissionDialogProvider.notifier).dismiss();
        ref.read(trackingStateProvider.notifier).toggle();
      }
    }
  }

  Future<void> _showPermissionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.backgroundTrackingDialogTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            l10n.backgroundTrackingDialogContent,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(l10n.cancel, style: const TextStyle(fontSize: 15)),
          ),
          FilledButton.icon(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.of(context).pop(true);
            },
            icon: const Icon(Icons.settings, size: 18),
            label: Text(
              l10n.openSettings,
              style: const TextStyle(fontSize: 15),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
    if (dialogResult == null || !dialogResult) {
      ref.read(pendingPermissionDialogProvider.notifier).dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final trackingAsync = ref.watch(trackingStateProvider);

    ref.listen<bool>(pendingPermissionDialogProvider, (_, next) {
      if (next) {
        _showPermissionDialog();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appBarTitle), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(locationHistoryProvider);
          ref.invalidate(permissionStatusProvider);
          ref.invalidate(currentLocationStreamProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const PermissionIndicatorWidget(),
              const LocationDisplayWidget(),
              _buildTrackingToggle(context, ref, trackingAsync),
              const SizedBox(height: 16),
              const TrackingHistoryWidget(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingToggle(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<bool> trackingAsync,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.track_changes,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.backgroundTracking,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  trackingAsync.when(
                    data: (isRunning) => Text(
                      isRunning ? l10n.active : l10n.inactive,
                      style: TextStyle(
                        fontSize: 13,
                        color: isRunning ? Colors.green : Colors.grey,
                      ),
                    ),
                    error: (_, _) => Text(
                      l10n.inactive,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    loading: () => Text(
                      l10n.loading,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            trackingAsync.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: trackingAsync.asData?.value ?? false,
                    onChanged: (_) {
                      ref.read(trackingStateProvider.notifier).toggle();
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

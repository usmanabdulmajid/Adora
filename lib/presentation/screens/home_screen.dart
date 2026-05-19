import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../constants/dimensions.dart';
import '../providers/location_providers.dart';
import '../widgets/location_display_widget.dart';
import '../widgets/permission_dialog_widget.dart';
import '../widgets/permission_indicator_widget.dart';
import '../widgets/tracking_history_widget.dart';
import '../widgets/tracking_toggle_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _hasRequestedLocationPermission = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasRequestedLocationPermission) {
      ref.read(requestLocationPermissionUseCaseProvider).call();
      _hasRequestedLocationPermission = true;
    }
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
        ref.read(trackingStateProvider.notifier).toggle();
      }
      ref.read(pendingPermissionDialogProvider.notifier).dismiss();
    }
  }

  Future<void> _showPermissionDialog() async {
    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => PermissionDialogWidget(),
    );
    if (dialogResult == null || !dialogResult && context.mounted) {
      ref.read(pendingPermissionDialogProvider.notifier).dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              const SizedBox(height: AppSizes.spacingSmall),
              const PermissionIndicatorWidget(),
              const LocationDisplayWidget(),
              const TrackingToggleWidget(),
              const SizedBox(height: AppSizes.spacingLarge),
              const TrackingHistoryWidget(),
              const SizedBox(height: AppSizes.spacingExtraLarge),
            ],
          ),
        ),
      ),
    );
  }
}

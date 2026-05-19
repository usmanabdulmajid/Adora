import 'package:adora_assessment/l10n/app_localizations.dart';
import 'package:adora_assessment/presentation/constants/dimensions.dart';
import 'package:adora_assessment/presentation/providers/location_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackingToggleWidget extends ConsumerWidget {
  const TrackingToggleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final permissionAsync = ref.watch(permissionStatusProvider);
    final hasPermission = permissionAsync.asData?.value ?? false;
    final trackingAsync = ref.watch(trackingStateProvider);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Opacity(
        opacity: hasPermission ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.track_changes,
                color: hasPermission
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(width: AppSizes.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.backgroundTracking,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: hasPermission ? null : Colors.grey,
                      ),
                    ),
                    if (hasPermission)
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
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        loading: () => Text(
                          l10n.loading,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      Text(
                        l10n.locationPermissionRequiredTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              if (trackingAsync.isLoading)
                const SizedBox(
                  width: AppSizes.loadingIndicatorLarge,
                  height: AppSizes.loadingIndicatorLarge,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizes.progressIndicatorStrokeWidth,
                  ),
                )
              else
                Switch(
                  value: trackingAsync.asData?.value ?? false,
                  onChanged: hasPermission
                      ? (_) {
                          ref.read(trackingStateProvider.notifier).toggle();
                        }
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

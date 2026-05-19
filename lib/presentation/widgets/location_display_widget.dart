import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../providers/location_providers.dart';

class LocationDisplayWidget extends ConsumerWidget {
  const LocationDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final permissionAsync = ref.watch(permissionStatusProvider);
    final locationAsync = ref.watch(currentLocationStreamProvider);
    final hasPermission = permissionAsync.asData?.value ?? false;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: hasPermission
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.currentLocation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            permissionAsync.when(
              data: (granted) {
                if (!granted) {
                  return PermissionDeniedWidget();
                }
                return locationAsync.when(
                  data: (location) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow(
                        l10n.latitude,
                        location.latitude.toStringAsFixed(6),
                      ),
                      const SizedBox(height: 4),
                      InfoRow(
                        l10n.longitude,
                        location.longitude.toStringAsFixed(6),
                      ),
                      const SizedBox(height: 4),
                      InfoRow(
                        l10n.timestamp,
                        DateFormat(
                          'yyyy-MM-dd HH:mm:ss',
                        ).format(location.timestamp),
                      ),
                    ],
                  ),
                  error: (err, _) => Text(
                    l10n.unableToGetLocation('$err'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              },
              error: (_, _) => Text(
                l10n.locationPermissionRequiredTitle,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              loading: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionDeniedWidget extends StatelessWidget {
  const PermissionDeniedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.lock,
            size: 40,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.locationPermissionRequiredTitle,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.locationPermissionRequiredDescription,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontFamily: 'monospace')),
      ],
    );
  }
}

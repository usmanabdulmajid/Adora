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
    final locationAsync = ref.watch(currentLocationStreamProvider);

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
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.currentLocation,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            locationAsync.when(
              data: (location) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(l10n.latitude, location.latitude.toStringAsFixed(6)),
                  const SizedBox(height: 4),
                  _infoRow(
                    l10n.longitude,
                    location.longitude.toStringAsFixed(6),
                  ),
                  const SizedBox(height: 4),
                  _infoRow(
                    l10n.timestamp,
                    DateFormat(
                      'yyyy-MM-dd HH:mm:ss',
                    ).format(location.timestamp),
                  ),
                ],
              ),
              error: (err, _) => Text(
                l10n.unableToGetLocation('$err'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontFamily: 'monospace')),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../constants/dimensions.dart';
import '../providers/location_providers.dart';

class TrackingHistoryWidget extends ConsumerWidget {
  const TrackingHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(locationHistoryProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSizes.spacingSmall),
                Text(
                  l10n.trackingHistory,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingMedium),
            historyAsync.when(
              data: (locations) {
                if (locations.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: Text(l10n.noLocationData)),
                  );
                }
                final display = locations.take(10).toList();
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: display.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final loc = display[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      title: Text(
                        '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                      trailing: Text(
                        DateFormat('HH:mm:ss').format(loc.timestamp),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                );
              },
              error: (err, _) => Text(
                l10n.failedToLoadHistory('$err'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

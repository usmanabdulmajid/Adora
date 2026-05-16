import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/location_providers.dart';

class PermissionIndicatorWidget extends ConsumerWidget {
  const PermissionIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final permissionAsync = ref.watch(permissionStatusProvider);

    return permissionAsync.when(
      data: (granted) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              granted ? Icons.check_circle : Icons.cancel,
              color: granted ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              granted
                  ? l10n.locationPermissionGranted
                  : l10n.locationPermissionDenied,
              style: TextStyle(
                fontSize: 13,
                color: granted ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      loading: () => const SizedBox(
        height: 16,
        child: Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

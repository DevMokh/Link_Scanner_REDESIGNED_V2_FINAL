import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'brand_logo.dart';

/// Unified page header used by every top-level tool screen.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  final String title;
  final String subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final scaffold = Scaffold.maybeOf(context);
    final hasMenu = scaffold?.hasDrawer ?? false;
    final badge = icon == null
        ? const LinkScannerLogo(size: 46, glowing: false)
        : Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: alpha(C.accent, 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: alpha(C.accent, 0.28)),
            ),
            child: Icon(icon, color: C.accent, size: 24),
          );

    return Padding(
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
        decoration: BoxDecoration(
          color: C.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: C.line),
        ),
        child: Row(
          children: [
            badge,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: C.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: C.muted, fontSize: 11.5, height: 1.35),
                  ),
                ],
              ),
            ),
            if (hasMenu) ...[
              const SizedBox(width: 8),
              Material(
                color: C.surface2,
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: () => scaffold?.openDrawer(),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.tune_rounded, color: C.accent, size: 20),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

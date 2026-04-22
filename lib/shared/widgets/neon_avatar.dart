import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

/// Avatar with gradient ring border and optional online indicator dot.
/// Matches the design reference avatar styling with neon ring + status dot.
class NeonAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;
  final Gradient? ringGradient;
  final bool showRing;
  final VoidCallback? onTap;

  const NeonAvatar({
    super.key,
    this.imageUrl,
    this.size = 56,
    this.showOnlineIndicator = false,
    this.isOnline = true,
    this.ringGradient,
    this.showRing = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ringPadding = size * 0.036; // 2px for 56px avatar

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Ring + Avatar
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: showRing
                    ? (ringGradient ?? AppDecorations.avatarRingGradient)
                    : null,
                color: showRing ? null : AppColors.white10,
                boxShadow: showRing ? AppDecorations.neonShadowPrimary : null,
              ),
              padding: EdgeInsets.all(ringPadding),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
                padding: EdgeInsets.all(ringPadding),
                child: ClipOval(
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          width: size,
                          height: size,
                          errorBuilder: (ctx, err, st) => _fallbackIcon(),
                        )
                      : _fallbackIcon(),
                ),
              ),
            ),

            // Online indicator dot
            if (showOnlineIndicator)
              Positioned(
                bottom: size * 0.02,
                right: size * 0.02,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? AppColors.online : AppColors.away,
                    border: Border.all(
                      color: AppColors.background,
                      width: size * 0.036,
                    ),
                    boxShadow: isOnline
                        ? AppDecorations.neonShadowGreen
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: AppColors.backgroundAlt,
      child: Icon(
        Icons.person,
        color: AppColors.primary,
        size: size * 0.4,
      ),
    );
  }
}

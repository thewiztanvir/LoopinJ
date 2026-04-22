import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

/// Bottom navigation bar with glassmorphism styling matching the
/// `glass-nav` design reference (Chats, Calls, Camera, Profile).
class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Icons.chat_bubble, label: 'Chats'),
    _NavItem(icon: Icons.call, label: 'Calls'),
    _NavItem(icon: Icons.photo_camera, label: 'Camera'),
    _NavItem(icon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: AppDecorations.glassNav(),
          padding: const EdgeInsets.only(top: 12, bottom: 20),
          child: Row(
            children: List.generate(_items.length, (index) {
              final isActive = index == currentIndex;
              final item = _items[index];

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon container
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 32,
                        width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isActive
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                        ),
                        child: Icon(
                          item.icon,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.white50,
                          size: 24,
                          shadows: isActive
                              ? [
                                  Shadow(
                                    color: AppColors.primary.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Label
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.white50,
                          shadows: isActive
                              ? [
                                  Shadow(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    blurRadius: 5,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

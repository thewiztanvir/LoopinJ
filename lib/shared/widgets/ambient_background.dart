import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Background widget with ambient glow orbs matching the design reference
/// decorative background elements (blurred circles of purple, cyan, pink).
class AmbientBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final List<AmbientOrb> orbs;

  const AmbientBackground({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.background,
    this.orbs = const [],
  });

  /// Convenience constructor with the most common layout from designs.
  factory AmbientBackground.standard({
    Key? key,
    required Widget child,
    Color backgroundColor = AppColors.background,
  }) {
    return AmbientBackground(
      key: key,
      backgroundColor: backgroundColor,
      orbs: const [
        AmbientOrb(
          color: Color(0x26A855F7), // purple/15
          top: -0.1,
          left: -0.1,
          size: 300,
          blur: 120,
        ),
        AmbientOrb(
          color: Color(0x1A00FFFF), // cyan/10
          bottom: -0.1,
          right: -0.1,
          size: 250,
          blur: 100,
        ),
        AmbientOrb(
          color: Color(0x14312E81), // indigo/8
          top: 0.4,
          left: 0.2,
          size: 200,
          blur: 80,
        ),
      ],
      child: child,
    );
  }

  /// Variant for the chat dashboard with 3 orbs.
  factory AmbientBackground.dashboard({
    Key? key,
    required Widget child,
  }) {
    return AmbientBackground(
      key: key,
      backgroundColor: AppColors.background,
      orbs: const [
        AmbientOrb(
          color: Color(0x1A00FFFF),
          top: -0.08,
          left: -0.08,
          size: 260,
          blur: 80,
        ),
        AmbientOrb(
          color: Color(0x1AA855F7),
          top: 0.5,
          right: -0.08,
          size: 320,
          blur: 100,
        ),
        AmbientOrb(
          color: Color(0x1AFF00FF),
          bottom: -0.08,
          left: 0.25,
          size: 260,
          blur: 80,
        ),
      ],
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Stack(
        children: [
          // Background color
          Positioned.fill(child: Container(color: backgroundColor)),
          // Glow orbs
          for (final orb in orbs)
            Positioned(
              top: orb.top != null
                  ? MediaQuery.of(context).size.height * orb.top!
                  : null,
              bottom: orb.bottom != null
                  ? MediaQuery.of(context).size.height * orb.bottom!
                  : null,
              left: orb.left != null
                  ? MediaQuery.of(context).size.width * orb.left!
                  : null,
              right: orb.right != null
                  ? MediaQuery.of(context).size.width * orb.right!
                  : null,
              child: IgnorePointer(
                child: Container(
                  width: orb.size,
                  height: orb.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: orb.color,
                    boxShadow: [
                      BoxShadow(
                        color: orb.color,
                        blurRadius: orb.blur,
                        spreadRadius: orb.blur * 0.3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Content
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class AmbientOrb {
  final Color color;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final double blur;

  const AmbientOrb({
    required this.color,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.blur,
  });
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

/// Pill-shaped glass input field matching the design `glass-input` class.
/// Features: rounded-full shape, dark translucent bg, cyan border on focus,
/// neon glow on focus, prefix icon.
class GlassTextField extends StatefulWidget {
  final String hintText;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool isPassword;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const GlassTextField({
    super.key,
    required this.hintText,
    this.label,
    this.prefixIcon,
    this.suffix,
    this.isPassword = false,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.autofocus = false,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _obscured = true;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              widget.label!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        Focus(
          onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: AppDecorations.glassInput(focused: _focused),
                child: TextFormField(
                  controller: widget.controller,
                  obscureText: widget.isPassword && _obscured,
                  validator: widget.validator,
                  keyboardType: widget.keyboardType,
                  onChanged: widget.onChanged,
                  autofocus: widget.autofocus,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w300,
                    ),
                    prefixIcon: widget.prefixIcon != null
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16, right: 12),
                            child: Icon(
                              widget.prefixIcon,
                              color: _focused
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.7),
                              size: 22,
                            ),
                          )
                        : null,
                    prefixIconConstraints: const BoxConstraints(minWidth: 0),
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            icon: Icon(
                              _obscured
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscured = !_obscured),
                          )
                        : widget.suffix,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

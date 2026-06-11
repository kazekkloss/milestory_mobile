import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class LogoWidget extends StatelessWidget {
  final bool _compact;

  const LogoWidget({super.key}) : _compact = false;

  const LogoWidget.compact({super.key}) : _compact = true;

  @override
  Widget build(BuildContext context) {
    return _compact ? _buildCompact(context) : _buildFull(context);
  }

  // ─────────────────────────────────────────────────────────────────
  // Large logo — Row: image + "MileStory"
  // ─────────────────────────────────────────────────────────────────

  Widget _buildFull(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo_milestory3.png',
          height: 42,
          errorBuilder: (_, __, ___) => Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.accent),
            alignment: Alignment.center,
            child: Text(
              'M',
              style: TextStyle(
                fontFamily: AppColors.fontDisplay,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: c.bg,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsetsGeometry.only(top: 6.0),
          child: Text(
            'MileStory',
            style: TextStyle(
              fontFamily: AppColors.fontDisplay,
              fontSize: 26,
              fontWeight: FontWeight.w400,
              color: c.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Small logo — Column: image
  // ─────────────────────────────────────────────────────────────────

  Widget _buildCompact(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo_milestory3.png',
          height: 30,
          errorBuilder: (_, __, ___) => Container(
            width: 28,
            height: 30,
            decoration: BoxDecoration(
              color: c.accent,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              'M',
              style: TextStyle(
                fontFamily: AppColors.fontDisplay,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: c.bg,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

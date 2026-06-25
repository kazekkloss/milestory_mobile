import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core_export.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SizeConfig.horizontalPadding),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.accentBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _link(
                'Polityka prywatności',
                'https://milestory.pl/privacy_policy_creator.html',
                c,
                tt,
              ),
              _link(
                'Regulamin',
                'https://milestory.pl/regulations_creator.html',
                c,
                tt,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2025 MileStory. All rights reserved.',
                style: tt.labelSmall!.copyWith(fontSize: 12),
              ),
              Row(
                children: [
                  _social(
                    FontAwesomeIcons.instagram,
                    'https://instagram.com/milestory.pl',
                    c,
                  ),
                  _social(
                    FontAwesomeIcons.facebook,
                    'https://facebook.com/milestory',
                    c,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _link(String label, String url, AppColors c, TextTheme tt) =>
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => launchUrl(Uri.parse(url)),
          child: Text(
            label,
            style: tt.labelSmall!.copyWith(
              fontSize: 13,
              color: c.textSecondary,
            ),
          ),
        ),
      );

  Widget _social(FaIconData icon, String url, AppColors c) => GestureDetector(
    onTap: () => launchUrl(Uri.parse(url)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: FaIcon(icon, color: c.textPrimary, size: 15),
    ),
  );
}

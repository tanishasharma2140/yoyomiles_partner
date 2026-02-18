import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'constant_color.dart';

class OwnerDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const OwnerDetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: PortColor.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextConst(title:
            loc.owner_details,
            size: Sizes.fontSizeSeven,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
      shape: Border(
        bottom: BorderSide(
          color: PortColor.gray,
          width: Sizes.screenWidth * 0.001,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(Sizes.screenHeight * 0.05);
}

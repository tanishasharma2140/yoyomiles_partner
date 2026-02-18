import 'package:flutter/cupertino.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';

class YoyomilesPartnerCon with ChangeNotifier {

  List<DashBoardModel> dashBoardGridList = [
    DashBoardModel(
        img: Assets.assetsDriverProfile,
        titleKey: 'profile',
        route: RoutesName.editProfile),

    DashBoardModel(
        img: Assets.assetsRideHistoryDriver,
        titleKey: 'ride_history',
        route: RoutesName.rideHistory),

    DashBoardModel(
        img: Assets.assetsWalletSettlement,
        titleKey: 'wallet_and_settlement',
        route: RoutesName.walletSettlement),

    DashBoardModel(
        img: Assets.assetsEarning,
        titleKey: 'earning_report',
        route: RoutesName.earningReport),
  ];
}

class DashBoardModel {
  final String img;
  final String titleKey;
  final String route;

  DashBoardModel({
    required this.img,
    required this.titleKey,
    required this.route,
  });
}

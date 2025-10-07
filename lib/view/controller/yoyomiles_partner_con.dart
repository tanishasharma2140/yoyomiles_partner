import 'package:flutter/cupertino.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';

class YoyomilesPartnerCon with ChangeNotifier {
  List<DashBoardModel> dashBoardGridList = [
    DashBoardModel(img: Assets.assetsEditprofile,
        title: ' Profile',
        route: RoutesName.editProfile),
    DashBoardModel(img: Assets.assetsTruck,
        title: 'Ride History',
        route: RoutesName.rideHistory),
    DashBoardModel(img: Assets.assetsWalletHistory,
        title: 'Wallet',
        route: RoutesName.wallet),
    DashBoardModel(
        img: Assets.assetsReward, title: 'Reward', route: RoutesName.reward),
  ];
}
class DashBoardModel{
  final String img;
  final String title;
  final String route;
  DashBoardModel({required this.img, required this.title, required this.route});
}
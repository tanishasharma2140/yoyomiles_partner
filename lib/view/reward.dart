// import 'package:flutter/material.dart';
// import 'package:yoyomiles_partner/generated/assets.dart';
// import 'package:yoyomiles_partner/res/constant_color.dart';
// import 'package:yoyomiles_partner/res/sizing_const.dart';
// import 'package:yoyomiles_partner/res/text_const.dart';
//
// class Reward extends StatefulWidget {
//   const Reward({super.key});
//
//   @override
//   State<Reward> createState() => _RewardState();
// }
//
// class _RewardState extends State<Reward> {
//   final List<Map<String, String>> rewardData = [
//     {"title": "Customer Exp", "points": "3482"},
//     {"title": "Login Reward", "points": "1293"},
//     {"title": "Bonus Reward", "points": "1450"},
//   ];
//   final List<Map<String, dynamic>> items = [
//     {
//       'icon': Icons.dashboard_customize_outlined,
//       'label': "Customer\nExperience",
//       'color': PortColor.reward,
//     },
//     {
//       'icon': Icons.local_activity,
//       'label': "Login\nActivity",
//       'color': PortColor.coin,
//     },
//     {
//       'icon': Icons.apps_outage_outlined,
//       'label': "Activity",
//       'color': PortColor.rewardCoin,
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: PortColor.scaffoldBgGrey,
//       body: Column(
//         children: [
//           SizedBox(height: Sizes.screenHeight*0.025,),
//           Container(
//             padding: EdgeInsets.symmetric(
//                 horizontal: Sizes.screenWidth * 0.002,
//                 vertical: Sizes.screenHeight * 0.03),
//             decoration: BoxDecoration(
//               color: Colors.blue.withOpacity(0.1),
//               borderRadius: const BorderRadius.only(
//                   bottomRight: Radius.circular(15),
//                   bottomLeft: Radius.circular(15)),
//             ),
//             child: Column(
//               children: [
//                 const TextConst(
//                   title:
//                   "Total Reward Point",
//                   fontWeight: FontWeight.bold,
//                 ),
//                 TextConst(
//                   title:
//                   "5,382",
//                   fontWeight: FontWeight.bold,
//                   size: Sizes.fontSizeEight,
//                 ),
//                 SizedBox(
//                   height: Sizes.screenHeight * 0.015,
//                 ),
//                 SizedBox(
//                   height: Sizes.screenHeight * 0.09,
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: rewardData.length,
//                     itemBuilder: (context, index) {
//                       final data = rewardData[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(left: 8.0),
//                         child: Container(
//                           width: Sizes.screenWidth * 0.35,
//                           decoration: BoxDecoration(
//                             color: PortColor.white,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 TextConst(
//                                   title:
//                                   data["title"] ?? "",
//                                   color: PortColor.gray,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 TextConst(
//                                   title:
//                                   data["points"] ?? "",
//                                   fontWeight: FontWeight.bold,
//                                   size: Sizes.fontSizeEight,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(
//                   height: Sizes.screenHeight * 0.019,
//                 ),
//                 const TextConst(title: "Reach new levels and win exiciting gift 🎁"),
//                 SizedBox(
//                   height: Sizes.screenHeight * 0.03,
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     // First Circle with Image
//                     Container(
//                       height: 50,
//                       width: 50,
//                       decoration: const BoxDecoration(
//                         color: PortColor.white,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Image.asset(Assets.assetsRewardStarCoin),
//                     ),
//                     Container(
//                       height: Sizes.screenHeight * 0.0022,
//                       width: Sizes.screenWidth * 0.6,
//                       color: PortColor.gray,
//                     ),
//                     Container(
//                       height: 50,
//                       width: 50,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: PortColor.gray),
//                         color: PortColor.grey,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Image.asset(Assets.assetsKingFairy),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: Sizes.screenWidth * 0.045),
//                   child: const Row(
//                     children: [
//                       Column(
//                         children: [
//                           TextConst(
//                             title:
//                             "Star",
//                             fontWeight: FontWeight.bold,
//                           ),
//                           TextConst(
//                             title:
//                             "Level 1",
//                             color: PortColor.gray,
//                           ),
//                         ],
//                       ),
//                       Spacer(),
//                       Column(
//                         children: [
//                           TextConst(
//                             title:
//                             "SuperStar",
//                             fontWeight: FontWeight.bold,
//                           ),
//                           TextConst(
//                             title:
//                             "Level 2",
//                             color: PortColor.gray,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding:
//                 EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.05),
//             height: Sizes.screenHeight * 0.07,
//             color: PortColor.white,
//             child: Row(
//               children: [
//                 Image.asset(Assets.assetsTruck),
//                 SizedBox(
//                   width: Sizes.screenWidth * 0.02,
//                 ),
//                 const TextConst(title: "Win a mini truck as a"),
//                 SizedBox(
//                   width: Sizes.screenWidth * 0.02,
//                 ),
//                 const TextConst(
//                   title:
//                   "Bumper Price!",
//                   fontWeight: FontWeight.bold,
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(
//             height: Sizes.screenHeight * 0.02,
//           ),
//           Padding(
//             padding:
//                 EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.03),
//             child: Row(
//               children: [
//                 TextConst(
//                   title:
//                   "Daily Rewards",
//                   fontWeight: FontWeight.bold,
//                   size: Sizes.fontSizeSix,
//                 ),
//                 Container(
//                   margin: EdgeInsets.symmetric(
//                       horizontal: Sizes.screenWidth * 0.02),
//                   height: Sizes.screenHeight * 0.001,
//                   width: Sizes.screenWidth * 0.6,
//                   color: PortColor.grey,
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(
//             height: Sizes.screenHeight * 0.02,
//           ),
//           Container(
//             padding:
//                 EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.02),
//             height: Sizes.screenHeight * 0.25,
//             child: ListView.builder(
//               shrinkWrap: true,
//               scrollDirection: Axis.horizontal,
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 final item = items[index];
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 10),
//                   child: Container(
//                     alignment: Alignment.center,
//                     height: Sizes.screenHeight * 0.22,
//                     width: Sizes.screenWidth * 0.36,
//                     decoration: BoxDecoration(
//                       color: item['color'],
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(item['icon']),
//                         TextConst(title: item['label']),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

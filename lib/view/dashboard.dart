import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view/controller/yoyomiles_partner_con.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});




  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  @override
  Widget build(BuildContext context) {
    return Consumer<YoyomilesPartnerCon>(builder: (context, ppc, child) {
      return Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        body: SizedBox(
          height: Sizes.screenHeight,
          width: Sizes.screenWidth,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: Sizes.screenHeight * 0.37,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PortColor.partner,
                          PortColor.porterPartner,
                          PortColor.purple,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 40, 10, 10),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextConst(
                                title:
                                "My Dashboard",
                                color: PortColor.white,
                                size: Sizes.fontSizeEight,
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(height: Sizes.screenHeight * 0.007),
                              TextConst(
                                title:
                                "Wallet",
                                color: PortColor.white,
                                size: Sizes.fontSizeSix,
                              ),
                            ],
                          ),
                        ),
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(Assets.assetsProfile),
                        ),
                      ],
                    ),
                    SizedBox(height: Sizes.screenHeight * 0.1),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.9,
                        ),
                        shrinkWrap: true,
                        itemCount: ppc.dashBoardGridList.length,
                        itemBuilder: (BuildContext context, index) {
                          final res = ppc.dashBoardGridList[index];
                          return GestureDetector(
                            onTap: () {
                              if (res.route != '') {
                                Navigator.pushNamed(context, res.route);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: Sizes.screenHeight * 0.07,
                                    width: Sizes.screenWidth * 0.13,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(res.img),
                                          fit: BoxFit.fill),
                                    ),
                                  ),
                                  SizedBox(height: Sizes.screenHeight * 0.014),
                                  TextConst(
                                    title:
                                    res.title,
                                    size: Sizes.fontSizeSix,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(height: Sizes.screenHeight * 0.015),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          PortColor.partner,
                                          PortColor.porterPartner,
                                          PortColor.purple,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: const Center(
                                        child: Icon(Icons.arrow_forward,
                                            color: PortColor.white, size: 16)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            gradient: LinearGradient(
              colors: [
                PortColor.partner,
                PortColor.porterPartner,
                PortColor.purple,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: PortColor.scaffoldBgGrey,
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (BuildContext context) {
                  return Padding(
                    padding: EdgeInsets.all(Sizes.screenHeight * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const TextConst(
                          title:
                          "Are you sure you want to log out?",
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: Sizes.screenHeight * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: Sizes.screenHeight * 0.058,
                                width: Sizes.screenWidth * 0.4,
                                decoration: BoxDecoration(
                                  color: PortColor.white,
                                  border: Border.all(
                                      color: PortColor.blue, width: 2),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20)),
                                ),
                                child: const Center(
                                  child: TextConst(   title: "No",
                                      fontWeight: FontWeight.bold,
                                      color: PortColor.partner),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: Sizes.screenWidth * 0.02,
                            ),
                            Container(
                              height: Sizes.screenHeight * 0.058,
                              width: Sizes.screenWidth * 0.4,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: PortColor.blue, width: 2),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(20)),
                              ),
                              child: const Center(
                                child: TextConst(
                                  title:
                                  "Yes",
                                  fontWeight: FontWeight.bold,
                                  color: PortColor.partner,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            backgroundColor: Colors.transparent,
            child: const Icon(
              Icons.logout,
              color: PortColor.white,
            ),
          ),
        ),
      );
    });
  }
}

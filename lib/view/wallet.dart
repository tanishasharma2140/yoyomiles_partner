import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/view/earning/daily_weekly_earning_report.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});
  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  void _showWithdrawBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: Sizes.screenWidth * 0.04,
              vertical: Sizes.screenHeight * 0.018),
          height: Sizes.screenHeight * 0.3,
          width: Sizes.screenWidth,
          decoration: BoxDecoration(
            color: PortColor.white,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextConst(
                title:
                "Withdraw cash",
                fontWeight: FontWeight.bold,
                size: Sizes.fontSizeSix,
              ),
              SizedBox(
                height: Sizes.screenHeight * 0.018,
              ),
              TextConst(
                title:
                "Withdrawable Amount",
                size: Sizes.fontSizeFive,
              ),
              SizedBox(
                height: Sizes.screenHeight * 0.001,
              ),
              TextConst(
                title:
                "₹200.00",
                fontWeight: FontWeight.bold,
                size: Sizes.fontSizeSeven,
              ),
              SizedBox(
                height: Sizes.screenHeight * 0.02,
              ),
              TextConst(title: "Minimum Wallet balance ₹200.0",
                  fontWeight: FontWeight.bold,
                  size: Sizes.fontSizeFour,
                  color: PortColor.gray),
              SizedBox(
                height: Sizes.screenHeight * 0.05,
              ),
              Container(
                width: Sizes.screenWidth,
                decoration: BoxDecoration(
                  color: PortColor.partner,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: TextConst(
                    title:
                    'Withdraw ₹200.0',
                    color: PortColor.white,
                    size: Sizes.fontSizeSeven,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortColor.scaffoldBgGrey,
      body: Column(
        children: [
          SizedBox(height: Sizes.screenHeight*0.025,),

          Container(
            height: Sizes.screenHeight * 0.08,
            decoration: const BoxDecoration(color: PortColor.white),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                  ),
                ),
                TextConst(
                  title:
                  "Wallet",
                  size: Sizes.fontSizeEight,
                  fontWeight: FontWeight.bold,
                ),
                const Spacer(),
                Row(
                  children: [
                     GestureDetector(
                         onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (context)=>DailyWeeklyEarningReport()));
                           // Navigator.pushNamed(context, RoutesName.bank);
                         },
                         child: Image(image: AssetImage(Assets.assetsAddDetail),height: Sizes.screenHeight*0.05,width: Sizes.screenWidth*0.08,)),
                    SizedBox(width: Sizes.screenWidth*0.035,),
                    GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(context, RoutesName.bankDetail);
                        },
                        child: Image(image: AssetImage(Assets.assetsBank))),
                  ],
                ),
                SizedBox(width: Sizes.screenWidth*0.03,),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.bottomLeft,
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: Sizes.screenWidth * 0.05,
                    vertical: Sizes.screenWidth * 0.03),
                height: Sizes.screenHeight * 0.15,
                color: Colors.blue.withOpacity(0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextConst(
                          title:
                          "Balance",
                          size: Sizes.fontSizeSeven,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(
                          width: Sizes.screenWidth * 0.07,
                        ),
                        TextConst(
                          title:
                          "₹",
                          size: Sizes.fontSizeSeven,
                          fontWeight: FontWeight.bold,
                        ),
                        TextConst(
                          title:
                          "700.",
                          size: Sizes.fontSizeEight,
                          fontWeight: FontWeight.bold,
                        ),
                        TextConst(
                          title:
                          "06",
                          size: Sizes.fontSizeEight,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Sizes.screenHeight * 0.003,
                    ),
                    Row(
                      children: [
                        TextConst(title: "Minimum Balance",
                            size: Sizes.fontSizeFour),
                        SizedBox(
                          width: Sizes.screenWidth * 0.05,
                        ),
                        TextConst(title: "₹500.0", size: Sizes.fontSizeFour),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: Sizes.screenHeight * -0.025,
                left: Sizes.screenWidth * 0.05,
                child: GestureDetector(
                  onTap: _showWithdrawBottomSheet,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Sizes.screenWidth * 0.025,
                        vertical: Sizes.screenHeight * 0.01),
                    decoration: BoxDecoration(
                      color: PortColor.yellow,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: Colors.brown,
                        width: Sizes.screenWidth * 0.003,
                      ),
                    ),
                    child: TextConst(
                      title:
                      'Withdraw ₹200.0',
                      color: Colors.brown,
                      size: Sizes.fontSizeSix,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: Sizes.screenHeight * 0.04,
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.035),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Sizes.screenWidth * 0.02,
                  vertical: Sizes.screenHeight * 0.01),
              color: PortColor.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextConst(
                        title:
                        "Trip to Koramangla",
                        size: Sizes.fontSizeSix,
                        fontWeight: FontWeight.bold,
                      ),
                      const Spacer(),
                      TextConst(
                        title:
                        "+ ",
                        size: Sizes.fontSizeFive,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      TextConst(title: "₹100.0",
                          size: Sizes.fontSizeSix,
                          fontWeight: FontWeight.bold),
                    ],
                  ),
                  const TextConst(
                    title:
                    "Today,5:30pm",
                    color: PortColor.gray,
                  ),
                  Divider(
                    thickness: Sizes.screenWidth * 0.001,
                    color: PortColor.gray,
                  ),
                  SizedBox(
                    height: Sizes.screenHeight * 0.01,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextConst(
                            title:
                            "Trip to Jp nagar",
                            size: Sizes.fontSizeSix,
                            fontWeight: FontWeight.bold,
                          ),
                          const Spacer(),
                          TextConst(
                            title:
                            "+ ",
                            size: Sizes.fontSizeFive,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          TextConst(title: "₹1000.0",
                              size: Sizes.fontSizeSix,
                              fontWeight: FontWeight.bold),
                        ],
                      ),
                      Row(
                        children: [
                          const TextConst(
                            title:
                            "Today,12:10pm",
                            color: PortColor.gray,
                          ),
                          const Spacer(),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: PortColor.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(
                            width: Sizes.screenWidth * 0.02,
                          ),
                          const TextConst(
                            title:
                            "Pending",
                            color: PortColor.gray,
                          ),
                        ],
                      ),
                      Divider(
                        thickness: Sizes.screenWidth * 0.001,
                        color: PortColor.gray,
                      ),
                      SizedBox(
                        height: Sizes.screenHeight * 0.01,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.02),
            height: Sizes.screenHeight * 0.06,
            color: PortColor.grey,
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: Sizes.screenWidth * 0.02,
                ),
                const TextConst(
                  title:
                  "Know more",
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(
                  width: Sizes.screenWidth * 0.02,
                ),
                const TextConst(title: "about Pending transactions ",
                    color: PortColor.gray)
              ],
            ),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.035),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Sizes.screenWidth * 0.02,
                  vertical: Sizes.screenHeight * 0.01),
              color: PortColor.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextConst(
                        title:
                        "Login Incentive",
                        size: Sizes.fontSizeSix,
                        fontWeight: FontWeight.bold,
                      ),
                      const Spacer(),
                      TextConst(
                        title:
                        "+ ",
                        size: Sizes.fontSizeFive,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      TextConst(title: "₹50.0",
                          size: Sizes.fontSizeSix,
                          fontWeight: FontWeight.bold),
                    ],
                  ),
                  const TextConst(
                    title:
                    "yesterday,8:00pm",
                    color: PortColor.gray,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

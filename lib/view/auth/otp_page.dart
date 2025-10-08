import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/main.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Map arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      Provider.of<AuthViewModel>(context, listen: false)
          .sendOtpApi(arguments["mobileNumber"], context);
    });

    _startTimer();
  }

  int _timerCountdown = 0;
  Timer? _timer;

  void _startTimer() {
    setState(() {
      _timerCountdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerCountdown > 0) {
        setState(() {
          _timerCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    Map arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: PortColor.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topPadding,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Assets.assetsYoyoPartnerLogo,
                  height: Sizes.screenHeight * 0.07,
                  width: Sizes.screenWidth*0.55,
                  fit: BoxFit.contain,
                )
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.04),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextConst(title: arguments["mobileNumber"]),
                SizedBox(width: Sizes.screenWidth * 0.02),
                const TextConst(
                  title:
                  "Change",
                  color: PortColor.blue,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            SizedBox(height: Sizes.screenHeight * 0.03),
            Center(
              child: TextConst(
                title:
                "One Time Password (OTP) is sent to this number",
                color: PortColor.black.withOpacity(0.5),
              ),
            ),
            SizedBox(height: Sizes.screenHeight * 0.07),
            TextConst(
              title:
              "Enter OTP",
              color: PortColor.black.withOpacity(0.5),
            ),
             TextField(
              controller:_otpController,
              cursorColor: PortColor.gray,
              textAlign: TextAlign.center,
              maxLength: 4,
               inputFormatters: [
                 FilteringTextInputFormatter.digitsOnly,
               ],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                counterText: "",
                hintStyle: TextStyle(color: PortColor.gray),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: PortColor.gray),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: PortColor.gray),
                ),
              ),
            ),
            SizedBox(height: Sizes.screenHeight * 0.04),
            GestureDetector(
              onTap: _otpController.text.trim().length == 4 &&
                  int.tryParse(_otpController.text.trim()) != null
                  ? () {
                final enteredOtp = _otpController.text.trim();
                authViewModel.verifyOtpApi(
                    arguments["mobileNumber"], enteredOtp, arguments["user_id"], context);
              }
                  : null,
              child: Container(
                height: Sizes.screenHeight * 0.06,
                decoration: BoxDecoration(
                  color: (_otpController.text.trim().length == 4 &&
                      int.tryParse(_otpController.text.trim()) != null)
                      ? PortColor.gold
                      : PortColor.grey,
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: !authViewModel.otpLoading ?TextConst(
                  title:
                  "VERIFY",
                  fontFamily: AppFonts.kanitReg,
                  color: (_otpController.text.trim().length == 4 &&
                      int.tryParse(_otpController.text.trim()) != null)
                      ? PortColor.black
                      : Colors.black,
                  size: Sizes.fontSizeSeven,
                  fontWeight: FontWeight.w400,
                ):  CupertinoActivityIndicator(color: PortColor.black, radius: 12),
              ),
            ),

            SizedBox(height: Sizes.screenHeight * 0.03),
            Center(
              child: GestureDetector(
                onTap: _timerCountdown == 0
                    ? () {
                        _startTimer();
                      }
                    : null,
                child: TextConst(
                  title:
                  _timerCountdown > 0
                      ? "RESEND OTP ($_timerCountdown s)"
                      : "RESEND OTP",
                  color: _timerCountdown > 0 ? PortColor.blue : PortColor.blue,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoyomiles_partner/controller/language_controller.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/main.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view/video_player_screen.dart';
import 'package:yoyomiles_partner/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/video_view_model.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isTermsAgreed = false;
  bool isTDSAgreed = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VideoViewModel>(context, listen: false).videoApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<AuthViewModel>(context);
    final videoVm = Provider.of<VideoViewModel>(context);
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.055),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: topPadding),
                // 🔽 LANGUAGE DROPDOWN (TOP RIGHT)
                Align(
                  alignment: Alignment.topRight,
                  child: Consumer<LanguageController>(
                    builder: (context, languageProvider, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            )
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: languageProvider.currentLanguageCode,
                            dropdownColor: Colors.white,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: PortColor.blue,
                            ),
                            style: const TextStyle(
                              color: PortColor.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text("English"),
                              ),
                              DropdownMenuItem(
                                value: 'hi',
                                child: Text("Hindi"),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == 'en') {
                                languageProvider.changeLanguage(const Locale('en'));
                              } else if (value == 'hi') {
                                languageProvider.changeLanguage(const Locale('hi'));
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: Sizes.screenHeight * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.assetsYoyoPartnerLogo,
                      height: Sizes.screenHeight * 0.07,
                      width: Sizes.screenWidth * 0.65,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                SizedBox(height: Sizes.screenHeight * 0.02),
                Center(
                  child: Container(
                    height: Sizes.screenHeight * 0.05,
                    width: Sizes.screenWidth * 0.35,
                    decoration: BoxDecoration(
                      // color: Colors.blue[50],
                      color: PortColor.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          Assets.assetsIndiaimage,
                          height: Sizes.screenHeight * 0.04,
                        ),
                        TextConst(
                          title: loc.india,
                          size: Sizes.fontSizeFive,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(width: Sizes.screenWidth * 0.015),
                        TextConst(
                          title: loc.change,
                          size: Sizes.fontSizeFive,
                          fontWeight: FontWeight.w600,
                          color: PortColor.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Sizes.screenHeight * 0.1),
                TextConst(
                  title: loc.mob_no,
                  color: PortColor.black.withOpacity(0.5),
                  size: Sizes.fontSizeSix,
                ),
                TextField(
                  controller: loginViewModel.phoneController,
                  cursorColor: PortColor.gray,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    FilteringTextInputFormatter.deny(RegExp(r'^[0-5]')),
                  ],
                  decoration: InputDecoration(
                    counterText: "",
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Text(
                          '+91',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: Sizes.screenWidth * 0.02),
                        Container(
                          height: Sizes.screenHeight * 0.03,
                          width: Sizes.screenWidth * 0.005,
                          color: PortColor.gray,
                        ),
                      ],
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: PortColor.gray),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: PortColor.gray),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: PortColor.gray),
                    ),
                    contentPadding: const EdgeInsets.only(top: 12),
                  ),
                ),
                SizedBox(height: Sizes.screenHeight * 0.035),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isTermsAgreed = !isTermsAgreed;
                        });
                      },
                      child: Container(
                        height: Sizes.screenHeight * 0.025,
                        width: Sizes.screenWidth * 0.056,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PortColor.blue,
                            width: Sizes.screenWidth * 0.004,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: isTermsAgreed
                              ? PortColor.blue
                              : Colors.transparent,
                        ),
                        child: isTermsAgreed
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: Sizes.screenHeight * 0.02,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: Sizes.screenWidth * 0.029),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: loc.i_have_read,
                          style: TextStyle(
                            color: PortColor.black.withOpacity(0.7),
                            fontFamily: AppFonts.kanitReg,
                          ),
                          children: [
                            TextSpan(
                              text: loc.terms_condition,
                              style: TextStyle(
                                color: PortColor.blue,
                                fontFamily: AppFonts.kanitReg,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.termsCondition,
                                  );
                                },
                            ),
                            TextSpan(
                              text: loc.and,
                              style: TextStyle(
                                color: PortColor.black.withOpacity(0.7),
                                fontFamily: AppFonts.kanitReg,
                              ),
                            ),
                            TextSpan(
                              text: loc.privacy_policy,
                              style: TextStyle(
                                color: PortColor.blue,
                                fontFamily: AppFonts.kanitReg,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.privacyPolicy,
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Sizes.screenHeight * 0.035),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isTDSAgreed = !isTDSAgreed;
                        });
                      },
                      child: Container(
                        height: Sizes.screenHeight * 0.025,
                        width: Sizes.screenWidth * 0.056,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PortColor.blue,
                            width: Sizes.screenWidth * 0.004,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: isTDSAgreed ? PortColor.blue : Colors.transparent,
                        ),
                        child: isTDSAgreed
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: Sizes.screenHeight * 0.02,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(width: Sizes.screenWidth * 0.025),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: loc.i_have_read_hereby,
                          style: TextStyle(
                            color: PortColor.black.withOpacity(0.7),
                            fontFamily: AppFonts.kanitReg,
                          ),
                          children: [
                            TextSpan(
                              text: loc.tds_declaration,
                              style: TextStyle(
                                color: PortColor.blue,
                                fontFamily: AppFonts.kanitReg,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.tdsDeclaration,
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Sizes.screenHeight * 0.035),
                GestureDetector(
                  onTap: () {
                    if (isTermsAgreed && isTDSAgreed) {
                      if (loginViewModel.phoneController.text.length == 10 &&
                          RegExp(r'^\d{10}$').hasMatch(loginViewModel.phoneController.text)) {
                        final loginViewModel = Provider.of<AuthViewModel>(
                          context,
                          listen: false,
                        );
                        loginViewModel.otpSentApi(loginViewModel.phoneController.text, context);
                      } else {
                        Utils.showErrorMessage(
                          context,
                          loc.please_enter_valid_ten,
                        );
                      }
                    } else {
                      Utils.showErrorMessage(
                        context,
                        loc.please_agree_to_all
                      );
                    }
                  },
                  child: Container(
                    height: Sizes.screenHeight * 0.06,
                    decoration: BoxDecoration(
                      color: (isTermsAgreed && isTDSAgreed)
                          ? PortColor.gold
                          : PortColor.grey,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: !loginViewModel.loading
                        ? TextConst(
                            title: loc.login,
                            color: PortColor.black,
                            size: Sizes.fontSizeSeven,
                            fontWeight: FontWeight.w400,
                          )
                        : CupertinoActivityIndicator(color: PortColor.white, radius: 12),
                  ),
                ),
                SizedBox(height: Sizes.screenHeight * 0.1),

                GestureDetector(
                  onTap: () {
                    final videoUrl = videoVm.videoModel?.data?.videoUrl;

                    if (videoUrl != null && videoUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(videoUrl: videoUrl),
                        ),
                      );
                    } else {
                      Utils.showErrorMessage(context, loc.video_not_available);
                    }
                  },
                  child: Container(
                    height: Sizes.screenHeight * 0.13,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: PortColor.blue.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        // LEFT CONTENT
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextConst(
                                  title:
                                  loc.watch_this_video,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  size: Sizes.fontSizeFive,
                                  color: Colors.black54,
                                ),

                                const SizedBox(height: 10),

                                // CTA
                                Row(
                                  children: [
                                    TextConst(
                                      title:
                                      loc.watch_video,
                                      size: Sizes.fontSizeSix,
                                      color: PortColor.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: PortColor.blue,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            child: videoVm.loading
                                ? const Center(child: CupertinoActivityIndicator())
                                : Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  videoVm.videoModel?.data?.imageUrl ?? "",
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                                ),

                                // ▶️ Play Icon Overlay
                                const Center(
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}

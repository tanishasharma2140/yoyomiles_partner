import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view/refer/driver_referral_history.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';

class ReferAndEarn extends StatefulWidget {
  const ReferAndEarn({super.key});

  @override
  State<ReferAndEarn> createState() => _ReferAndEarnState();
}

class _ReferAndEarnState extends State<ReferAndEarn> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = Provider.of<ProfileViewModel>(context, listen: false);
      profileViewModel.profileApi(context);
    });
    super.initState();
  }

  bool _copied = false;

  void _copyCode() {
    final profile = Provider.of<ProfileViewModel>(context,listen: false);
    Clipboard.setData(ClipboardData(text: profile.profileModel?.data?.referralCode??"N/A"));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final profile = Provider.of<ProfileViewModel>(context);
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.bgColor,
        appBar: AppBar(
          backgroundColor: PortColor.white,
          elevation: 0,
          leading:  BackButton(color: Colors.black),
          title:  TextConst(
            title:
            loc.refer_n_earn,
            color: Colors.black,
            fontWeight: FontWeight.w700,
            size: 18,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.black),
              onPressed: () {
               Navigator.push(context, CupertinoPageRoute(builder: (context)=> DriverReferralHistory()));
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10,),
               referCard(context),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: PortColor.gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.confirmation_number_outlined,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                           SizedBox(width: 10),
                           TextConst(
                             title:
                            loc.your_referral_code,
                             size: 14,
                             fontWeight: FontWeight.w700,
                             color: Color(0xFF1A1A1A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: PortColor.bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: PortColor.gold.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextConst(
                              title:
                              profile.profileModel?.data?.referralCode??"N/A",
                              size: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                            GestureDetector(
                              onTap: _copyCode,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _copied ? Colors.green : PortColor.gold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _copied
                                          ? Icons.check_rounded
                                          : Icons.copy_rounded,
                                      size: 15,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 5),
                                    TextConst(
                                      title:
                                      _copied ? loc.copied : loc.copy,
                                      size: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: PortColor.gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                           SizedBox(width: 10),
                           TextConst(
                             title:
                            loc.how_it_work,
                             size: 14,
                             fontWeight: FontWeight.w700,
                             color: Color(0xFF1A1A1A),
                          ),
                        ],
                      ),
                       SizedBox(height: 20),
                      _StepRow(
                        icon: Icons.share_rounded,
                        title: loc.share_your_code,
                        subtitle: loc.sent_your_unique,
                        accentColor: PortColor.gold,
                        showLine: true,
                      ),
                      _StepRow(
                        icon: Icons.person_add_alt_1_rounded,
                        title: loc.friend_sign_up,
                        subtitle: loc.they_register_using_your,
                        accentColor: PortColor.gold,
                        showLine: true,
                      ),
                      _StepRow(
                        icon: Icons.currency_rupee_rounded,
                        title: loc.both_earn_rewards,
                        subtitle: ' ${loc.you_get} ₹${profile.profileModel?.driverReferralAmount??""}',
                        accentColor: PortColor.gold,
                        showLine: false,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Share Button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {

                      String message = profile.profileModel?.driverReferralMessage;

                      Share.share(message);
                    },
                    icon: const Icon(Icons.share_rounded,
                        color: Colors.black, size: 18),
                    label:  TextConst(
                      title: loc.share_and_invite_friends,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      size: 15,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PortColor.gold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),


              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

Widget referCard(BuildContext context) {
  final loc = AppLocalizations.of(context)!;
  final profileVm = Provider.of<ProfileViewModel>(context);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    child: Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          color: PortColor.gold,
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -10,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15,),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.card_giftcard_rounded,
                        size: 36,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 14),

                     TextConst(
                      title: loc.invite_friend_n_earn,
                      size: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                     TextConst(
                      title: loc.refer_friend_and_unlock,
                      textAlign: TextAlign.center,
                      size: 12,
                      color: Color(0xFF4A4A4A),
                    ),

                    const SizedBox(height: 16),

                    _RewardBadge(
                      label: loc.you_earn,
                      amount:
                      "${profileVm.profileModel?.driverReferralAmount ?? 0}₹",
                    ),
                    SizedBox(height: 10,)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}

class _RewardBadge extends StatelessWidget {
  final String label;
  final String amount;

  const _RewardBadge({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextConst(
          title:
          label,
          size: 11,
          color: Color(0xFF555555),
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 2),
        TextConst(
          title:
          amount,
          size: 26,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final bool showLine;

  const _StepRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.showLine,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 20, color: Colors.black),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8E8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8, bottom: showLine ? 0 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConst(
                  title:
                  title,
                  size: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
                const SizedBox(height: 3),
                TextConst(
                  title:
                  subtitle,
                  size: 12,
                  color: Color(0xFF888888),
                ),
                if (showLine) const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
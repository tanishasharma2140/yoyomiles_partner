import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
    final profile = Provider.of<ProfileViewModel>(context);
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.bgColor,
        appBar: AppBar(
          backgroundColor: PortColor.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title:  TextConst(
            title:
            'Refer & Earn',
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
                          const SizedBox(width: 10),
                           TextConst(
                             title:
                            'Your Referral Code',
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
                                      _copied ? 'Copied!' : 'Copy',
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
                          const SizedBox(width: 10),
                           TextConst(
                             title:
                            'How it works',
                             size: 14,
                             fontWeight: FontWeight.w700,
                             color: Color(0xFF1A1A1A),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _StepRow(
                        icon: Icons.share_rounded,
                        title: 'Share your code',
                        subtitle: 'Send your unique code to friends & family',
                        accentColor: PortColor.gold,
                        showLine: true,
                      ),
                      _StepRow(
                        icon: Icons.person_add_alt_1_rounded,
                        title: 'Friend signs up',
                        subtitle: 'They register using your referral code',
                        accentColor: PortColor.gold,
                        showLine: true,
                      ),
                      _StepRow(
                        icon: Icons.currency_rupee_rounded,
                        title: 'Both earn rewards',
                        subtitle: 'You get ₹${profile.profileModel?.driverReferralAmount??""}',
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
                    label: const TextConst(
                      title: 'Share & Invite Friends',
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

Widget referCard(context) {
  final profileVm = Provider.of<ProfileViewModel>(context);
  return Container(
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
        color: PortColor.gold,
        child: Stack(
          children: [
            // Background circles
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

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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

                  const TextConst(
                    title:
                    'Invite Friends & Earn',
                    size: 20, // ↓ slightly smaller
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 6),

                   TextConst(
                     title:
                    'Refer friends and unlock exciting rewards!',
                    textAlign: TextAlign.center,
                     size: 12,
                     color: Color(0xFF4A4A4A),
                  ),

                  const SizedBox(height: 16),

                   _RewardBadge(
                    label: 'You earn',
                    amount: "${profileVm.profileModel?.driverReferralAmount?? 0}Rs",
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Reward Badge ──
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

// ── Share Icon ──
class _ShareIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _ShareIcon({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
        ),
      ],
    );
  }
}

// ── Step Row ──
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
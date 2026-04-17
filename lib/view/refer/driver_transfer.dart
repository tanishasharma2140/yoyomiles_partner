import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/driver_transfer_view_model.dart';

class DriverTransfer extends StatefulWidget {
  final String? rewardWallet;
  const DriverTransfer({super.key, this.rewardWallet});

  @override
  State<DriverTransfer> createState() => _DriverTransferState();
}

class _DriverTransferState extends State<DriverTransfer> {
  int selectedDestination = 0;

  int get type => selectedDestination == 0 ? 2 : 1;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final driverTransfer = Provider.of<DriverTransferViewModel>(context);
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.white,
        appBar: AppBar(
          backgroundColor: PortColor.gold,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black87,
              size: 20,
            ),
          ),
          title: TextConst(
            title: loc.transfer_reward,
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            size: 18,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: PortColor.gold,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: PortColor.gold.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.card_giftcard_rounded,
                      color: Colors.black87,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextConst(
                          title: loc.reward_wallet,
                          color: Colors.black54,
                          size: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 2),
                        TextConst(
                          title: '₹${widget.rewardWallet ?? '0'}',
                          color: Colors.black87,
                          size: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── TRANSFER TO ───
              TextConst(
                title: loc.transfer_to,
                size: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildDestinationTile(
                      label: loc.due_wallet,
                      icon: Icons.account_balance_wallet_rounded,
                      index: 0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDestinationTile(
                      label: loc.main_wallet,
                      icon: Icons.account_balance_rounded,
                      index: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextConst(
                          title: loc.transfer_amount,
                          size: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        TextConst(
                          title: '₹${widget.rewardWallet ?? '0'}',
                          size: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    const SizedBox(height: 10),

                    // ─── Destination Row ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextConst(
                          title: loc.to,
                          size: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        TextConst(
                          title: selectedDestination == 0
                              ? loc.due_wallet
                              : loc.main_wallet,
                          size: 13,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        driverTransfer.transferApi(type, context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: PortColor.blackLight,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.swap_horiz,
                              color: PortColor.gold,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            TextConst(
                              title: '${loc.transfer} ₹${widget.rewardWallet ?? '0'}',
                              size: 15,
                              fontWeight: FontWeight.w700,
                              color: PortColor.gold,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationTile({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final isSelected = selectedDestination == index;
    return GestureDetector(
      onTap: () => setState(() => selectedDestination = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFECA1F) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFECA1F)
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFFFECA1F).withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black87 : const Color(0xFF90A4AE),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextConst(
                title: label,
                size: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black87 : const Color(0xFF90A4AE),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.black87,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
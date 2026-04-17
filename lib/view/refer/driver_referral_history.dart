import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/model/driver_transaction_model.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view/refer/driver_transfer.dart';
import 'package:yoyomiles_partner/view_model/driver_referral_history_view_model.dart';

class DriverReferralHistory extends StatefulWidget {
  const DriverReferralHistory({super.key});

  @override
  State<DriverReferralHistory> createState() => _DriverReferralHistoryState();
}

class _DriverReferralHistoryState extends State<DriverReferralHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DriverReferralHistoryViewModel>(context, listen: false)
          .driverRefHistApi(1, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Consumer<DriverReferralHistoryViewModel>(
      builder: (context, vm, _) {
        return SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              backgroundColor: PortColor.gold,
              elevation: 0,
              iconTheme: IconThemeData(color: PortColor.blackLight),
              title: TextConst(
                title: loc.driver_referral_hist,
                color: PortColor.blackLight,
                size: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            body: vm.loading
                ? const Center(
                child: CircularProgressIndicator(color: PortColor.gold))
                : vm.driverTransactionModel == null
                ? Center(child: TextConst(title: loc.no_data_found))
                : _buildBody(vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(DriverReferralHistoryViewModel vm) {
    final loc = AppLocalizations.of(context)!;
    final model = vm.driverTransactionModel!;
    final type = model.type ?? 1;

    return Column(
      children: [
        Container(
          color: PortColor.gold,
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Row(
            children: [
              _tab(loc.referral_history, type == 1, 1, vm),
              const SizedBox(width: 8),
              _tab(loc.transaction, type == 2, 2, vm),
            ],
          ),
        ),
        Expanded(
          child: type == 1
              ? _buildReferralBody(model)
              : _buildTransactionBody(model),
        ),
      ],
    );
  }

  Widget _tab(String label, bool active, int typeValue,
      DriverReferralHistoryViewModel vm) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (vm.driverTransactionModel?.type != typeValue) {
            vm.driverRefHistApi(typeValue, context);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? PortColor.blackLight : Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: TextConst(
            title: label,
            size: 12,
            fontWeight: FontWeight.w500,
            color: active ? PortColor.gold : PortColor.blackLight,
          ),
        ),
      ),
    );
  }

  Widget _buildReferralBody(DriverTransactionModel model) {
    final referrals = model.referralData ?? [];
    final loc = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _rewardCard(model),
        if (referrals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(child: TextConst(title: loc.no_referral_yet)),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
            child: TextConst(
              title: "${loc.referrals} (${referrals.length})",
              size: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
            ),
          ),
          ...referrals.map((r) => _referralCard(r)),
        ],
      ],
    );
  }

  Widget _referralCard(ReferralData r) {
    final name = (r.driverName ?? "").trim();
    final initials = name.isNotEmpty
        ? name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join()
        : '?';
    final amount = r.rewardAmount ?? '0';
    final date = _formatDate(r.createdAt);
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3CC),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: TextConst(
              title: initials.toUpperCase(),
              size: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFBA7517),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConst(
                  title: name.isEmpty ? loc.unknown_driver : name,
                  size: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                ),
                const SizedBox(height: 2),
                TextConst(title: date, size: 11, color: Colors.black45),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3DE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextConst(
              title: "+ ₹$amount",
              size: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3B6D11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionBody(DriverTransactionModel model) {
    final loc = AppLocalizations.of(context)!;
    final txns = model.transactionHistory ?? [];
    final totalTransferred = model.totalTransferred ?? '0';

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _rewardCard(model),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: _summaryChip(
            '${loc.total_transferred} :',
            "₹ $totalTransferred",
            Colors.red.shade700,
          ),
        ),
        if (txns.isEmpty)
           Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: TextConst(title: loc.no_transaction_history)),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: TextConst(
              title: loc.all_transaction,
              size: 11,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
            ),
          ),
          ...txns.map((t) => _transactionCard(t)),
        ],
      ],
    );
  }

  Widget _summaryChip(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextConst(title: label, size: 15, color: Colors.black45),
          Spacer(),
          TextConst(
            title: value,
            size: 15,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(TransactionHistory t) {
    final loc = AppLocalizations.of(context)!;

    final isFromWallet = t.actionType == 1;
    final amount = t.rewardAmount ?? '0';
    final date = _formatDate(t.createdAt);

    final String label = isFromWallet
        ? loc.transferred_from_wallet
        : loc.transferred_from_due;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isFromWallet
                  ? const Color(0xFFEAF3DE)
                  : const Color(0xFFFCEBEB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_upward,
              size: 16,
              color: isFromWallet
                  ? const Color(0xFF3B6D11)
                  : const Color(0xFFA32D2D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConst(
                  title: label,
                  size: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                ),
                const SizedBox(height: 2),
                TextConst(title: date, size: 11, color: Colors.black45),
              ],
            ),
          ),
          TextConst(
            title: "- ₹$amount",
            size: 14,
            fontWeight: FontWeight.w500,
            color: isFromWallet
                ? const Color(0xFF3B6D11)
                : const Color(0xFFA32D2D),
          ),
        ],
      ),
    );
  }

  Widget _rewardCard(DriverTransactionModel model) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: PortColor.blackLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextConst(
                    title: loc.total_reward_amount,
                    color: Colors.white60,
                    size: 11,
                  ),
                  const SizedBox(height: 4),
                  TextConst(
                    title: "₹ ${model.totalReward ?? '0'}",
                    color: PortColor.gold,
                    size: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const Icon(Icons.emoji_events, color: PortColor.gold, size: 28),
            ],
          ),

          const SizedBox(height: 10),

          GestureDetector(
            onTap: () {
            Navigator.push(context, CupertinoPageRoute(builder: (context) => DriverTransfer(rewardWallet:model.rewardWallet )));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet,
                      size: 16, color: Colors.white70),
                  const SizedBox(width: 8),

                  Expanded(
                    child: TextConst(
                      title:
                      "Reward Wallet: ₹ ${model.rewardWallet ?? '0'}",
                      color: Colors.white,
                      size: 12,
                    ),
                  ),

                  /// 👉 CLEAR ACTION
                  Row(
                    children: const [
                      Text(
                        "Transfer",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios,
                          size: 12, color: Colors.white70),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return "";
    try {
      final dt = DateTime.parse(raw);
      return DateFormat("dd MMM yyyy, h:mm a").format(dt);
    } catch (_) {
      return raw;
    }
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/driver_referral_history_view_model.dart';
import 'package:yoyomiles_partner/model/driver_transaction_model.dart';

const kYellow = Color(0xFFFECA1F);
const kDark = Color(0xFF1A1A1A);

class DriverReferralHistory extends StatefulWidget {
  const DriverReferralHistory({super.key});

  @override
  State<DriverReferralHistory> createState() =>
      _DriverReferralHistoryState();
}

class _DriverReferralHistoryState
    extends State<DriverReferralHistory> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<DriverReferralHistoryViewModel>(
          context,
          listen: false);
      vm.driverRefHistApi(1, context); // 👈 default type 1
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DriverReferralHistoryViewModel>(
      builder: (context, vm, _) {
        return SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: AppBar(
              backgroundColor: kYellow,
              elevation: 0,
              iconTheme: const IconThemeData(color: kDark),
              title: const Text(
                "Driver Referral History",
                style: TextStyle(
                    color: kDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              ),
            ),
            body: vm.loading
                ? const Center(
                child: CircularProgressIndicator(color: kYellow))
                : vm.driverTransactionModel == null
                ? const Center(child: Text("No Data Found"))
                : _buildBody(vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(DriverReferralHistoryViewModel vm) {
    final model = vm.driverTransactionModel!;
    final type = model.type ?? 1;

    return Column(
      children: [
        // ─── TAB BAR ───
        Container(
          color: const Color(0xFFF0C400),
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Row(
            children: [
              _tab("Referral History", type == 1, 1),
              const SizedBox(width: 8),
              _tab("Transactions", type == 2, 2),
            ],
          ),
        ),

        // ─── BODY ───
        Expanded(
          child: type == 1
              ? _buildReferralBody(model)
              : _buildTransactionBody(model),
        ),
      ],
    );
  }

  // ✅ TAB CLICK FUNCTION
  Widget _tab(String label, bool active, int typeValue) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          final vm =
          Provider.of<DriverReferralHistoryViewModel>(
              context,
              listen: false);

          // 👇 same tab pe dubara call avoid
          if (vm.driverTransactionModel?.type != typeValue) {
            vm.driverRefHistApi(typeValue, context);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? kDark : Colors.black12,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: active ? kYellow : kDark,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────
  // TYPE 1 UI
  // ─────────────────────────────
  Widget _buildReferralBody(DriverTransactionModel model) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(
              horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: kDark,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text("Total Reward Earned",
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(
                    "₹ ${model.totalReward ?? 0}",
                    style: const TextStyle(
                        color: kYellow,
                        fontSize: 22,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Wallet: ₹ ${model.rewardWallet ?? 0}",
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10),
                  ),
                ],
              ),
              const Icon(Icons.emoji_events,
                  color: kYellow),
            ],
          ),
        ),

        if (model.transactionHistory != null)
          ...model.transactionHistory!
              .where((t) => t.actionType == 1)
              .map((t) => ListTile(
            title: const Text("Referral Bonus"),
            subtitle: Text(t.createdAt ?? ""),
            trailing:
            Text("+ ₹${t.rewardAmount}"),
          ))
      ],
    );
  }

  // ─────────────────────────────
  // TYPE 2 UI
  // ─────────────────────────────
  Widget _buildTransactionBody(DriverTransactionModel model) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (model.transactionHistory != null)
          ...model.transactionHistory!.map(
                (t) {
              final isBonus = t.actionType == 1;
              return ListTile(
                title: Text(
                  isBonus
                      ? "Referral Bonus"
                      : "Transfer",
                ),
                subtitle: Text(t.createdAt ?? ""),
                trailing: Text(
                  isBonus
                      ? "+ ₹${t.rewardAmount}"
                      : "- ₹${t.rewardAmount}",
                  style: TextStyle(
                    color: isBonus
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              );
            },
          )
      ],
    );
  }
}
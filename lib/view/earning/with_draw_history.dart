import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/withdraw_history_view_model.dart';
import 'package:provider/provider.dart';
import '../../model/withdraw_history_model.dart';

class WithDrawHistory extends StatefulWidget {
  const WithDrawHistory({super.key});

  @override
  State<WithDrawHistory> createState() => _WithDrawHistoryState();
}

class _WithDrawHistoryState extends State<WithDrawHistory> {
  int _selectedFilter = 0; // 0: All, 1: Completed, 2: Pending, 3: Failed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final withdrawHistoryVm =
      Provider.of<WithdrawHistoryViewModel>(context, listen: false);
      withdrawHistoryVm.withDrawHistoryApi("", context); // ✅ Default ALL -> ""
    });
  }

  // ✅ Format Date
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      DateTime d = DateTime.parse(date);
      return DateFormat("dd MMM yyyy, hh:mm a").format(d);
    } catch (e) {
      return date;
    }
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 1:
        return Colors.green; // Completed
      case 0:
        return Colors.orange; // Pending
      case 2:
        return Colors.red; // Failed
      default:
        return Colors.grey;
    }
  }

  // ✅ Status Text Mapping
  String _getStatusText(int? status) {
    switch (status) {
      case 1:
        return 'Completed';
      case 0:
        return 'Pending';
      case 2:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title:  TextConst(
            title:
            'Withdrawal History',
            fontWeight: FontWeight.w600,
            size: 17,
          ),
        ),

        body: Column(
          children: [
            _buildFilterChips(),
            _buildWithdrawalList(),
          ],
        ),
      ),
    );
  }

  // ✅ FILTER CHIPS + FILTER API CALL MAPPING
  Widget _buildFilterChips() {
    List<String> filters = ['All', 'Completed', 'Pending', 'Rejected'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: filters.asMap().entries.map((entry) {
          int index = entry.key;
          String filter = entry.value;
          bool isSelected = _selectedFilter == index;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = index);

              final withdrawHistoryVm =
              Provider.of<WithdrawHistoryViewModel>(context, listen: false);

              // ✅ UPDATED FLAGS
              String flag = "";
              if (index == 1) flag = "1"; // Completed
              if (index == 2) flag = "0"; // Pending
              if (index == 3) flag = "2"; // Failed

              withdrawHistoryVm.withDrawHistoryApi(flag, context);
            },

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? PortColor.gold : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? PortColor.gold : Colors.grey.shade300,
                ),
              ),
              child: TextConst(
                title:
                filter,
                  size: 13,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ✅ WITHDRAWAL LIST
  Widget _buildWithdrawalList() {
    final withdrawHistoryVm = Provider.of<WithdrawHistoryViewModel>(context);

    // ✅ Loader
    if (withdrawHistoryVm.loading) {
      return const Expanded(
        child: Center(child: CupertinoActivityIndicator(radius: 18)),
      );
    }

    final List<Data>? list = withdrawHistoryVm.withdrawHistoryModel?.data;

    // ✅ Empty UI
    if (list == null || list.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              TextConst(title:
                "No withdrawals found",
                size: 15,
              )
            ],
          ),
        ),
      );
    }

    // ✅ LISTVIEW
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        itemBuilder: (context, index) => _buildWithdrawalItem(list[index]),
      ),
    );
  }

  // ✅ EACH ITEM CARD
// ✅ EACH ITEM CARD
  Widget _buildWithdrawalItem(Data withdrawal) {
    int status = withdrawal.status ?? -1;
    Color statusColor = _getStatusColor(status);

    final String rejectReason = (withdrawal.rejectReason ?? "").toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PortColor.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance,
              color: PortColor.gold,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // ✅ DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextConst(
                      title: withdrawal.orderId ?? "Order",
                      size: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    TextConst(
                      title: "₹${withdrawal.amount}",
                      fontWeight: FontWeight.bold,
                      size: 14,
                      color: PortColor.gold,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ✅ Reject reason (sirf Rejected pe)
                if (status == 2 && rejectReason.isNotEmpty) ...[
                  TextConst(
                    title: "Reason: $rejectReason",
                    size: 12,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 4),
                ],

                // ✅ Footer row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextConst(
                      title: formatDate(withdrawal.createdAt),
                      size: 13,
                      color: Colors.grey.shade600,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextConst(
                        title: _getStatusText(status),
                        color: statusColor,
                        size: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

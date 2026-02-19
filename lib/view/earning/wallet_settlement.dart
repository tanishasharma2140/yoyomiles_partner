import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/view/bank_detail_view.dart';
import 'package:yoyomiles_partner/view_model/bank_view_model.dart';
import 'package:yoyomiles_partner/view_model/withdraw_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/res/animated_gradient_border.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/custom_text_field.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view/bank_detail.dart' show BankDetail;
import 'package:yoyomiles_partner/view/earning/with_draw_history.dart'
    show WithDrawHistory;
import 'package:yoyomiles_partner/view_model/payment_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/transaction_view_model.dart';

class WalletSettlement extends StatefulWidget {
  const
  WalletSettlement({super.key});

  @override
  State<WalletSettlement> createState() => _WalletSettlementState();
}

class _WalletSettlementState extends State<WalletSettlement> {
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("trabsactuyon");
      final transactionVm = Provider.of<TransactionViewModel>(
        context,
        listen: false,
      );
      transactionVm.transactionApi(context);
      final bankVm = Provider.of<BankViewModel>(context, listen: false);
      bankVm.bankDetailViewApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: TextConst(
            title: loc.wallet_and_settlement,
            color: Colors.black,
            size: 18,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildBalanceCard(),
              SizedBox(height: Sizes.screenHeight * 0.02),
              // Quick Actions
              _buildQuickActions(),

              // Withdrawal Methods
              SizedBox(height: 20),

              _buildTransactionHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final driverProfile = Provider.of<ProfileViewModel>(context);
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sizes.screenWidth * 0.045),
      child: AnimatedGradientBorder(
        borderSize: 0.2,
        glowSize: 0,
        gradientColors: [
          Color(0xFFFFA726),
          Colors.transparent,
          Color(0xFFFFD54F),
        ],
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: EdgeInsets.all(4),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [Color(0xFFFFF176), Color(0xFFFFD54F), Color(0xFFFFA726)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: PortColor.gold.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(height: 8),
              // Main wallet amount - centered
              Text(
                '₹${driverProfile.profileModel!.data!.wallet}',
                style: TextStyle(
                  color: PortColor.blackLight,
                  fontFamily: AppFonts.kanitReg,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              TextConst(
                title: loc.available_balance,
                size: 14,
                color: PortColor.black,
              ),
              SizedBox(height: 20),
              // Two wallets - left and right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Main Wallet - Left side
                  Expanded(
                    child: _buildWalletItem(
                      loc.main_wallet,
                      '₹${driverProfile.profileModel!.data!.wallet}',
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Due Wallet - Right side
                  Expanded(
                    child: _buildWalletItem(
                      loc.due_wallet,
                      '₹${driverProfile.profileModel!.data!.duesPayment}',
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Updated helper widget for wallet items
  Widget _buildWalletItem(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: PortColor.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 14,
              color: PortColor.blackLight,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildQuickActions() {
    final bankVm = Provider.of<BankViewModel>(context);
    final bool hasBank = bankVm.bankDetailModel != null;
    final loc = AppLocalizations.of(context)!;

    void addBankAccount() {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => BankDetail(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: Duration(milliseconds: 300),
        ),
      );
    }

    void _goToBankHistory() {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => BankDetailView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: Duration(milliseconds: 300),
        ),
      );
    }


    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionButton(
            loc.withdraw,
            Icons.currency_rupee,
            _showWithdrawalDialog,
          ),
          _buildActionButton(loc.history, Icons.history, _viewHistory),
          _buildActionButton(
            hasBank ? loc.bank_history : loc.add_bank,                 // text
            hasBank ? Icons.history : Icons.account_balance,       // icon optional
            hasBank ? _goToBankHistory : addBankAccount,          // navigation
          ),

          _buildActionButton(loc.due_wallet, Icons.wallet, _showDueWalletHelp),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PortColor.gold.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: PortColor.gold),
            ),
            child: Icon(icon, color: PortColor.gold, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    final transaction = Provider.of<TransactionViewModel>(context);
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:  [
              Text(
                loc.recent_transactions,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 🔥 Conditional UI for Loading / Data / Empty State
          if (transaction.loading) ...[
            const Center(child: CupertinoActivityIndicator(radius: 14)),
          ] else if (transaction.transactionsModel == null ||
              transaction.transactionsModel!.data == null ||
              transaction.transactionsModel!.data!.isEmpty) ...[
             Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  loc.no_data_found,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ] else ...[
            // ✅ Show Transaction List if data available
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: transaction.transactionsModel!.data!.length,
              itemBuilder: (context, index) {
                final transactionData =
                    transaction.transactionsModel!.data![index];
                return _buildTransactionItem(transactionData);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionItem(transaction) {
    int paymentBy = transaction.paymetBy ?? 1;

    String paymentStatus = _getPaymentStatus(paymentBy);
    String statusText = _getStatusText(paymentBy);
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(paymentBy).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 STATUS ICON
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(paymentBy).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(paymentBy),
              color: _getStatusColor(paymentBy),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // 🔹 DETAILS SECTION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // =======================
                // PAYMENT BY = 1 (ONLINE)
                // =======================
                if (paymentBy == 1) ...[
                  Text(
                    '${loc.total_amount} ₹${transaction.totalAmount ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${loc.platform_fee} ${transaction.platformFee ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${loc.final_amount} ₹${transaction.amount ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.orderId ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  TextConst(
                    title:
                    transaction.paymentGatewayStatus == 0
                        ? "Pending"
                        : transaction.paymentGatewayStatus == 1
                        ? "Success"
                        : "Failed",
                    fontWeight: FontWeight.w600,
                    size: 13,
                    color: transaction.paymentGatewayStatus == 0
                        ? Colors.orange
                        : transaction.paymentGatewayStatus == 1
                        ? Colors.green
                        : Colors.red,
                  ),
                ],

                // =======================
                // PAYMENT BY = 2 (DUE)
                // =======================
                if (paymentBy == 2) ...[
                  Text(
                    '${loc.total_amount} ₹${transaction.totalAmount ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.orderId ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  TextConst(
                    title:
                    transaction.paymentGatewayStatus == 0
                        ? "Pending"
                        : transaction.paymentGatewayStatus == 1
                        ? "Success"
                        : "Failed",
                    fontWeight: FontWeight.w600,
                    size: 13,
                    color: transaction.paymentGatewayStatus == 0
                        ? Colors.orange
                        : transaction.paymentGatewayStatus == 1
                        ? Colors.green
                        : Colors.red,
                  ),
                ],

                // =======================
                // PAYMENT BY = 3 (OFFLINE)
                // =======================
                if (paymentBy == 3) ...[
                  Text(
                    '${loc.total_amount} ₹${transaction.totalAmount ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${loc.platform_fee} ${transaction.platformFee ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                // ==========================
                // 🔥 PAYMENT BY = 6 (WALLET)
                // ==========================
                if (paymentBy == 6) ...[
                   Text(
                    loc.paid_from_user_wallet,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${loc.total_amount} ₹${transaction.totalAmount ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${loc.platform_fee} ${transaction.platformFee ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${loc.final_amount} ₹${transaction.amount ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ],

                const SizedBox(height: 4),

                // 🔹 DATE
                Text(
                  _formatDate(transaction.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),

                // 🔹 STATUS BADGE
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getStatusColor(paymentBy).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getStatusColor(paymentBy).withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(paymentBy),
                        size: 10,
                        color: _getStatusColor(paymentBy),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: _getStatusColor(paymentBy),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔹 AMOUNT COLUMN
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${transaction.amount ?? '0.00'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(paymentBy),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                paymentStatus,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper function to get payment status text
  String _getPaymentStatus(int paymentBy) {
    final loc = AppLocalizations.of(context)!;
    switch (paymentBy) {

      case 1:
        return loc.online_payment;
      case 2:
        return loc.due_payment;
      case 3:
        return loc.offline_payment;
      case 6:
        return loc.from_user_wallet;
      default:
        return loc.unknown;
    }
  }

  String _getStatusText(int paymentBy) {
    final loc = AppLocalizations.of(context)!;
    switch (paymentBy) {
      case 1:
        return loc.online;
      case 2:
        return loc.due;
      case 3:
        return loc.offline;
      case 6:
        return loc.wallet;
      default:
        return loc.unknown;
    }
  }

  Color _getStatusColor(int paymentBy) {
    switch (paymentBy) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      case 6:
        return Colors.purple; // 🔥 wallet color
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int paymentBy) {
    switch (paymentBy) {
      case 1:
        return Icons.credit_card;
      case 2:
        return Icons.pending;
      case 3:
        return Icons.money;
      case 6:
        return Icons.account_balance_wallet;
      default:
        return Icons.help_outline;
    }
  }


  // Helper function to format date
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'No Date';

    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _showWithdrawalDialog() {
    final loc = AppLocalizations.of(context)!;
    final driverProfile = Provider.of<ProfileViewModel>(context, listen: false);
    final bankVm = Provider.of<BankViewModel>(context, listen: false);
    final withdrawVm = Provider.of<WithdrawViewModel>(context, listen: false);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: loc.withdraw_funds,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              shadowColor: PortColor.gold.withOpacity(0.3),
              title: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: PortColor.gold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.currency_rupee,
                      color: PortColor.gold,
                      size: 30,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextConst(
                    title: loc.withdraw_funds,
                    size: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Balance Info
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: PortColor.gold.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: PortColor.gold.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: PortColor.gold,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextConst(
                                  title: loc.available_balance,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                TextConst(
                                  title:
                                      '₹${driverProfile.profileModel!.data!.wallet}',
                                  size: 16,
                                  fontWeight: FontWeight.bold,
                                  color: PortColor.gold,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Amount Input
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: loc.enter_amount,
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: AppFonts.kanitReg,
                        ),
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                          color: PortColor.gold,
                          size: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: PortColor.gold,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Selected Bank
                    bankVm.bankDetailModel == null
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: TextConst(
                              title:
                              loc.no_bank_account_added,
                              size: 13,
                              color: PortColor.black,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: PortColor.gold.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.account_balance,
                                    color: PortColor.gold,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextConst(
                                        title:
                                            bankVm
                                                .bankDetailModel
                                                ?.bankDetails
                                                ?.bankName ??
                                            "Unknown",
                                        fontWeight: FontWeight.w600,
                                        size: 14,
                                      ),
                                      TextConst(
                                        title:
                                            bankVm
                                                .bankDetailModel
                                                ?.bankDetails
                                                ?.accountNumber ??
                                            "Unknown",
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            child: TextConst(
                              title: loc.cancel,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            withdrawVm.withDrawApi(
                              amountController.text,
                              context,
                            );
                            amountController.clear();
                            // _showSuccessDialog();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: PortColor.gold,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFA726,
                                  ).withOpacity(0.3),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ✅ Hide Rupee icon when loading
                                if (!withdrawVm.loading) ...[
                                  const Icon(
                                    Icons.currency_rupee,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                ],

                                // ✅ Loader OR Text
                                withdrawVm.loading
                                    ? const CupertinoActivityIndicator(
                                        radius: 12,
                                      )
                                    : TextConst(
                                        title: loc.withdraw,
                                        color: PortColor.white,
                                        fontWeight: FontWeight.bold,
                                        size: 14,
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _viewHistory() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WithDrawHistory(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    ); // Implement view history
  }

  void _showDueWalletHelp() {
    final payment = Provider.of<PaymentViewModel>(context, listen: false);
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon and title
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: PortColor.gold.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wallet,
                          size: 28,
                          color: PortColor.gold,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        loc.due_wallet,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                CustomTextField(
                  controller: amountController,
                  labelText: loc.enter_amount,
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                          child: Text(
                            loc.cancel,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12),

                    // Submit Button
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            payment.paymentApi(
                              amountController.text,
                              "",
                              context,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: PortColor.gold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            loc.submit,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

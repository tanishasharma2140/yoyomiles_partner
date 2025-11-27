import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  const WalletSettlement({super.key});

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
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: TextConst(
            title: 'Wallet & Settlements',
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
                title: 'Available Balance',
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
                      'Main Wallet',
                      '₹${driverProfile.profileModel!.data!.wallet}',
                      Icons.account_balance_wallet,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 16),
                  // Due Wallet - Right side
                  Expanded(
                    child: _buildWalletItem(
                      'Due Wallet',
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

  Widget _buildBalanceItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: PortColor.blackLight, size: 20),
        SizedBox(height: 4),
        TextConst(
          title: title,
          color: PortColor.blackLight,
          size: 12,
          fontFamily: AppFonts.kanitReg,
        ),
        SizedBox(height: 2),
        TextConst(
          title: value,
          color: PortColor.blackLight,
          fontFamily: AppFonts.kanitReg,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final bankVm = Provider.of<BankViewModel>(context);
    final bool hasBank = bankVm.bankDetailModel != null;

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
            'Withdraw',
            Icons.currency_rupee,
            _showWithdrawalDialog,
          ),
          _buildActionButton('History', Icons.history, _viewHistory),
          _buildActionButton(
            hasBank ? 'Bank History' : 'Add Bank',                 // text
            hasBank ? Icons.history : Icons.account_balance,       // icon optional
            hasBank ? _goToBankHistory : addBankAccount,          // navigation
          ),

          _buildActionButton('Due Wallet', Icons.wallet, _showDueWalletHelp),
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


  Widget _buildWithdrawalMethod(Map<String, dynamic> method) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: method['selected']
            ? PortColor.gold.withOpacity(0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: method['selected'] ? PortColor.gold : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: PortColor.gold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(method['icon'], color: PortColor.gold, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  method['number'],
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    final transaction = Provider.of<TransactionViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Recent Transactions',
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
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Text(
                  "No Data Found",
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
            SizedBox(
              height: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: transaction.transactionsModel!.data!.length,
                itemBuilder: (context, index) {
                  final transactionData =
                      transaction.transactionsModel!.data![index];
                  return _buildTransactionItem(transactionData);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionItem(transaction) {
    // Assuming you have payment_by field in your Data model
    // If not, you need to add it to your Data class
    int paymentBy = transaction.paymetBy ?? 1; // Default to 1 if null

    // Determine transaction type and status
    bool isCredit =
        transaction.amount != null && double.parse(transaction.amount!) > 0;
    String paymentStatus = _getPaymentStatus(paymentBy);
    String statusText = _getStatusText(paymentBy);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(paymentBy).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Status Icon
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
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Case 1: payment_by = 1
                if (paymentBy == 1) ...[
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text:
                              'Total Amount: ₹${transaction.totalAmount ?? '0.00'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text:
                              'Platform Fee: ${transaction.platformFee ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.orange[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text:
                              'Final Amount: ₹${transaction.amount ?? '0.00'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    transaction.orderId ?? 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: PortColor.gray,
                      fontSize: 14,
                    ),
                  ),
                ],

                // Case 2: payment_by = 2
                if (paymentBy == 2) ...[
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text:
                              'Total Amount: ₹${transaction.totalAmount ?? '0.00'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    transaction.orderId ?? 'N/A',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: PortColor.gray,
                      fontSize: 14,
                    ),
                  ),
                ],

                // Case 3: payment_by = 3
                if (paymentBy == 3) ...[
                  // No Order ID for case 3
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text:
                              'Total Amount: ₹${transaction.totalAmount ?? '0.00'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      children: [
                        TextSpan(
                          text:
                              'Platform Fee: ${transaction.platformFee ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.orange[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Date - Common for all cases
                SizedBox(height: 4),
                Text(
                  _formatDate(transaction.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),

                // Status Badge
                Container(
                  margin: EdgeInsets.only(top: 6),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      SizedBox(width: 4),
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

          // Right side amount column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Amount display based on payment_by
              if (paymentBy == 1 || paymentBy == 3)
                Text(
                  '₹${transaction.amount ?? '0.00'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),

              if (paymentBy == 2)
                Text(
                  '₹${transaction.totalAmount ?? '0.00'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),

              SizedBox(height: 4),

              // Label based on payment_by
              if (paymentBy == 1)
                Text(
                  'After Fee',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),

              if (paymentBy == 2 || paymentBy == 3)
                Text(
                  'Total',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),

              // Payment Method
              SizedBox(height: 2),
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
    switch (paymentBy) {
      case 1:
        return 'Online Payment';
      case 2:
        return 'Due Payment';
      case 3:
        return 'Offline Payment';
      default:
        return 'Unknown';
    }
  }

  // Helper function to get status text
  String _getStatusText(int paymentBy) {
    switch (paymentBy) {
      case 1:
        return 'Online';
      case 2:
        return 'Due';
      case 3:
        return 'Offline';
      default:
        return 'Unknown';
    }
  }

  // Helper function to get status color
  Color _getStatusColor(int paymentBy) {
    switch (paymentBy) {
      case 1: // Online
        return Colors.blue;
      case 2: // Due Payment
        return Colors.orange;
      case 3: // Offline
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Helper function to get status icon
  IconData _getStatusIcon(int paymentBy) {
    switch (paymentBy) {
      case 1: // Online
        return Icons.online_prediction;
      case 2: // Due Payment
        return Icons.pending;
      case 3: // Offline
        return Icons.offline_pin;
      default:
        return Icons.help;
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
    final driverProfile = Provider.of<ProfileViewModel>(context, listen: false);
    final bankVm = Provider.of<BankViewModel>(context, listen: false);
    final withdrawVm = Provider.of<WithdrawViewModel>(context, listen: false);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Withdraw Funds',
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
                    title: 'Withdraw Funds',
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
                                  title: 'Available Balance',
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
                        labelText: 'Enter Amount',
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
                              "No bank account has been added,\nplease add a bank account first.",
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
                              title: 'Cancel',
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
                                        title: 'Withdraw',
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

  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Success',
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Icon with Animation
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Success Message
                    Text(
                      'Success!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Withdrawal request submitted successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    SizedBox(height: 20),

                    // OK Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PortColor.gold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addBankAccount() {
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String amount = '';
        final TextEditingController _amountController = TextEditingController();

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
                        'Due Wallet',
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
                  controller: _amountController,
                  labelText: 'Enter Amount',
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: Container(
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
                            'Cancel',
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
                              context,
                              _amountController.text,
                              "",
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
                            'Submit',
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

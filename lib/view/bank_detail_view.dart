import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/generated/assets.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view/earning/edit_bank_account_page.dart';
import 'package:yoyomiles_partner/view_model/bank_view_model.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/view_model/delete_bank_detail_view_model.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';

class BankDetailView extends StatefulWidget {
  const BankDetailView({super.key});

  @override
  State<BankDetailView> createState() => _BankDetailViewState();
}

class _BankDetailViewState extends State<BankDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bankViewModel = Provider.of<BankViewModel>(context, listen: false);
      bankViewModel.bankDetailViewApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Bank Details',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<BankViewModel>(
          builder: (context, bankViewModel, child) {
            if (bankViewModel.loading) {
              // 🔹 Loader while data is being fetched
              return Center(
                child: CircularProgressIndicator(
                  color: PortColor.gold,
                  strokeWidth: 3,
                ),
              );
            } else if (bankViewModel.bankDetailModel != null) {
              // 🔹 Data Found
              return bankDataFound();
            } else {
              // 🔹 No Data
              return bankDataNot();
            }
          },
        ),
      ),
    );
  }

  Widget bankDataFound() {
    final bankViewModel = Provider.of<BankViewModel>(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF176),
                  Color(0xFFFFD54F),
                  Color(0xFFFFA726),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: PortColor.gold.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: PortColor.gold,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextConst(
                        title: 'Bank Account Verified',
                        color: PortColor.blackLight,
                        size: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 2),
                      TextConst(
                        title: 'Your account is ready for withdrawals',
                        color: Colors.black38,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Bank Details List
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // List Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PortColor.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance, color: PortColor.gold),
                      SizedBox(width: 12),
                      TextConst(
                        title: 'Account Information',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),

                // Account Holder Name
                _buildListTile(
                  icon: Icons.person,
                  title: 'Account Holder Name',
                  value:
                      bankViewModel
                          .bankDetailModel!
                          .bankDetails!
                          .accountHolderName ??
                      '',
                  isFirst: true,
                ),

                _buildListTile(
                  icon: Icons.account_balance,
                  title: 'Bank Name',
                  value:
                  bankViewModel
                      .bankDetailModel!
                      .bankDetails!
                      .bankName ??
                      '',
                  isFirst: true,
                ),

                // Account Number
                _buildListTile(
                  icon: Icons.credit_card,
                  title: 'Account Number',
                  value: _maskAccountNumber(
                    bankViewModel.bankDetailModel!.bankDetails!.accountNumber ??
                        '',
                  ),
                  showVisibility: true,
                ),

                // Re-account Number
                _buildListTile(
                  icon: Icons.verified_user,
                  title: 'Confirm Account Number',
                  value: _maskAccountNumber(
                    bankViewModel
                            .bankDetailModel!
                            .bankDetails!
                            .reAccountNumber ??
                        '',
                  ),
                  showVisibility: true,
                ),

                // IFSC Code
                _buildListTile(
                  icon: Icons.code,
                  title: 'IFSC Code',
                  value:
                      bankViewModel.bankDetailModel!.bankDetails!.ifscCode ??
                      '',
                  isLast: true,
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Bank Status Card
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextConst(
                        title: 'Verification Status',
                        size: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      SizedBox(height: 4),
                      TextConst(
                        title: 'Your bank account is successfully verified',
                        size: 13,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextConst(
                    title: 'Verified',
                    color: Colors.green,
                    size: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              // Edit Button
              Expanded(
                child: OutlinedButton(
                  onPressed: _editBankDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PortColor.gold,
                    side: BorderSide(color: PortColor.gold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      TextConst(title: 'Edit Details', color: PortColor.gold),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),

              // Delete Button
              Expanded(
                child: OutlinedButton(
                  onPressed: _deleteBankAccount,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, size: 18),
                      SizedBox(width: 8),
                      TextConst(title: 'Delete', color: PortColor.red),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Set as Default Button
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String value,
    bool isFirst = false,
    bool isLast = false,
    bool showVisibility = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: PortColor.gold.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: PortColor.gold, size: 20),
        ),
        title: TextConst(
          title: title,
          size: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        subtitle: TextConst(
          title: value,
          size: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        trailing: showVisibility
            ? Icon(Icons.visibility_off, color: Colors.grey, size: 18)
            : null,
      ),
    );
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    String lastFour = accountNumber.substring(accountNumber.length - 4);
    return 'XXXX XXXX $lastFour';
  }

  Widget bankDataNot() {
    return SizedBox(
      height: Sizes.screenHeight * 0.76,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: PortColor.gold.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: PortColor.gold,
                    size: 60,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'No Bank Account Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add your bank account to start receiving payments',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editBankDetails() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Bank Details',
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
                    child: Icon(Icons.edit, color: PortColor.gold, size: 30),
                  ),
                  SizedBox(height: 8),
                  TextConst(title:
                    'Edit Bank Details',
                    size: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextConst(title:
                    'Are you sure you want to edit your bank account details?',
                    textAlign: TextAlign.center,
                      size: 16, color: Colors.grey.shade600
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextConst(title:
                            'You will need to re-verify your account',
                            size: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: TextConst(title: 'Cancel',color: Colors.grey,),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToEditPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PortColor.gold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: 18, color: Colors.white),
                            SizedBox(width: 6),
                            TextConst(title:
                              'Edit',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
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

  void _navigateToEditPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditBankAccountPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
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

  void _deleteBankAccount() {
    final deleteAccount = Provider.of<DeleteBankDetailViewModel>(context,listen: false);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Delete Bank Account',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 300),
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
              elevation: 15,
              shadowColor: Colors.red.withOpacity(0.3),
              title: Column(
                children: [
                  // Warning Icon
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 12),
                  TextConst(title:
                    'Delete Bank Account',
                    size: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextConst(title:
                    'Are you sure you want to delete this bank account?',
                    textAlign: TextAlign.center,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  SizedBox(height: 12),

                  // Warning Card
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextConst(title:
                            'This action cannot be undone',
                            size: 14,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.grey.shade50,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cancel_outlined, size: 18),
                              SizedBox(width: 6),
                              TextConst(title:
                                'Cancel',
                                  fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 12),

                      // Delete Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            UserViewModel userViewModel = UserViewModel();
                            int? userId = await userViewModel.getUser();

                            await deleteAccount.deleteBankDetailApi(userId.toString(), context);

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                            shadowColor: Colors.red.withOpacity(0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              !deleteAccount.loading
                                  ? TextConst(
                                title: 'Delete',
                                fontWeight: FontWeight.bold,
                                color: PortColor.white,
                              ): CircularProgressIndicator(color: PortColor.white,)
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
        );
      },
    );
  }

}

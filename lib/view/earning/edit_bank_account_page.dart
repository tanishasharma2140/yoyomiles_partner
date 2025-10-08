import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/bank_detail_view_model.dart';

import 'package:yoyomiles_partner/view_model/bank_view_model.dart';
import 'package:provider/provider.dart';

class EditBankAccountPage extends StatefulWidget {
  const EditBankAccountPage({super.key});

  @override
  State<EditBankAccountPage> createState() => _EditBankAccountPageState();
}

class _EditBankAccountPageState extends State<EditBankAccountPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _reAccountController = TextEditingController();
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadCurrentData();
  }

  void _loadCurrentData() {
    final bankViewModel = Provider.of<BankViewModel>(context, listen: false);
    if (bankViewModel.bankDetailModel != null) {
      _holderNameController.text = bankViewModel.bankDetailModel!.bankDetails!.accountHolderName ?? 'N/A';
      _accountController.text = bankViewModel.bankDetailModel!.bankDetails!.accountNumber ?? 'N/A';
      _reAccountController.text = bankViewModel.bankDetailModel!.bankDetails!.reAccountNumber ?? 'N/A';
      _bankNameController.text = bankViewModel.bankDetailModel!.bankDetails!.bankName ?? 'N/A';
      _ifscCodeController.text = bankViewModel.bankDetailModel!.bankDetails!.ifscCode ?? 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bankDetailViewModel = Provider.of<BankDetailViewModel>(context);

    return Scaffold(
      backgroundColor: PortColor.scaffoldBgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Bank Account',
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
      body: SingleChildScrollView(
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
                  colors: [PortColor.gold, Color(0xFFFFD700)],
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
                      Icons.edit_note,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextConst(
                          title:
                          'Update Bank Details',
                          color: PortColor.blackLight,
                          size: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: 4),
                        TextConst(title:
                          'Modify your bank account information',
                          color: Colors.black38,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Edit Form
            Container(
              padding: EdgeInsets.all(20),
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
                  _buildFormField(
                    title: "Bank Name",
                    hintText: "Enter bank name",
                    controller: _bankNameController,
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 16),
                  // Account Holder Name
                  _buildFormField(
                    title: "Account Holder Name",
                    hintText: "Enter account holder name",
                    controller: _holderNameController,
                    icon: Icons.person_outline,
                  ),

                  SizedBox(height: 16),

                  // Account Number
                  _buildFormField(
                    title: "Account Number",
                    hintText: "Enter 12-digit account number",
                    controller: _accountController,
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    maxLength: 12,

                  ),

                  SizedBox(height: 16),

                  // Confirm Account Number
                  _buildFormField(
                    title: "Confirm Account Number",
                    hintText: "Re-enter account number",
                    controller: _reAccountController,
                    icon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 12,
                  ),

                  SizedBox(height: 16),

                  // IFSC Code
                  _buildFormField(
                    title: "IFSC Code",
                    hintText: "Enter IFSC code",
                    controller: _ifscCodeController,
                    icon: Icons.code,
                    textCapitalization: TextCapitalization.characters,
                  ),

                  SizedBox(height: 20),

                  // Info Card
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'After updating, your account will need re-verification',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, size: 18),
                        SizedBox(width: 8),
                        Text('Cancel'),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: (){
                      bankDetailViewModel.bankDetailApi(
                          _accountController.text
                          , _bankNameController.text,
                          _reAccountController.text,
                          _holderNameController.text,
                          _ifscCodeController.text,
                          context);
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
                        Icon(Icons.save, size: 18, color: Colors.black),
                        SizedBox(width: 8),
                        !bankDetailViewModel.loading
                            ? TextConst(
                          title:
                          'Save Changes',
                        color: PortColor.black,
                        ):const CupertinoActivityIndicator(
                          color: Colors.white,
                          radius: 14,
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
  }

  Widget _buildFormField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: PortColor.gold, size: 18),
            SizedBox(width: 8),
            TextConst(title:
              title,
              size : 14,
              fontWeight: FontWeight.w400,
              color: Colors.black38,
            ),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            counterText: "",
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PortColor.gold, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: AppFonts.kanitReg
          ),
        ),
      ],
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
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              title: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Success!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Bank account details updated successfully!\nYour account will be re-verified shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              actions: [
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close success dialog
                      Navigator.pop(context); // Close edit page
                      Navigator.pop(context); // Close bank details page
                    },
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
                      ),
                    ),
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
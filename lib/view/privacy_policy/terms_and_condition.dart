import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/policy_view_model.dart';

class TermsAndCondition extends StatefulWidget {
  const TermsAndCondition({super.key});

  @override
  State<TermsAndCondition> createState() => _TermsAndConditionState();
}

class _TermsAndConditionState extends State<TermsAndCondition> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final termsPolicyVm =
      Provider.of<PolicyViewModel>(context, listen: false);
      termsPolicyVm.policyApi("2");
      print("I am the....");
    });
  }

  @override
  Widget build(BuildContext context) {
    final termsPolicyVm = Provider.of<PolicyViewModel>(context);

    final description = termsPolicyVm.policyModel?.data?.description ?? "";

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 19, left: 15, right: 15),
              height: Sizes.screenHeight * 0.085,
              width: Sizes.screenWidth,
              decoration: BoxDecoration(
                color: PortColor.gold,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextConst(
                    title: "Privacy and Policy",
                    color: PortColor.black,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.dangerous_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: termsPolicyVm.loading
                    ? const Center(
                  child: CupertinoActivityIndicator(
                    color: PortColor.gold,
                    radius: 14,
                  ),
                )
                    : description.isEmpty
                    ?  Center(
                  child: Text(
                    "No data found",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: AppFonts.poppinsReg,
                      color: Colors.black54,
                    ),
                  ),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: HtmlWidget(
                    description,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.poppinsReg,
                      fontSize: 14,
                      color: PortColor.blackLight,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

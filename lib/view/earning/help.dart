import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/help_topics_view_model.dart';

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final helpTopics = Provider.of<HelpTopicsViewModel>(context, listen: false);
      helpTopics.helpTopicApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final helpTopicsVM = Provider.of<HelpTopicsViewModel>(context);

    return Scaffold(
      backgroundColor: PortColor.scaffoldBgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextConst(
          title: 'Help & Support',
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
      body: helpTopicsVM.loading
          ? const Center(child: CircularProgressIndicator(color: PortColor.gold))
          : helpTopicsVM.helpTopicsModel?.data == null ||
          helpTopicsVM.helpTopicsModel!.data!.isEmpty
          ? Center(child: TextConst(title: "No data found"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: helpTopicsVM.helpTopicsModel!.data!.length,
        itemBuilder: (context, index) {
          final item = helpTopicsVM.helpTopicsModel!.data![index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExpansionTile(
              tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: EdgeInsets.zero,
              collapsedIconColor: PortColor.gold,
              iconColor: PortColor.gold,
              backgroundColor: Colors.transparent,
              collapsedBackgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: TextConst(
                title: item.heading ?? "",
                fontWeight: FontWeight.w500,
                size: 14,
                color: Colors.black87,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: TextConst(
                    title: item.text ?? "",
                    size: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
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
  List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How long does withdrawal take?',
      'answer':
      'Withdrawals are processed within 2-4 hours during business days. For weekends, it may take up to 24 hours.',
    },
    {
      'question': 'Why is my withdrawal pending?',
      'answer':
      'Pending status usually means your request is being processed. It can take 2-4 hours to complete.',
    },
    {
      'question': 'What are the withdrawal charges?',
      'answer':
      'We charge zero fees for withdrawals. You get the full amount transferred to your bank account.',
    },
    {
      'question': 'How to add bank account?',
      'answer':
      'Go to Wallet → Add Bank → Enter your account details and IFSC code → Verify and submit.',
    },
  ];

  final List<Map<String, dynamic>> _contactOptions = [
    {
      'icon': Icons.phone,
      'title': 'Call Us',
      'subtitle': '+91 1800-123-4567',
      'color': Colors.green,
    },
    {
      'icon': Icons.email,
      'title': 'Email Us',
      'subtitle': 'support@yoyomiles.com',
      'color': Colors.blue,
    },
  ];

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
    final help = Provider.of<HelpTopicsViewModel>(context);
    final totalItems = _contactOptions.length + _faqs.length + 1; // +1 for section header
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
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: help.helpTopicsModel!.data!.length,
        itemBuilder: (context, index) {
          // Section header
          final helpSupport = help.helpTopicsModel!.data![index];
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConst(
                  title: 'Contact Support',
                  size: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                SizedBox(height: 16),
              ],
            );
          }

          // Contact options
          if (index > 0 && index <= _contactOptions.length) {
            final contact = _contactOptions[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildContactItem(
                contact['icon'],
                contact['title'],
                contact['subtitle'],
                contact['color'],
              ),
            );
          }

          // FAQ Section header
          if (index == _contactOptions.length + 1) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: TextConst(
                title: 'Frequently Asked Questions',
                size: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            );
          }

          // FAQ items
          final faqIndex = index - (_contactOptions.length + 2);
          final faq = _faqs[faqIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildFAQItem(faq),
          );
        },
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConst(
                  title: title,
                  fontWeight: FontWeight.w600,
                  size: 13,
                  color: Colors.black87,
                ),
                SizedBox(height: 2),
                TextConst(
                  title: subtitle,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: EdgeInsets.zero,
        collapsedIconColor: PortColor.gold,
        iconColor: PortColor.gold,
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: TextConst(
          title: faq['question'],
          fontWeight: FontWeight.w500,
          size: 14,
          color: Colors.black87,
        ),
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: TextConst(
              title: faq['answer'],
              size: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';

class WithDrawHistory extends StatefulWidget {
  const WithDrawHistory({super.key});

  @override
  State<WithDrawHistory> createState() => _WithDrawHistoryState();
}

class _WithDrawHistoryState extends State<WithDrawHistory> {
  int _selectedFilter = 0; // 0: All, 1: Completed, 2: Pending, 3: Failed

  List<Map<String, dynamic>> _withdrawals = [
    {
      'amount': 5000.00,
      'status': 'completed',
      'date': 'Today, 10:30 AM',
      'method': 'HDFC Bank',
    },
    {
      'amount': 3500.00,
      'status': 'pending',
      'date': 'Today, 09:15 AM',
      'method': 'ICICI Bank',
    },
    {
      'amount': 7500.00,
      'status': 'completed',
      'date': 'Yesterday, 03:45 PM',
      'method': 'HDFC Bank',
    },
    {
      'amount': 2000.00,
      'status': 'failed',
      'date': '15 Dec, 11:20 AM',
      'method': 'PhonePe UPI',
    },
    {
      'amount': 4500.00,
      'status': 'completed',
      'date': '14 Dec, 02:30 PM',
      'method': 'HDFC Bank',
    },
  ];

  List<Map<String, dynamic>> get filteredWithdrawals {
    if (_selectedFilter == 0) return _withdrawals;
    if (_selectedFilter == 1) return _withdrawals.where((w) => w['status'] == 'completed').toList();
    if (_selectedFilter == 2) return _withdrawals.where((w) => w['status'] == 'pending').toList();
    return _withdrawals.where((w) => w['status'] == 'failed').toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed': return 'Completed';
      case 'pending': return 'Processing';
      case 'failed': return 'Failed';
      default: return 'Unknown';
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
          title: Text(
            'Withdrawal History',
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
        body: Column(
          children: [
            // Filter Chips
            _buildFilterChips(),

            // Withdrawal List
            _buildWithdrawalList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    List<String> filters = ['All', 'Completed', 'Pending', 'Failed'];

    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: filters.asMap().entries.map((entry) {
          int index = entry.key;
          String filter = entry.value;
          bool isSelected = _selectedFilter == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? PortColor.gold : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? PortColor.gold : Colors.grey.shade300,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWithdrawalList() {
    if (filteredWithdrawals.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text(
                'No withdrawals found',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredWithdrawals.length,
        itemBuilder: (context, index) {
          return _buildWithdrawalItem(filteredWithdrawals[index]);
        },
      ),
    );
  }

  Widget _buildWithdrawalItem(Map<String, dynamic> withdrawal) {
    Color statusColor = _getStatusColor(withdrawal['status']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bank Icon
          Container(
            padding: EdgeInsets.all(12),
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

          SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      withdrawal['method'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '₹${withdrawal['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: PortColor.gold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      withdrawal['date'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getStatusText(withdrawal['status']),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
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
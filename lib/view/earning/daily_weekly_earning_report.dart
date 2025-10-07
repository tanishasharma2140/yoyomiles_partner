import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/res/animated_gradient_border.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/text_const.dart';

class DailyWeeklyEarningReport extends StatefulWidget {
  const DailyWeeklyEarningReport({super.key});

  @override
  State<DailyWeeklyEarningReport> createState() =>
      _DailyWeeklyEarningReportState();
}

class _DailyWeeklyEarningReportState extends State<DailyWeeklyEarningReport> {
  int _selectedTab = 0;
  DateTime _selectedDate = DateTime.now();
  String _selectedWeek = "This Week";

  // Sample data - replace with actual API data
  final Map<String, dynamic> _dailyData = {
    "totalEarnings": "₹2,850",
    "tripsCompleted": 12,
    "onlineHours": "8h 30m",
    "bonusEarned": "₹350",
    "date": "Today, 15 Dec 2024",
  };

  final Map<String, dynamic> _weeklyData = {
    "totalEarnings": "₹18,750",
    "tripsCompleted": 68,
    "onlineHours": "52h 15m",
    "bonusEarned": "₹1,250",
    "week": "11-17 Dec 2024",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortColor.scaffoldBgGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextConst(title:
          "Earnings Report",
            size: 18,
            fontWeight: FontWeight.w700,

        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab Selection
          _buildTabSelector(),

          // Date/Week Selector
          _buildDateSelector(),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Earnings Card
                  _buildEarningsCard(),

                  SizedBox(height: 16),

                  // Stats Grid
                  _buildStatsGrid(),

                  SizedBox(height: 20),

                  // Trip Details Section
                  _buildTripDetails(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              text: "Daily",
              isSelected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              text: "Weekly",
              isSelected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Color(0xFFFFF176),
                    Color(0xFFFFD54F),
                    Color(0xFFFFA726),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                )
              : null, // no gradient when not selected
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextConst(
          title: text,
          textAlign: TextAlign.center,
          color: isSelected ? Colors.black : Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 16, color: PortColor.gold),
            onPressed: () {
              // Handle previous date/week
            },
          ),

          Text(
            _selectedTab == 0 ? _dailyData["date"]! : _selectedWeek,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: PortColor.gold,
            ),
            onPressed: () {
              // Handle next date/week
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    final data = _selectedTab == 0 ? _dailyData : _weeklyData;

    return AnimatedGradientBorder(
      borderSize: 2.0, // slightly thicker so it’s visible
      glowSize: 0,
      gradientColors: [
        Color(0xFFFFA726),
        Colors.transparent,
        Color(0xFFFFD54F),
      ],
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: EdgeInsets.all(3), // exposes the animated border
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: PortColor.gold.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            TextConst(
              title: "Total Earnings",
              color: Colors.black,
              size: 16,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 8),
            Text(
              data["totalEarnings"]!,
              style: TextStyle(
                color: PortColor.blackLight,
                fontSize: 30,
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
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextConst(
                title: _selectedTab == 0 ? "Today" : "This Week",
                color: Colors.black38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }

  Widget _buildStatsGrid() {
    final data = _selectedTab == 0 ? _dailyData : _weeklyData;

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          icon: Icons.directions_car,
          title: "Trips Completed",
          value: "${data["tripsCompleted"]}",
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.timer,
          title: "Online Hours",
          value: data["onlineHours"]!,
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.workspace_premium,
          title: "Bonus Earned",
          value: data["bonusEarned"]!,
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.attach_money,
          title: "Avg. Earning",
          value: _selectedTab == 0 ? "₹238/trip" : "₹276/trip",
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          TextConst(title:
            value,
              size: 18,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
          ),
          SizedBox(height: 4),
          TextConst(title:
            title,
            textAlign: TextAlign.center,
            color: Colors.black26,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextConst(title:
          "Trip Details",
            color: PortColor.blackLight,
          fontWeight: FontWeight.w600,
          size: 16,
        ),
        SizedBox(height: 12),
        ...List.generate(5, (index) => _buildTripItem(index)),
      ],
    );
  }

  Widget _buildTripItem(int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: PortColor.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConst(title:
                  "Trip #${1001 + index}",
                    fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 4),
                TextConst(title:
                  "10:${30 + index} AM • 8.2 km • 24 mins",
                    color: Colors.grey,
                ),
              ],
            ),
          ),
          TextConst(title:
            "₹${250 + (index * 25)}",
              fontWeight: FontWeight.w600,
              color: PortColor.gold,

          ),
        ],
      ),
    );
  }
}

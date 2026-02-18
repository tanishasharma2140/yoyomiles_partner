import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/model/daily_weekly_model.dart';
import 'package:yoyomiles_partner/res/animated_gradient_border.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/view_model/daily_weekly_view_model.dart';

class DailyWeeklyEarningReport extends StatefulWidget {
  const DailyWeeklyEarningReport({super.key});

  @override
  State<DailyWeeklyEarningReport> createState() =>
      _DailyWeeklyEarningReportState();
}

class _DailyWeeklyEarningReportState extends State<DailyWeeklyEarningReport> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dailyWeeklyViewModel =
      Provider.of<DailyWeeklyViewModel>(context, listen: false);
      dailyWeeklyViewModel.dailyWeeklyApi("1", context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DailyWeeklyViewModel>(context);
    final loc = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: TextConst(
            title: loc.earning_report,
            size: 18,
            fontWeight: FontWeight.w700,
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: viewModel.loading
            ?  Center(
          child: CupertinoActivityIndicator(
            radius: 14,
            color: PortColor.gold,
          ),
        )
            : Column(
          children: [
            _buildTabSelector(viewModel),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildEarningsCard(viewModel.dailyWeeklyModel),
                    const SizedBox(height: 16),
                    _buildStatsGrid(viewModel.dailyWeeklyModel),
                    const SizedBox(height: 20),
                    _buildTripDetails(viewModel.dailyWeeklyModel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    return "${now.day}-${_monthName(now.month)}-${now.year}";
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildTabSelector(DailyWeeklyViewModel viewModel) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              text: "${loc.today} (${_formattedDate()})",
              isSelected: _selectedTab == 0,
              onTap: () {
                setState(() => _selectedTab = 0);
                viewModel.dailyWeeklyApi("1", context);
              },
            ),
          ),
          Expanded(
            child: _buildTabButton(
              text: loc.weekly,
              isSelected: _selectedTab == 1,
              onTap: () {
                setState(() => _selectedTab = 1);
                viewModel.dailyWeeklyApi("2", context);
              },
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [
              Color(0xFFFFF176),
              Color(0xFFFFD54F),
              Color(0xFFFFA726),
            ],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          )
              : null,
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

  Widget _buildEarningsCard(DailyWeeklyModel? data) {
    final loc = AppLocalizations.of(context)!;
    return AnimatedGradientBorder(
      borderSize: 2,
      glowSize: 0,
      gradientColors: const [Color(0xFFFFA726), Colors.transparent, Color(0xFFFFD54F)],
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.all(3),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF176), Color(0xFFFFD54F), Color(0xFFFFA726)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
             TextConst(title: loc.total_earnings, color: Colors.black, size: 16),
            const SizedBox(height: 8),
            Text(
              data?.offlinePlusOnline ?? "₹0",
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextConst(
                title: _selectedTab == 0 ? loc.today :  loc.this_week,
                color: Colors.black38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DailyWeeklyModel? data) {
    final loc = AppLocalizations.of(context)!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          icon: Icons.directions_car,
          title: loc.trips_completed,
          value: "${data?.tripCompleted ?? 0}",
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.timer,
          title: loc.online_hours,
          value: data?.totalTime ?? "0h",
          color: Colors.green,
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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          TextConst(
            title: value,
            size: 18,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          const SizedBox(height: 4),
          TextConst(
            title: title,
            textAlign: TextAlign.center,
            color: Colors.black26,
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildTripDetails(DailyWeeklyModel? data) {
    final loc = AppLocalizations.of(context)!;
    final trips = data?.tripDetails ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         TextConst(title: loc.trip_details, size: 16, fontWeight: FontWeight.w600),
        const SizedBox(height: 12),
        if (trips.isEmpty)
           Center(child: TextConst(title: loc.no_trips_available))
        else
          ...trips.map((trip) => _buildTripItem(trip)).toList(),
      ],
    );
  }

  Widget _buildTripItem(TripDetails trip) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(width: 4, height: 40, color: PortColor.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextConst(title: "${loc.trip} #${trip.id ?? '-'}", fontWeight: FontWeight.w600),
                const SizedBox(height: 4),
                TextConst(title: "${trip.createdAt ?? ''} • ${trip.distance ?? 0} km"),
              ],
            ),
          ),
          TextConst(
            title: "₹${trip.amount ?? 0}",
            fontWeight: FontWeight.w600,
            color: PortColor.gold,
          ),
        ],
      ),
    );
  }
}

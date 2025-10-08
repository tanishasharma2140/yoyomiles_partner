import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';

class RideSafety extends StatefulWidget {
  const RideSafety({super.key});

  @override
  State<RideSafety> createState() => _RideSafetyState();
}

class _RideSafetyState extends State<RideSafety> {
  void _showRiderDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: PortColor.scaffoldBgGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.person, color: PortColor.gold, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Rider Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: PortColor.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Simple Details List
              _buildSimpleDetail('Name', 'Sarah Johnson'),
              _buildSimpleDetail('Phone', '+1 (555) 123-4567'),
              _buildSimpleDetail('Rating', '4.9 ★'),
              _buildSimpleDetail('Pickup', 'Central Station'),
              _buildSimpleDetail('Destination', 'Northgate Mall'),
              _buildSimpleDetail('Distance', '7.2 km | 15 min'),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PortColor.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleDetail(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade700),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSOSConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: PortColor.scaffoldBgGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: PortColor.gold),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 10),
            Text(
              'Emergency SOS',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to send emergency alert to admin?',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Emergency alert sent to admin'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PortColor.scaffoldBgGrey,
      appBar: AppBar(
        backgroundColor: PortColor.scaffoldBgGrey,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: PortColor.gold),
        ),
        title: Text(
          'Ride & Safety',
          style: TextStyle(
            color: PortColor.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Current Ride Card - Simple
            Card(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Current Ride',
                          style: TextStyle(
                            color: PortColor.gold,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSimpleInfo('Rider', 'Sarah Johnson'),
                    _buildSimpleInfo('From', 'Central Station'),
                    _buildSimpleInfo('To', 'Northgate Mall'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _showRiderDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PortColor.gold.withOpacity(0.1),
                        foregroundColor: PortColor.gold,
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text('View Rider Details'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SOS Button - Simple
            Card(
              color: Colors.grey.shade900,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Emergency SOS',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _showSOSConfirmation,
                        icon: const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Press for emergency',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Text(
                      'Admin will be notified',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Safety Features - Simple
            Text(
              'Safety Features',
              style: TextStyle(
                color: PortColor.gold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSimpleFeature(
                    Icons.share_location,
                    'Share Location',
                  ),
                ),
                Expanded(
                  child: _buildSimpleFeature(
                    Icons.emergency,
                    'Emergency',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade400,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleFeature(IconData icon, String title) {
    return Card(
      color: Colors.grey.shade800,
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: PortColor.gold, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
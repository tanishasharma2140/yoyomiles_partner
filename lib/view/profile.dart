import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/custom_text_field.dart';
import 'package:yoyomiles_partner/res/image_preview_screen.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/service/background_service.dart';
import 'package:yoyomiles_partner/service/socket_service.dart';
import 'package:yoyomiles_partner/view/splash_screen.dart';
import 'package:yoyomiles_partner/view_model/online_status_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final profileData = profileViewModel.profileModel!.data!;

    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: PortColor.scaffoldBgGrey,
        body: CustomScrollView(
          slivers: [
            // App Bar Section
            SliverAppBar(
              expandedHeight: Sizes.screenHeight * 0.25,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFF176),
                        Color(0xFFFFD54F),
                        Color(0xFFFFA726),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Profile Image
                        GestureDetector(
                          onTap: () {
                            if (profileData.ownerSelfie!.isNotEmpty) {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => ImagePreviewScreen(imageUrl: profileData.ownerSelfie! ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: Sizes.screenWidth * 0.25,
                            height: Sizes.screenHeight * 0.12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: PortColor.white,
                                width: 3,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(
                                    profileData.ownerSelfie ?? ""),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Sizes.screenHeight * 0.01),
                        TextConst(
                          title: profileData.driverName ?? "Driver Name",
                          size: Sizes.fontSizeEight,
                          fontWeight: FontWeight.bold,
                          color: PortColor.white,
                        ),
                        SizedBox(height: Sizes.screenHeight * 0.005),
                        TextConst(
                          title: "Professional Driver",
                          size: Sizes.fontSizeSix,
                          color: PortColor.white.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: PortColor.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: PortColor.white,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _showLogoutDialog,
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: PortColor.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: PortColor.white,
                    ),
                  ),
                ),
              ],
            ),

            // Profile Information Section
            SliverList(
              delegate: SliverChildListDelegate([
                // Personal Information Card
                _buildInfoCard(
                  title: "Personal Information:",
                  icon: Icons.person_outline,
                  children: [
                    _buildInfoRow(
                      icon: Icons.person,
                      label: "Driver Name:",
                      value: profileData.driverName ?? "N/A",
                    ),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: "Phone Number:",
                      value: profileData.phone?.toString() ?? "N/A",
                    ),
                    _buildInfoRow(
                      icon: Icons.person,
                      label: "Owner Name:",
                      value: profileData.ownerName ?? "N/A",
                    ),
                    _buildInfoRow(
                      icon: Icons.directions_car,
                      label: "Vehicle Number:",
                      value: profileData.vehicleNo ?? "N/A",
                    ),
                    // Vehicle Information Section

                  ],
                ),

                _buildInfoCard(
                  title: "Vehicle Information:",
                  icon: Icons.local_shipping_outlined,
                  children: [

                    // 🚘 VEHICLE IMAGE
                    GestureDetector(
                      child: Center(
                        child: Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: PortColor.scaffoldBgGrey,
                            image: (profileData.vehicleTypeImage != null &&
                                profileData.vehicleTypeImage!.isNotEmpty)
                                ? DecorationImage(
                              image: NetworkImage(profileData.vehicleTypeImage!),
                              fit: BoxFit.contain,
                            )
                                : null,
                          ),
                          child: (profileData.vehicleTypeImage == null ||
                              profileData.vehicleTypeImage!.isEmpty)
                              ? const Center(
                            child: Icon(
                              Icons.local_shipping_rounded,
                              color: Colors.grey,
                              size: 60,
                            ),
                          )
                              : null,
                        ),
                      ),
                    ),

                    SizedBox(height: Sizes.screenHeight * 0.02),

                    _buildInfoRow(
                      icon: Icons.directions_car,
                      label: "Vehicle Body Type:",
                      value: profileData.vehicleBodyTypeName ?? "N/A",
                    ),
                    _buildInfoRow(
                      icon: Icons.directions_bus_filled,
                      label: "Vehicle Name:",
                      value: profileData.vehicleTypeName ?? "N/A",
                    ),
                  ],
                ),


                // Document Section - Aadhaar Card
                _buildDocumentSection(
                  title: "Aadhaar Card:",
                  frontImage: profileData.ownerAadhaarFront ?? "",
                  backImage: profileData.ownerAadhaarBack ?? "",
                ),

                // Document Section - PAN Card
                _buildDocumentSection(
                  title: "PAN Card:",
                  frontImage: profileData.ownerPanFornt ?? "",
                  backImage: profileData.ownerPanBack ?? "",
                ),

                // Document Section - Driving Licence
                _buildDocumentSection(
                  title: "Driving Licence",
                  frontImage: profileData.drivingLicenceFront ?? "",
                  backImage: profileData.drivingLicenceBack ?? "",
                ),

                // Document Section - RC Document
                _buildDocumentSection(
                  title: "RC Document",
                  frontImage: profileData.rcFront ?? "",
                  backImage: profileData.rcBack ?? "",
                ),

                SizedBox(height: Sizes.screenHeight * 0.03),
              ]),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.all(Sizes.screenWidth * 0.04),
      padding: EdgeInsets.all(Sizes.screenWidth * 0.04),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: PortColor.blue,
                size: 20,
              ),
              SizedBox(width: Sizes.screenWidth * 0.02),
              TextConst(
                title: title,
                size: Sizes.fontSizeSeven,
                fontWeight: FontWeight.bold,
                color: PortColor.blackLight,
              ),
            ],
          ),
          SizedBox(height: Sizes.screenHeight * 0.02),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Sizes.screenHeight * 0.008),
      child: Row(
        children: [
          Icon(
            icon,
            color: PortColor.gray,
            size: 18,
          ),
          SizedBox(width: Sizes.screenWidth * 0.03),
          SizedBox(
            width: 140,
            child: TextConst(
              title: label,
              size: Sizes.fontSizeSix,
              color: PortColor.gray,
            ),
          ),
          Expanded(
            flex: 3,
            child: TextConst(
              title: value,
              size: Sizes.fontSizeSix,
              fontWeight: FontWeight.w500,
              color: PortColor.gray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required String frontImage,
    required String backImage,
  }) {
    return Container(
      margin: EdgeInsets.all(Sizes.screenWidth * 0.02),
      padding: EdgeInsets.all(Sizes.screenWidth * 0.04),
      decoration: BoxDecoration(
        color: PortColor.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: PortColor.blue,
                size: 20,
              ),
              SizedBox(width: Sizes.screenWidth * 0.02),
              TextConst(
                title: title,
                size: Sizes.fontSizeSix,
                fontWeight: FontWeight.bold,
                color: PortColor.blackLight,
              ),
            ],
          ),
          SizedBox(height: Sizes.screenHeight * 0.02),
          Row(
            children: [
              Expanded(
                child: _buildDocumentImage(
                  label: "Front Side",
                  imageUrl: frontImage,
                ),
              ),
              SizedBox(width: Sizes.screenWidth * 0.03),
              Expanded(
                child: _buildDocumentImage(
                  label: "Back Side",
                  imageUrl: backImage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentImage({
    required String label,
    required String imageUrl,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (imageUrl.isNotEmpty) {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ImagePreviewScreen(imageUrl: imageUrl),
                ),
              );
            }
          },
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: PortColor.scaffoldBgGrey,
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: imageUrl.isEmpty
                ? Center(
              child: Icon(
                Icons.document_scanner_outlined,
                color: PortColor.gray,
                size: 40,
              ),
            )
                : null,
          ),
        ),
        SizedBox(height: Sizes.screenHeight * 0.008),
        TextConst(
          title: label,
          size: Sizes.fontSizeSix,
          color: PortColor.gray,
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showModalBottomSheet(
      backgroundColor: PortColor.scaffoldBgGrey,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          bottom: true,
          child: Container(
            padding: EdgeInsets.all(Sizes.screenHeight * 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PortColor.gray.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: Sizes.screenHeight * 0.02),
                 TextConst(
                  title: "Are you sure you want to log out?",
                  fontWeight: FontWeight.bold,
                  size: Sizes.fontSizeSeven,
                ),
                SizedBox(height: Sizes.screenHeight * 0.02),
                TextConst(
                  title: "You'll need to log in again to access your account.",
                  size: Sizes.fontSizeSix,
                  color: PortColor.gray,
                ),
                SizedBox(height: Sizes.screenHeight * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: Sizes.screenHeight * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          side: const BorderSide(color: PortColor.blue),
                        ),
                        child: const TextConst(
                          title: "Cancel",
                          fontWeight: FontWeight.bold,
                          color: PortColor.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: Sizes.screenWidth * 0.03),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {

                          // Navigator.pop(context); // Close bottom sheet

                          final onlineStatusVm =
                          Provider.of<OnlineStatusViewModel>(context, listen: false);
                          await onlineStatusVm.onlineStatusApi(context, 0);
                          await stopBackgroundService();

                          await UserViewModel().remove();

                          // 🔥 Navigate to splash
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SplashScreen(),
                            ),
                                (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PortColor.blue,
                          padding: EdgeInsets.symmetric(
                              vertical: Sizes.screenHeight * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const TextConst(
                          title: "Log Out",
                          fontWeight: FontWeight.bold,
                          color: PortColor.black,
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
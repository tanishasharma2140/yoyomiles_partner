import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/custom_text_field.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view_model/body_type_view_model.dart';
import 'package:yoyomiles_partner/view_model/cities_view_model.dart';
import 'package:yoyomiles_partner/view_model/driver_vehicle_view_model.dart';
import 'package:yoyomiles_partner/view_model/fuel_type_view_model.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:yoyomiles_partner/view_model/user_view_model.dart';
import 'package:yoyomiles_partner/view_model/vehicle_body_detail_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class VehicleDetail extends StatefulWidget {
  const VehicleDetail({super.key});

  @override
  State<VehicleDetail> createState() => _VehicleDetailState();
}

class _VehicleDetailState extends State<VehicleDetail> {
  final TextEditingController _vehicleNumberController =
  TextEditingController();

  // Variables to store IDs
  String? _selectedCityId;
  String? _selectedVehicleId;
  String? _selectedVehicleBodyDetailId;
  String? _selectedBodyTypeId;
  String? _selectedFuelTypeId;

  // Variables to store display names
  String? _selectedCityName;
  String? _selectedVehicleTypeName;
  String? _selectedVehicleBodyDetailName;
  String? _selectedBodyTypeName;
  String? _selectedFuelTypeName;

  bool _isLoadingBodyDetails = false;
  bool _isLoadingBodyTypes = false;
  bool _isLoadingFuelTypes = false;
  bool _isSubmitting = false;
  String? _vehicleErrorText;

  // New variables for delivery type
  int _selectedDeliveryType = 0; // 0 for parcel, 1 for passenger

  XFile? _rcFrontFile;
  XFile? _rcBackFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final citiesVm = Provider.of<CitiesViewModel>(context, listen: false);
      citiesVm.citiesApi();
      final driverVehicleVm = Provider.of<DriverVehicleViewModel>(
        context,
        listen: false,
      );
      driverVehicleVm.driverVehicleApi();
    });
  }

  // Filter vehicles based on delivery type
  void _filterVehiclesByDeliveryType(int deliveryType) {
    setState(() {
      _selectedDeliveryType = deliveryType;

      // Reset selections when delivery type changes
      _selectedVehicleTypeName = null;
      _selectedVehicleId = null;
      _selectedVehicleBodyDetailId = null;
      _selectedVehicleBodyDetailName = null;
      _selectedBodyTypeId = null;
      _selectedBodyTypeName = null;
      _selectedFuelTypeId = null;
      _selectedFuelTypeName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: PortColor.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextConst(
                title: "Vehicle Detail",
                size: Sizes.fontSizeSeven,
                fontWeight: FontWeight.bold,
              ),
              const Icon(Icons.headset_mic_rounded, color: Colors.black),
            ],
          ),
          shape: Border(
            bottom: BorderSide(
              color: PortColor.gray,
              width: Sizes.screenWidth * 0.001,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Type Radio Buttons

                // Vehicle Number Section
                _buildVehicleNumberSection(),
                const SizedBox(height: 24),

                // Vehicle RC Section
                _buildVehicleRCSection(),
                const SizedBox(height: 24),

                _buildDeliveryTypeSection(),
                const SizedBox(height: 24),

                // Vehicle Type Selection
                _buildVehicleTypeSection(),
                const SizedBox(height: 16),

                // Vehicle Body Detail (only for vehicles that have body details)
                if (_selectedVehicleTypeName != null &&
                    _shouldShowBodyDetailSection())
                  _buildVehicleBodyDetailSection(),

                // Body Type Selection (show directly for vehicle ID 3, or after body detail selection for others)
                if (_selectedVehicleTypeName != null &&
                    _shouldShowBodyTypeSection())
                  _buildBodyTypeSection(),
                if (_selectedBodyTypeName != null) const SizedBox(height: 16),

                // Fuel Type Selection (if body type selected)
                if (_selectedBodyTypeName != null) _buildFuelTypeSection(),
                if (_selectedFuelTypeName != null) const SizedBox(height: 24),

                // Continue Button
                if (_selectedFuelTypeName != null) _buildContinueButton(""),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New method for delivery type radio buttons
  Widget _buildDeliveryTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title: 'Select Delivery Type',
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Parcel Delivery Radio
            Expanded(
              child: _buildDeliveryTypeRadio(
                title: "Parcel Delivery",
                value: 0,
                icon: Icons.local_shipping,
              ),
            ),
            const SizedBox(width: 16),
            // Passenger Delivery Radio
            Expanded(
              child: _buildDeliveryTypeRadio(
                title: "Passenger Delivery",
                value: 1,
                icon: Icons.people,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryTypeRadio({
    required String title,
    required int value,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => _filterVehiclesByDeliveryType(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
        decoration: BoxDecoration(
          color: _selectedDeliveryType == value
              ? PortColor.gold.withOpacity(0.2)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedDeliveryType == value
                ? PortColor.gold
                : Colors.grey.shade300,
            width: _selectedDeliveryType == value ? 1 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: _selectedDeliveryType == value
                  ? PortColor.gold
                  : Colors.grey.shade600,
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: _selectedDeliveryType == value
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: _selectedDeliveryType == value
                    ? PortColor.black
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Check if vehicle has body details available
  bool _shouldShowBodyDetailSection() {
    if (_selectedVehicleId == null) return false;
    if (_selectedVehicleId == "3") return false;
    return true;
  }

  // Check if body type section should be shown
  bool _shouldShowBodyTypeSection() {
    if (_selectedVehicleId == null) return false;
    if (_selectedVehicleId == "3") return true;
    return _selectedVehicleBodyDetailName !=
        null; // Show after body detail for others
  }

  Widget _buildVehicleTypeSection() {
    final driverVehicleVm = Provider.of<DriverVehicleViewModel>(context);
    final vehicleList = driverVehicleVm.driverVehicleModel?.data;

    if (vehicleList == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vehicleList.isEmpty) {
      return const Center(child: Text("No vehicles available"));
    }

    // Filter vehicles based on delivery type
    List filteredVehicles = [];
    if (_selectedDeliveryType == 0) {
      // Parcel delivery - index 0 to 2
      if (vehicleList.length >= 3) {
        filteredVehicles = vehicleList.sublist(0, 3);
      } else {
        filteredVehicles = List.from(vehicleList);
      }
    } else {
      // Passenger delivery - index 3 to 4
      if (vehicleList.length >= 5) {
        filteredVehicles = vehicleList.sublist(3, 5);
      } else if (vehicleList.length >= 4) {
        filteredVehicles = vehicleList.sublist(3);
      } else {
        filteredVehicles = [];
      }
    }

    if (filteredVehicles.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextConst(
            title: 'Select Vehicle Type',
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                _selectedDeliveryType == 0
                    ? "No parcel delivery vehicles available"
                    : "No passenger delivery vehicles available",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title: 'Select Vehicle Type',
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: filteredVehicles.map((vehicle) {
            return Padding(
              padding: const EdgeInsets.only(right: 13),
              child: _buildVehicleTypeCard(
                imageUrl: vehicle.image ?? "",
                title: vehicle.name ?? "Unknown",
                color: PortColor.gold,
                isSelected: _selectedVehicleTypeName == vehicle.name,
                onTap: () => _selectVehicleType(
                  vehicle.name ?? "",
                  vehicle.id?.toString() ?? "",
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeCard({
    required String imageUrl,
    required String title,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? PortColor.gold.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected ? PortColor.gold : Colors.black,
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.directions_car,
                size: 40,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleBodyDetailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title: 'Select Vehicle Body Detail',
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _isLoadingBodyDetails
              ? null
              : _showVehicleBodyDetailBottomSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_isLoadingBodyDetails)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    _selectedVehicleBodyDetailName ??
                        "Select Vehicle Body Detail",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: _selectedVehicleBodyDetailName == null
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                  ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyTypeSection() {
    final bodyTypeVm = Provider.of<BodyTypeViewModel>(context);
    final bodyTypeList = bodyTypeVm.bodyTypeModel?.data;

    if (_isLoadingBodyTypes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bodyTypeList == null || bodyTypeList.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title: 'Select Vehicle Body Type',
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bodyTypeList.length,
            itemBuilder: (context, index) {
              final bodyType = bodyTypeList[index];
              return Container(
                width: 100,
                margin: EdgeInsets.only(
                  right: index == bodyTypeList.length - 1 ? 0 : 12,
                ),
                child: _buildBodyTypeCard(
                  imageUrl: bodyType.image ?? "",
                  title: bodyType.bodyType ?? "Unknown",
                  isSelected: _selectedBodyTypeName == bodyType.bodyType,
                  onTap: () => _selectBodyType(
                    bodyType.bodyType ?? "",
                    bodyType.id?.toString() ?? "",
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBodyTypeCard({
    required String imageUrl,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.directions_car,
                size: 40,
                color: Colors.grey,
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelTypeSection() {
    final fuelTypeVm = Provider.of<FuelTypeViewModel>(context, listen: false);
    final fuelTypeList = fuelTypeVm.fuelTypeModel?.data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title: 'Select Vehicle Fuel Type',
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
        if (_isLoadingFuelTypes)
          const Center(child: CircularProgressIndicator())
        else if (fuelTypeList == null || fuelTypeList.isEmpty)
          const Text(
            "No fuel types available for this vehicle",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey,
            ),
          )
        else
          GestureDetector(
            onTap: () => _showFuelTypeBottomSheet(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedFuelTypeName ?? "Select Vehicle Fuel Type",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: _selectedFuelTypeName == null
                          ? Colors.grey.shade600
                          : Colors.black,
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _selectVehicleType(String type, String id) {
    setState(() {
      _selectedVehicleTypeName = type;
      _selectedVehicleId = id;
      // Reset dependent selections when vehicle type changes
      _selectedVehicleBodyDetailId = null;
      _selectedVehicleBodyDetailName = null;
      _selectedBodyTypeId = null;
      _selectedBodyTypeName = null;
      _selectedFuelTypeId = null;
      _selectedFuelTypeName = null;
      _isLoadingBodyDetails = false;
      _isLoadingBodyTypes = false;
      _isLoadingFuelTypes = false;
    });

    print("Selected Vehicle Type ID: $id, Name: $type");

    // Load body types and fuel types for selected vehicle
    _loadBodyTypesForVehicle(id);
    _loadFuelTypesForVehicle(id);

    // Pre-load body details only for vehicles that need it (not for ID 3)
    if (id != "3") {
      _preLoadVehicleBodyDetails();
    }
  }

  void _selectBodyType(String type, String id) {
    setState(() {
      _selectedBodyTypeId = id;
      _selectedBodyTypeName = type;
      // Reset fuel type when body type changes
      _selectedFuelTypeId = null;
      _selectedFuelTypeName = null;
    });
    print("Selected Body Type ID: $id, Name: $type");
  }

  // Load body types based on vehicle ID
  void _loadBodyTypesForVehicle(String vehicleId) async {
    final bodyTypeVm = Provider.of<BodyTypeViewModel>(context, listen: false);

    try {
      setState(() {
        _isLoadingBodyTypes = true;
      });

      await bodyTypeVm.bodyTypeApi(vehicleId);

      setState(() {
        _isLoadingBodyTypes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBodyTypes = false;
      });
      print("Error loading body types: $e");
    }
  }

  // Load fuel types based on vehicle ID
  void _loadFuelTypesForVehicle(String vehicleId) async {
    final fuelTypeVm = Provider.of<FuelTypeViewModel>(context, listen: false);

    try {
      setState(() {
        _isLoadingFuelTypes = true;
      });

      await fuelTypeVm.fuelTypeApi(vehicleId);

      setState(() {
        _isLoadingFuelTypes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFuelTypes = false;
      });
      print("Error loading fuel types: $e");
    }
  }

  // Pre-load body details when vehicle is selected (only for non-scooter vehicles)
  void _preLoadVehicleBodyDetails() async {
    if (_selectedVehicleId == null || _selectedVehicleId!.isEmpty) return;

    final vehicleBodyDetailVm = Provider.of<VehicleBodyDetailViewModel>(
      context,
      listen: false,
    );

    try {
      setState(() {
        _isLoadingBodyDetails = true;
      });

      await vehicleBodyDetailVm.vehicleBodyDetailApi(_selectedVehicleId!);

      setState(() {
        _isLoadingBodyDetails = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBodyDetails = false;
      });
      print("Error pre-loading body details: $e");
    }
  }

  void _showVehicleBodyDetailBottomSheet() async {
    if (_selectedVehicleId == null || _selectedVehicleId!.isEmpty) {
      Utils.showErrorMessage(context, "Please select a vehicle type first.");
      return;
    }

    final vehicleBodyDetailVm = Provider.of<VehicleBodyDetailViewModel>(
      context,
      listen: false,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await vehicleBodyDetailVm.vehicleBodyDetailApi(_selectedVehicleId!);
      Navigator.pop(context);

      if (vehicleBodyDetailVm.vehicleBodyDetailModel?.data == null ||
          vehicleBodyDetailVm.vehicleBodyDetailModel!.data!.isEmpty) {
        Utils.showErrorMessage(
          context,
          "No body details available for this vehicle.",
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Consumer<VehicleBodyDetailViewModel>(
            builder: (context, vehicleBodyDetailVm, child) {
              return Container(
                color: PortColor.white,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        "Select Vehicle Body Detail",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: vehicleBodyDetailVm
                            .vehicleBodyDetailModel!
                            .data!
                            .length,
                        itemBuilder: (context, index) {
                          final vehicleBody = vehicleBodyDetailVm
                              .vehicleBodyDetailModel!
                              .data![index];
                          return ListTile(
                            title: Text(
                              vehicleBody.bodyDetail ?? 'No Name',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                _selectedVehicleBodyDetailId = vehicleBody.id
                                    ?.toString();
                                _selectedVehicleBodyDetailName =
                                    vehicleBody.bodyDetail;
                              });
                              print(
                                "Selected Vehicle Body Detail ID: $_selectedVehicleBodyDetailId, Name: $_selectedVehicleBodyDetailName",
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      Navigator.pop(context);
      Utils.showErrorMessage(
        context,
        "Error loading body details: ${e.toString()}",
      );
    }
  }

  void _showFuelTypeBottomSheet() {
    if (_selectedVehicleId == null) return;

    final fuelTypeVm = Provider.of<FuelTypeViewModel>(context, listen: false);
    final fuelTypeList = fuelTypeVm.fuelTypeModel?.data;

    if (fuelTypeList == null || fuelTypeList.isEmpty) {
      Utils.showErrorMessage(
        context,
        "No fuel types available for this vehicle.",
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          color: PortColor.white,
          height: Sizes.screenHeight * 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  "Select Vehicle Fuel Type",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: fuelTypeList.length,
                  itemBuilder: (context, index) {
                    final fuelVehicle = fuelTypeList[index];
                    return ListTile(
                      title: Text(
                        fuelVehicle.fuelType ?? 'Unknown',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedFuelTypeId = fuelVehicle.id?.toString();
                          _selectedFuelTypeName = fuelVehicle.fuelType;
                        });
                        print(
                          "Selected Fuel Type ID: $_selectedFuelTypeId, Name: $_selectedFuelTypeName",
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVehicleNumberSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title: 'Vehicle Number *',
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          size: 15,
        ),
        const SizedBox(height: 8),

        // Vehicle Number Input Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CustomTextField(
            controller: _vehicleNumberController,
            hintText: "Enter Vehicle Number",
            hintStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              UpperCaseTextFormatter(),
              LengthLimitingTextInputFormatter(10),
            ],
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            prefixIcon: const Icon(
              Icons.directions_car,
              color: Colors.grey,
              size: 24,
            ),
            onChanged: (value) {
              final text = value.trim();
              final pattern = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{2}\d{4}$');

              setState(() {
                if (text.isEmpty) {
                  _vehicleErrorText = 'Please enter vehicle number';
                } else if (!pattern.hasMatch(text)) {
                  _vehicleErrorText = 'Invalid format (e.g., DL01AB1234)';
                } else {
                  _vehicleErrorText = null;
                }
              });
            },
          ),
        ),

        // Error message below field
        if (_vehicleErrorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8),
            child: Text(
              _vehicleErrorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  String? validateVehicleNumber(String value) {
    final RegExp vehicleRegExp = RegExp(
      r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$',
    );

    if (value.isEmpty) {
      return 'Vehicle number is required';
    } else if (!vehicleRegExp.hasMatch(value)) {
      return 'Enter a valid vehicle number (e.g., MH12AB1234)';
    }
    return null;
  }

  Widget _buildVehicleRCSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRCUploadSection(),
        const SizedBox(height: 16),
        const Text(
          'Select the city of operation',
          style: TextStyle(
            fontFamily: 'Kannit',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final citiesVm = Provider.of<CitiesViewModel>(
              context,
              listen: false,
            );

            final selected = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                List filteredCities =
                List.from(citiesVm.citiesModel?.data ?? []);
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      color: PortColor.white,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Select the city of operation",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            hintText: "Search City",
                            height: 40,
                            prefixIcon: Icon(Icons.search),
                            onChanged: (value) {
                              setModalState(() {
                                filteredCities = citiesVm.citiesModel?.data
                                    ?.where((city) => city.cityName!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                    .toList() ??
                                    [];
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          const Divider(height: 1, thickness: 1),
                          Expanded(
                            child: filteredCities.isEmpty
                                ? const Center(
                              child: Text('No cities found'),
                            )
                                : ListView.builder(
                              itemCount: filteredCities.length,
                              itemBuilder: (context, index) {
                                final city = filteredCities[index];
                                final isSelected =
                                    city.id == _selectedCityId;
                                return Container(
                                  color: isSelected
                                      ? Colors.blue.shade50
                                      : Colors.transparent,
                                  child: ListTile(
                                    title: Text(
                                      city.cityName!,
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.black,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, {
                                        'id': city.id.toString(),
                                        'name': city.cityName,
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );

            if (selected != null) {
              setState(() {
                _selectedCityId = selected['id'];
                _selectedCityName = selected['name'];
              });
              print(
                "Selected City ID: $_selectedCityId, Name: $_selectedCityName",
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCityName ?? "Select the city of operation",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: _selectedCityName == null
                        ? Colors.grey.shade600
                        : Colors.black,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRCUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title: 'Upload RC Document *',
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          size: 15,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildUploadButton(
                text: _rcFrontFile != null ? 'Front Uploaded' : 'Front Side',
                onPressed: () => _uploadRCDocument('front'),
                isUploaded: _rcFrontFile != null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUploadButton(
                text: _rcBackFile != null ? 'Back Uploaded' : 'Back Side',
                onPressed: () => _uploadRCDocument('back'),
                isUploaded: _rcBackFile != null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildRCStatusIndicator(),
      ],
    );
  }

  Widget _buildUploadButton({
    required String text,
    required VoidCallback onPressed,
    bool isUploaded = false, // ✅ Add uploaded flag
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isUploaded
                ? Colors.green
                : Colors.grey.shade400, // ✅ dynamic border
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 16,
              color: isUploaded
                  ? Colors.green
                  : Colors.grey.shade600, // ✅ icon color
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isUploaded
                    ? Colors.green
                    : Colors.grey.shade700, // ✅ text color
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRCStatusIndicator() {
    if (_rcFrontFile != null && _rcBackFile != null) {
      return const TextConst(
        title: 'Uploaded',
        color: Colors.green,
        fontWeight: FontWeight.w600,
        size: 14,
      );
    } else {
      return const TextConst(
        title: 'Pending',
        color: Colors.red,
        fontWeight: FontWeight.w500,
        size: 14,
      );
    }
  }

  Widget _buildContinueButton(String userId) {
    return GestureDetector(
      onTap: _isSubmitting ? null : () => _submitVehicleDetails(userId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: PortColor.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: _isSubmitting
            ? SizedBox(
          height: 18,
          width: 18,
          child: CupertinoActivityIndicator(
            color: Colors.white,
            radius: 12,
          ),
        )
            : const TextConst(
          title: 'Continue',
          size: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _uploadRCDocument(String side) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        if (side == 'front') {
          _rcFrontFile = pickedFile;
          print("RC Front captured: ${pickedFile.path}");
        } else {
          _rcBackFile = pickedFile;
          print("RC Back captured: ${pickedFile.path}");
        }
      });
    }
  }

  // API Call to submit vehicle details
  Future<void> _submitVehicleDetails(String userId) async {
    UserViewModel userViewModel = UserViewModel();
    int? userId = (await userViewModel.getUser());

    // Validation
    if (_vehicleNumberController.text.isEmpty) {
      Utils.showErrorMessage(context, "Please enter vehicle number");
      return;
    }

    if (_rcFrontFile == null || _rcBackFile == null) {
      Utils.showErrorMessage(context, "Please upload both RC front and back");
      return;
    }

    if (_selectedCityId == null) {
      Utils.showErrorMessage(context, "Please select city");
      return;
    }

    if (_selectedVehicleId == null) {
      Utils.showErrorMessage(context, "Please select vehicle type");
      return;
    }

    if (_selectedVehicleBodyDetailId == null && _selectedVehicleId != "3") {
      Utils.showErrorMessage(context, "Please select vehicle body detail");
      return;
    }

    if (_selectedBodyTypeId == null) {
      Utils.showErrorMessage(context, "Please select body type");
      return;
    }

    if (_selectedFuelTypeId == null) {
      Utils.showErrorMessage(context, "Please select fuel type");
      return;
    }

    // Print all selected IDs before API call
    print("=== SUBMITTING VEHICLE DETAILS ===");
    print("User ID: $userId");
    print("Vehicle Number: ${_vehicleNumberController.text}");
    print("City ID: $_selectedCityId");
    print("Vehicle Type ID: $_selectedVehicleId");
    print("Vehicle Body Detail ID: $_selectedVehicleBodyDetailId");
    print("Body Type ID: $_selectedBodyTypeId");
    print("Fuel Type ID: $_selectedFuelTypeId");
    print("RC Front: ${_rcFrontFile?.path}");
    print("RC Back: ${_rcBackFile?.path}");
    print("===================================");

    setState(() {
      _isSubmitting = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://yoyomiles.codescarts.com/api/driver_register'),
      );

      print("📤 Sending User ID in API request: $userId");

      request.fields['id'] = userId.toString();
      request.fields['owner_doc_status'] = '2';
      request.fields['vehicle_doc_status'] = '1';
      request.fields['driver_doc_status'] = '2';
      request.fields['vehicle_no'] = _vehicleNumberController.text;
      request.fields['city_id'] = _selectedCityId!; // ID भेजें
      request.fields['vehicle_type'] = _selectedVehicleId!; // ID भेजें

      // For scooter, we might not have body details
      if (_selectedVehicleBodyDetailId != null) {
        request.fields['vehicle_body_details_type'] =
        _selectedVehicleBodyDetailId!; // ID भेजें
      } else {
        request.fields['vehicle_body_details_type'] = '0';
      }

      request.fields['vehicle_body_type'] = _selectedBodyTypeId!; // ID भेजें
      request.fields['fuel_type'] = _selectedFuelTypeId!; // ID भेजें

      // Add RC front file
      if (_rcFrontFile != null) {
        var rcFrontFile = await http.MultipartFile.fromPath(
          'rc_front',
          _rcFrontFile!.path,
        );
        request.files.add(rcFrontFile);
      }

      // Add RC back file
      if (_rcBackFile != null) {
        var rcBackFile = await http.MultipartFile.fromPath(
          'rc_back',
          _rcBackFile!.path,
        );
        request.files.add(rcBackFile);
      }

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        print("✅ API Response Success - User ID used: $userId");
        print("📋 API Response: ${jsonResponse['message']}");
        Utils.showSuccessMessage(context, jsonResponse['message']);

        // Error
        // Utils.showErrorMessage(context, jsonResponse['message']);

        final profileVm = Provider.of<ProfileViewModel>(context, listen: false);

        await profileVm.profileApi();
        final profile = profileVm.profileModel?.data;

        if (profile == null) {
          Utils.showErrorMessage(context, "Profile not loaded. Try again.");
          return;
        }

        debugPrint(
          "OwnerDoc: ${profile.ownerDocStatus}, VehicleDoc: ${profile.vehicleDocStatus}, DriverDoc: ${profile.driverDocStatus}",
        );

        if (profile.ownerDocStatus == 0 || profile.ownerDocStatus == 2) {
          Navigator.pushNamed(
            context,
            RoutesName.owner,
            arguments: {'user_id': userId},
          );
        } else if (profile.vehicleDocStatus == 0 ||
            profile.vehicleDocStatus == 2) {
          Navigator.pushNamed(
            context,
            RoutesName.vehicleDetail,
            arguments: {'user_id': userId},
          );
        } else if (profile.driverDocStatus == 0 ||
            profile.driverDocStatus == 2) {
          print(" Navigating to AddDriverDetail screen with User ID: $userId");
          Navigator.pushNamed(
            context,
            RoutesName.addDriverDetail,
            arguments: {'user_id': userId},
          );
        } else if (profile.ownerDocStatus == 1 &&
            profile.vehicleDocStatus == 1 &&
            profile.driverDocStatus == 1) {
          Navigator.pushNamed(
            context,
            RoutesName.register,
            arguments: {'user_id': userId},
          );
        } else {
          Navigator.pushNamed(
            context,
            RoutesName.register,
            arguments: {'user_id': userId},
          );
        }
      } else {
        Utils.showErrorMessage(
          context,
          jsonResponse['message'] ?? 'Unknown error',
        );
        // Error
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      Utils.showErrorMessage(
        context,
        "Error submitting vehicle details: ${e.toString()}",
      );
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _vehicleNumberController = TextEditingController();

  // Variables to store IDs
  String? _selectedCityId;
  String? _selectedVehicleTypeId;
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
          context, listen: false);
      driverVehicleVm.driverVehicleApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // Vehicle Number Section
              _buildVehicleNumberSection(),
              const SizedBox(height: 24),

              // Vehicle RC Section
              _buildVehicleRCSection(),
              const SizedBox(height: 24),

              // Vehicle Type Selection
              _buildVehicleTypeSection(),
              const SizedBox(height: 16),

              // Vehicle Body Detail (only for vehicles that have body details)
              if (_selectedVehicleTypeName != null &&
                  _shouldShowBodyDetailSection())
                _buildVehicleBodyDetailSection(),

              // Body Type Selection (show directly for vehicle ID 3, or after body detail selection for others)
              if (_selectedVehicleTypeName != null && _shouldShowBodyTypeSection())
                _buildBodyTypeSection(),
              if (_selectedBodyTypeName != null) const SizedBox(height: 16),

              // Fuel Type Selection (if body type selected)
              if (_selectedBodyTypeName != null) _buildFuelTypeSection(),
              if (_selectedFuelTypeName != null) const SizedBox(height: 24),

              // Continue Button
              if (_selectedFuelTypeName != null)
                _buildContinueButton(""),
            ],
          ),
        ),
      ),
    );
  }

  // Check if vehicle has body details available
  bool _shouldShowBodyDetailSection() {
    if (_selectedVehicleId == null) return false;
    if (_selectedVehicleId == "3") return false; // Skip for scooter
    return true;
  }

  // Check if body type section should be shown
  bool _shouldShowBodyTypeSection() {
    if (_selectedVehicleId == null) return false;
    if (_selectedVehicleId == "3") return true; // Show directly for scooter
    return _selectedVehicleBodyDetailName != null; // Show after body detail for others
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title: 'Select Vehicle Type',
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: vehicleList.map((vehicle) {
              return Padding(
                padding: const EdgeInsets.only(right: 25),
                child: _buildVehicleTypeCard(
                  imageUrl: vehicle.image ?? "",
                  title: vehicle.name ?? "Unknown",
                  color: Colors.blue,
                  isSelected: _selectedVehicleTypeName == vehicle.name,
                  onTap: () =>
                      _selectVehicleType(
                        vehicle.name ?? "",
                        vehicle.id?.toString() ?? "",
                      ),
                ),
              );
            }).toList(),
          ),
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? PortColor.greyLight : Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              imageUrl,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(
                  Icons.directions_car,
                  size: 40,
                  color: Colors.grey),
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
                    _selectedVehicleBodyDetailName ?? "Select Vehicle Body Detail",
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
                  onTap: () =>
                      _selectBodyType(
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
              errorBuilder: (context, error, stackTrace) =>
              const Icon(
                  Icons.directions_car,
                  size: 40,
                  color: Colors.grey),
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
        else
          if (fuelTypeList == null || fuelTypeList.isEmpty)
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
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
        context, listen: false);

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a vehicle type first.")),
      );
      return;
    }

    final vehicleBodyDetailVm = Provider.of<VehicleBodyDetailViewModel>(
        context, listen: false);

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("No body details available for this vehicle.")),
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
                          horizontal: 16, vertical: 12),
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
                        itemCount: vehicleBodyDetailVm.vehicleBodyDetailModel!
                            .data!.length,
                        itemBuilder: (context, index) {
                          final vehicleBody = vehicleBodyDetailVm
                              .vehicleBodyDetailModel!.data![index];
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
                                _selectedVehicleBodyDetailId = vehicleBody.id?.toString();
                                _selectedVehicleBodyDetailName = vehicleBody.bodyDetail;
                              });
                              print("Selected Vehicle Body Detail ID: $_selectedVehicleBodyDetailId, Name: $_selectedVehicleBodyDetailName");
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading body details: ${e.toString()}")),
      );
    }
  }

  void _showFuelTypeBottomSheet() {
    if (_selectedVehicleId == null) return;

    final fuelTypeVm = Provider.of<FuelTypeViewModel>(context, listen: false);
    final fuelTypeList = fuelTypeVm.fuelTypeModel?.data;

    if (fuelTypeList == null || fuelTypeList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("No fuel types available for this vehicle.")),
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
                        print("Selected Fuel Type ID: $_selectedFuelTypeId, Name: $_selectedFuelTypeName");
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
        CustomTextField(
          controller: _vehicleNumberController,
          hintText: "Vehicle Number",
          hintStyle: const TextStyle(color: PortColor.gray),
        )
      ],
    );
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
            final citiesVm = Provider.of<CitiesViewModel>(context, listen: false);
            final selected = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              builder: (context) {
                return Container(
                  color: PortColor.white,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          "Select the city of operation",
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
                          itemCount: citiesVm.citiesModel?.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            final city = citiesVm.citiesModel!.data![index];
                            final isSelected = city.id == _selectedCityId;
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
                                    color: isSelected ? Colors.blue : Colors.black,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context, {
                                    'id': city.id.toString(),
                                    'name': city.cityName
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
            if (selected != null) {
              setState(() {
                _selectedCityId = selected['id'];
                _selectedCityName = selected['name'];
              });
              print("Selected City ID: $_selectedCityId, Name: $_selectedCityName");
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
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUploadButton(
                text: _rcBackFile != null ? 'Back Uploaded' : 'Back Side',
                onPressed: () => _uploadRCDocument('back'),
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
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 16,
                color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
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
    return _isSubmitting
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
      onTap: () {
        _submitVehicleDetails(userId);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: PortColor.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: const TextConst(
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter vehicle number")),
      );
      return;
    }

    if (_rcFrontFile == null || _rcBackFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload both RC front and back")),
      );
      return;
    }

    if (_selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select city")),
      );
      return;
    }

    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select vehicle type")),
      );
      return;
    }

    if (_selectedVehicleBodyDetailId == null && _selectedVehicleId != "3") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select vehicle body detail")),
      );
      return;
    }

    if (_selectedBodyTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select body type")),
      );
      return;
    }

    if (_selectedFuelTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select fuel type")),
      );
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
        request.fields['vehicle_body_details_type'] = _selectedVehicleBodyDetailId!; // ID भेजें
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'] ?? "Vehicle details submitted successfully!")),
        );

        final profileVm = Provider.of<ProfileViewModel>(context, listen: false);

        await profileVm.profileApi();
        final profile = profileVm.profileModel?.data;

        if (profile == null) {
          Utils.showErrorMessage(context, "Profile not loaded. Try again.");
          return;
        }

        debugPrint("OwnerDoc: ${profile.ownerDocStatus}, VehicleDoc: ${profile.vehicleDocStatus}, DriverDoc: ${profile.driverDocStatus}");

        if (profile.ownerDocStatus == 0 || profile.ownerDocStatus == 2) {
          Navigator.pushNamed(context, RoutesName.owner, arguments: {'user_id': userId});
        } else if (profile.vehicleDocStatus == 0 || profile.vehicleDocStatus == 2) {
          Navigator.pushNamed(context, RoutesName.vehicleDetail, arguments: {'user_id': userId});
        } else if (profile.driverDocStatus == 0 || profile.driverDocStatus == 2) {
          print(" Navigating to AddDriverDetail screen with User ID: $userId");
          Navigator.pushNamed(context, RoutesName.addDriverDetail, arguments: {'user_id': userId});
        } else if (profile.ownerDocStatus == 1 &&
            profile.vehicleDocStatus == 1 &&
            profile.driverDocStatus == 1) {
          Navigator.pushNamed(context, RoutesName.register, arguments: {'user_id': userId});
        } else {
          Navigator.pushNamed(context, RoutesName.register, arguments: {'user_id': userId});
        }
      } else {
        // Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'] ?? 'Unknown error')),
        );
      }

    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting vehicle details: ${e.toString()}")),
      );
    }
  }
}
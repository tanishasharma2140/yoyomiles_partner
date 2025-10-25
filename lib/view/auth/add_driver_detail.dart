import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yoyomiles_partner/main.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/custom_text_field.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:http/http.dart' as http;
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

class AddDriverDetail extends StatefulWidget {
  const AddDriverDetail({super.key});

  @override
  State<AddDriverDetail> createState() => _AddDriverDetailState();
}

class _AddDriverDetailState extends State<AddDriverDetail> {
  bool? _isDrivingVehicle;
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverPhoneController = TextEditingController();

  File? _frontLicense;
  File? _backLicense;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<File?> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Image compression function
  Future<File> _compressImage(File file, {int maxWidth = 1024, int quality = 80}) async {
    try {
      final bytes = await file.readAsBytes();

      // Decode the image
      final image = img.decodeImage(bytes);
      if (image == null) return file;

      // Calculate new dimensions while maintaining aspect ratio
      int newWidth = image.width;
      int newHeight = image.height;

      if (image.width > maxWidth) {
        newWidth = maxWidth;
        newHeight = (image.height * maxWidth / image.width).round();
      }

      // Resize the image
      final resizedImage = img.copyResize(image, width: newWidth, height: newHeight);

      // Encode to JPEG with reduced quality
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      // Create temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      print('Image compressed: ${bytes.length ~/ 1024}KB -> ${compressedBytes.length ~/ 1024}KB');
      return tempFile;
    } catch (e) {
      print('Image compression failed: $e');
      return file; // Return original file if compression fails
    }
  }

  // API Call Function with compression
  Future<void> _registerDriver({
    required String id,
    required String driverName,
    required File drivingLicenceBack,
    required File drivingLicenceFront,
    required String phone,
    required String driveOperator,
    required BuildContext context,
  }) async {

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var url = Uri.parse("https://yoyomiles.codescarts.com/api/driver_register");
      var request = http.MultipartRequest('POST', url);

      // Add text fields
      request.fields.addAll({
        "id": id,
        "owner_doc_status": "2",
        "vehicle_doc_status": "2",
        "driver_doc_status": "1",
        "driver_name": driverName,
        "phone": phone,
        "fcm": fcmToken.toString(),
        "drive_operator": driveOperator,
      });


      // Compress images before uploading
      final compressedFiles = await Future.wait([
        _compressImage(drivingLicenceBack),
        _compressImage(drivingLicenceFront),
      ]);

      print("✅ Compression done, adding files...");
      print("   - Compressed back license: ${compressedFiles[0].path}");
      print("   - Compressed front license: ${compressedFiles[1].path}");

      request.files.add(await http.MultipartFile.fromPath(
        "driving_licence_back",
        compressedFiles[0].path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        "driving_licence_front",
        compressedFiles[1].path,
      ));

      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      setState(() {
        _isLoading = false;
      });


      if (response.statusCode == 200) {
        final value = jsonDecode(response.body);


        if (value['success'] == true) {
          final profileVm = Provider.of<ProfileViewModel>(context, listen: false);

          // Refresh profile before navigating
          await profileVm.profileApi();
          final profile = profileVm.profileModel?.data;

          if (profile == null) {
            _showErrorDialog(context, "Profile not loaded. Try again");
            return;
          }

          if (profile.ownerDocStatus == 0 || profile.ownerDocStatus == 2) {
            Navigator.pushNamed(context, RoutesName.owner, arguments: {'user_id': value['user_id']});
          } else if (profile.vehicleDocStatus == 0 || profile.vehicleDocStatus == 2) {
            Navigator.pushNamed(context, RoutesName.vehicleDetail, arguments: {'user_id': value['user_id']});
          } else if (profile.driverDocStatus == 0 || profile.driverDocStatus == 2) {
            Navigator.pushNamed(context, RoutesName.addDriverDetail, arguments: {'user_id': value['user_id']});
          } else if (profile.ownerDocStatus == 1 &&
              profile.vehicleDocStatus == 1 &&
              profile.driverDocStatus == 1) {
            Navigator.pushNamed(context, RoutesName.register, arguments: {'user_id': value['user_id']});
          } else {
            Navigator.pushNamed(context, RoutesName.register, arguments: {'user_id': value['user_id']});
          }


        } else {
          _showErrorDialog(context, value["message"] ?? "Registration failed");
        }

      } else if (response.statusCode == 413) {
        _showErrorDialog(context, "File sizes too large. Try smaller images.");
      } else {
        _showErrorDialog(context, "Server error: ${response.statusCode}");
      }

    } catch (error) {
      setState(() => _isLoading = false);


      if (error is TimeoutException) {
        _showErrorDialog(context, "Request timeout. Check internet and try again.");
      } else {
        _showErrorDialog(context, "Registration failed: $error");
      }
    } finally {
      // Clean up temporary compressed files
      for (var file in [drivingLicenceBack, drivingLicenceFront]) {
        try {
          if (file.path.contains('compressed_')) {
            await file.delete();
          }
        } catch (_) {
          print("⚠️ Could not delete file: ${file.path}");
        }
      }
    }
  }




  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  bool _validateForm() {
    if (_isDrivingVehicle == null) {
      _showErrorDialog(context, "Please select if you will be driving the vehicle");
      return false;
    }
    if (_driverNameController.text.isEmpty) {
      _showErrorDialog(context, "Please enter driver name");
      return false;
    }
    if (_driverPhoneController.text.isEmpty) {
      _showErrorDialog(context, "Please enter driver phone number");
      return false;
    }
    if (_frontLicense == null) {
      _showErrorDialog(context, "Please upload front license");
      return false;
    }
    if (_backLicense == null) {
      _showErrorDialog(context, "Please upload back license");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final String driveOperator = _isDrivingVehicle == true ? "1" : "2";
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final String userId = args['user_id'].toString();
    print("Received userId in AddDriverDetail: $userId");


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
              title:
              "Add Driver Detail",
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper Indicator
            _buildStepIndicator(),
            const SizedBox(height: 32),

            // I will be driving this vehicle section
            _buildDrivingQuestionSection(),
            const SizedBox(height: 24),

            // Driver Name Section
            _buildDriverNameSection(),
            const SizedBox(height: 20),

            // Driver Phone Number Section
            _buildDriverPhoneSection(),
            const SizedBox(height: 20),

            // Upload Driver License Section
            _buildLicenseUploadSection(),
            const SizedBox(height: 100),

            // Submit Button
            GestureDetector(
              onTap: _isLoading ? null : () {
                if (_validateForm()) {

                  _registerDriver(
                    id: userId,
                    driverName: _driverNameController.text,
                    drivingLicenceBack: _backLicense!,
                    drivingLicenceFront: _frontLicense!,
                    phone: _driverPhoneController.text,
                    driveOperator: driveOperator,
                    context: context,
                  );
                } else {
                  print("❌ Form validation failed");
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey : PortColor.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(1, 'Owner', isCompleted: true),
        _buildDashLine(isCompleted: true),
        _buildStep(2, 'Vehicle', isCompleted: true),
        _buildDashLine(isActive: true),
        _buildStep(3, 'Driver', isActive: true),
      ],
    );
  }

  Widget _buildStep(int stepNumber, String title, {bool isActive = false, bool isCompleted = false}) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? PortColor.blue : (isCompleted ? PortColor.blue : Colors.grey.shade300),
            border: Border.all(
              color: isActive ? PortColor.blue : (isCompleted ? PortColor.blue : Colors.grey),
              width: 1,
            ),
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : TextConst(
            title:
            stepNumber.toString(),
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextConst(
          title:
          title,
          size: 13,
          fontWeight: FontWeight.w600,
          color: isActive ? PortColor.blue : (isCompleted ? PortColor.blue : Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDashLine({bool isCompleted = false, bool isActive = false}) {
    Color lineColor;
    if (isActive) {
      lineColor = PortColor.blue;
    } else if (isCompleted) {
      lineColor = Colors.green;
    } else {
      lineColor = Colors.grey;
    }

    return Row(
      children: List.generate(
        8,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 1,
          color: lineColor,
        ),
      ),
    );
  }

  Widget _buildDrivingQuestionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'I will be driving this vehicle *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _isDrivingVehicle,
                      activeColor: PortColor.blue,
                      onChanged: (value) {
                        setState(() => _isDrivingVehicle = value);
                      },
                    ),
                    const Text("Yes"),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: Colors.grey,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: _isDrivingVehicle,
                      activeColor: PortColor.blue,
                      onChanged: (value) {
                        setState(() => _isDrivingVehicle = value);
                      },
                    ),
                    const Text("No"),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDriverNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title:
          'Driver Name *',
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          size: 15,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _driverNameController,
          hintText: "Enter Name",
          hintStyle: TextStyle(color: PortColor.gray),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
        )
      ],
    );
  }

  Widget _buildDriverPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title:
          'Driver Phone Number*',
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          size: 15,
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: _driverPhoneController,
          hintText: "Driver Phone Number",
          hintStyle: TextStyle(color: PortColor.gray),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        )
      ],
    );
  }

  Widget _buildLicenseUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TextConst(
          title:
          'Upload Driver License *',
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          size: 15,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Front License
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final image = await _pickImage();
                  if (image != null) {
                    setState(() {
                      _frontLicense = image;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _frontLicense != null ? Colors.green.shade50 : Colors.white,
                    border: Border.all(
                      color: _frontLicense != null ? Colors.green : Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _frontLicense != null ? Icons.check_circle : Icons.camera_alt,
                        color: _frontLicense != null ? Colors.green : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _frontLicense != null ? 'Uploaded' : 'Front',
                        style: TextStyle(
                          fontSize: 12,
                          color: _frontLicense != null ? Colors.green : Colors.grey,
                          fontWeight: _frontLicense != null ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Back License
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final image = await _pickImage();
                  if (image != null) {
                    setState(() {
                      _backLicense = image;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _backLicense != null ? Colors.green.shade50 : Colors.white,
                    border: Border.all(
                      color: _backLicense != null ? Colors.green : Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _backLicense != null ? Icons.check_circle : Icons.camera_alt,
                        color: _backLicense != null ? Colors.green : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _backLicense != null ? 'Uploaded' : 'Back',
                        style: TextStyle(
                          fontSize: 12,
                          color: _backLicense != null ? Colors.green : Colors.grey,
                          fontWeight: _backLicense != null ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    super.dispose();
  }
}
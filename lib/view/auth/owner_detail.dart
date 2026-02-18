import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:yoyomiles_partner/l10n/app_localizations.dart';
import 'package:yoyomiles_partner/res/app_fonts.dart';
import 'package:yoyomiles_partner/res/constant_color.dart';
import 'package:yoyomiles_partner/res/custom_text_field.dart';
import 'package:yoyomiles_partner/res/owner_details_appbar.dart';
import 'package:yoyomiles_partner/res/sizing_const.dart';
import 'package:yoyomiles_partner/res/text_const.dart';
import 'package:yoyomiles_partner/utils/routes/routes_name.dart';
import 'package:yoyomiles_partner/utils/utils.dart';
import 'package:yoyomiles_partner/view/profile.dart';
import 'package:yoyomiles_partner/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';

import '../../view_model/user_view_model.dart' show UserViewModel;

class OwnerDetail extends StatefulWidget {
  const OwnerDetail({super.key});

  @override
  _OwnerDetailState createState() => _OwnerDetailState();
}

class _OwnerDetailState extends State<OwnerDetail> {
  String? mobileNumber;
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, dynamic> aadhaarCard = {
    'front': null,
    'back': null,
    'status': 'upload',
  };

  Map<String, dynamic> panCard = {
    'front': null,
    'back': null,
    'status': 'upload',
  };

  Map<String, dynamic> selfie = {
    'front': null,
    'status': 'upload',
  };

  bool _isSubmitting = false;

  // Image compression function
  Future<File> _compressImage(File file,
      {int maxWidth = 1024, int quality = 80}) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return file;

      int newWidth = image.width;
      int newHeight = image.height;

      if (image.width > maxWidth) {
        newWidth = maxWidth;
        newHeight = (image.height * maxWidth / image.width).round();
      }

      final resizedImage =
          img.copyResize(image, width: newWidth, height: newHeight);
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      final tempDir = Directory.systemTemp;
      final tempFile = File(
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      debugPrint(
          'Image compressed: ${bytes.length ~/ 1024}KB -> ${compressedBytes.length ~/ 1024}KB');
      return tempFile;
    } catch (e) {
      debugPrint('Image compression failed: $e');
      return file;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && mobileNumber == null) {
      mobileNumber = args['phone'];
    }
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const OwnerDetailsAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Sizes.screenHeight * 0.02),

                  // Step Indicator
                  _buildStepIndicator(),
                  const SizedBox(height: 32),

                  // Name Field
                  _buildNameField(),
                  const SizedBox(height: 24),

                  // Upload Section
                  _buildUploadSection(),
                  const SizedBox(height: 32),

                  // Submit Button
                  _buildSubmitButton(),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final loc = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(1, loc.owner, isActive: true),
        _buildDashLine(),
        _buildStep(2, loc.vehicle, isActive: false),
        _buildDashLine(),
        _buildStep(3,loc.driver, isActive: false),
      ],
    );
  }

  Widget _buildStep(int stepNumber, String title, {bool isActive = false}) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? PortColor.blue : Colors.grey.shade300,
            border: Border.all(
              color: isActive ? PortColor.blue : Colors.grey,
              width: 1,
            ),
          ),
          child: TextConst(
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
          color: isActive ? PortColor.blue : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildDashLine() {
    return Row(
      children: List.generate(
        8,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 1,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         TextConst(
          title:
          loc.name,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          size: 15,
        ),
        const SizedBox(height: 5),
        CustomTextField(
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
          ],
          controller: _nameController,
          hintText: loc.enter_name,
          hintStyle: const TextStyle(color: PortColor.gray),
        ),
      ],
    );
  }

  Widget _buildUploadSection() {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         TextConst(
          title:
          loc.upload_the_following,
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          size: 15,
        ),
        const SizedBox(height: 13),

        // Aadhaar Card
        _buildDocumentItem(
          title: loc.owner_aadhaar,
          document: aadhaarCard,
          documentType: 'aadhaar',
        ),
        const SizedBox(height: 16),

        // PAN Card
        _buildDocumentItem(
          title: loc.owner_pan,
          document: panCard,
          documentType: 'pan',
        ),
        const SizedBox(height: 16),

        // Selfie
        _buildDocumentItem(
          title: loc.owner_selfie,
          document: selfie,
          documentType: 'selfie',
        ),
      ],
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required Map<String, dynamic> document,
    required String documentType,
  }) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Title
            TextConst(
              title:
              title,
              color: PortColor.darkBlue,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 10),

            // Upload Buttons
            Row(
              children: [
                if (documentType != 'selfie') ...[
                  Expanded(
                    child: _buildUploadButton(
                      text: loc.front_side,
                      documentType: documentType,
                      side: 'front',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUploadButton(
                      text: loc.back_side,
                      documentType: documentType,
                      side: 'back',
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: _buildUploadButton(
                      text: loc.take_selfie,
                      documentType: documentType,
                      side: 'front',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Status Indicator
            _buildStatusIndicator(
              document: document,
              documentType: documentType,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required String text,
    required String documentType,
    required String side,
  }) {
    // ✅ Check if this side is uploaded
    bool isUploaded = false;
    if (documentType == 'selfie') {
      isUploaded = selfie['front'] != null;
    } else if (documentType == 'aadhaar') {
      isUploaded = aadhaarCard[side] != null;
    } else if (documentType == 'pan') {
      isUploaded = panCard[side] != null;
    }

    return GestureDetector(
      onTap: () => _pickImage(documentType, side),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isUploaded ? Colors.green : Colors.grey.shade400,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined,
                size: 16, color: isUploaded ? Colors.green : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isUploaded ? Colors.green : Colors.grey.shade700,
                fontFamily: AppFonts.kanitReg
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStatusIndicator({
    required Map<String, dynamic> document,
    required String documentType, // Add this
  }) {
    final bool isComplete = documentType == 'selfie'
        ? document['front'] != null
        : document['front'] != null && document['back'] != null;
    final loc = AppLocalizations.of(context)!;


    final String text = isComplete ? loc.uploaded : "Upload";
    final Color color = isComplete ? Colors.green : Colors.blue;

    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontFamily: AppFonts.kanitReg,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  Widget _buildSubmitButton() {
    final loc = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _isSubmitting ? null : _submitOwnerDetails,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _isSubmitting ? Colors.grey : PortColor.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            :  TextConst(
          title:
          loc.submit,
                fontWeight: FontWeight.w500,
                color: PortColor.black,
                size: 16,
              ),
      ),
    );
  }

  Future<void> _pickImage(String documentType, String side) async {
    try {
      XFile? image;

      // 👇 If it's a selfie, open FRONT camera
      if (documentType == 'selfie') {
        image = await _picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.front,
          maxWidth: 1024,
          imageQuality: 80,
        );
      } else {
        // Aadhaar / PAN uses rear camera
        image = await _picker.pickImage(
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear,
          maxWidth: 1024,
          imageQuality: 80,
        );
      }

      if (image != null) {
        final imagePath = image.path; // ✅ safely store path here

        setState(() {
          if (documentType == 'aadhaar') {
            aadhaarCard[side] = imagePath;
          } else if (documentType == 'pan') {
            panCard[side] = imagePath;
          } else if (documentType == 'selfie') {
            selfie[side] = imagePath;
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (!mounted) return;
      Utils.showErrorMessage(context, 'Failed to pick image: $e');
    }
  }



  bool _validateForm() {
    final loc = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if(_nameController.text.isEmpty){
      Utils.showErrorMessage(context, loc.please_enter_name);
      return false;
    }

    if (aadhaarCard['front'] == null || aadhaarCard['back'] == null) {
      Utils.showErrorMessage(
          context, loc.please_upload_both_aadhaar);
      return false;
    }

    if (panCard['front'] == null || panCard['back'] == null) {
      Utils.showErrorMessage(context, loc.please_upload_both_pan);
      return false;
    }

    if (selfie['front'] == null) {
      Utils.showErrorMessage(context, loc.please_upload_selfie);
      return false;
    }

    return true;
  }

  Future<void> _submitOwnerDetails() async {
    final loc = AppLocalizations.of(context)!;

    if (!_validateForm()) return;

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final url = Uri.parse("https://admin.yoyomiles.com/api/driver_register");
      final request = http.MultipartRequest('POST', url);

      UserViewModel userViewModel = UserViewModel();
      int? userId = (await userViewModel.getUser());

      // Add form fields
      request.fields.addAll({
        "owner_name": _nameController.text.trim(),
        "phone": mobileNumber ??"",
        "owner_doc_status": '1',
        "vehicle_doc_status": '2',
        "driver_doc_status": '2',
        "id":userId.toString(),
      });

      // Compress and attach files
      final compressedAadhaarFront =
          await _compressImage(File(aadhaarCard['front']));
      final compressedAadhaarBack =
          await _compressImage(File(aadhaarCard['back']));
      final compressedPanFront = await _compressImage(File(panCard['front']));
      final compressedPanBack = await _compressImage(File(panCard['back']));
      final compressedSelfie = await _compressImage(File(selfie['front']));

      request.files.add(await http.MultipartFile.fromPath(
          "owner_aadhaar_front", compressedAadhaarFront.path));
      request.files.add(await http.MultipartFile.fromPath(
          "owner_aadhaar_back", compressedAadhaarBack.path));
      request.files.add(await http.MultipartFile.fromPath(
          "owner_pan_fornt", compressedPanFront.path));
      request.files.add(await http.MultipartFile.fromPath(
          "owner_pan_back", compressedPanBack.path));
      request.files.add(await http.MultipartFile.fromPath(
          "owner_selfie", compressedSelfie.path));

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final value = jsonDecode(response.body);
        if (value['success'] == true) {
          final String userId = value['user_id'].toString();

          // Save userId locally
          final userVm = UserViewModel();
          await userVm.saveUser(int.parse(userId));

          Utils.showSuccessMessage(context, loc.owner_detail_submitted );

          final profileVm = Provider.of<ProfileViewModel>(context, listen: false);

          // Refresh profile
          await profileVm.profileApi(context);
          final profile = profileVm.profileModel?.data;

          if (profile == null) {
            Utils.showErrorMessage(context, loc.profile_not_loaded);
            return;
          }

          if (profile.ownerDocStatus == 0 || profile.ownerDocStatus == 2) {
            Navigator.pushNamed(context, RoutesName.owner);
          } else if (profile.vehicleDocStatus == 0 || profile.vehicleDocStatus == 2) {
            Navigator.pushNamed(context, RoutesName.vehicleDetail);
          } else if (profile.driverDocStatus == 0 || profile.driverDocStatus == 2) {
            Navigator.pushNamed(context, RoutesName.addDriverDetail);
          } else if (profile.ownerDocStatus == 1 &&
              profile.vehicleDocStatus == 1 &&
              profile.driverDocStatus == 1) {
            Navigator.pushNamed(context, RoutesName.register);
          } else {
            Navigator.pushNamed(context, RoutesName.register);
          }

          _resetForm();
        } else {
          Utils.showErrorMessage(
              context, value["message"] ?? loc.submission_failed);
        }


      } else if (response.statusCode == 413) {
        Utils.showErrorMessage(
            context, loc.file_size_to_large);
      } else {
        Utils.showErrorMessage(context, "${loc.server_error} ${response.statusCode}");
      }
    } catch (e) {
      if (!mounted) return;
      Utils.showErrorMessage(context, "${loc.submission_failed} ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }

      // Clean up temporary files
      _cleanupTempFiles();
    }
  }

  void _resetForm() {
    _nameController.clear();
    setState(() {
      aadhaarCard = {'front': null, 'back': null, 'status': 'upload'};
      panCard = {'front': null, 'back': null, 'status': 'upload'};
      selfie = {'front': null, 'status': 'upload'};
    });
  }

  void _cleanupTempFiles() {
    // This would be called to clean up any temporary files
    // Implementation depends on your specific file management strategy
  }
}

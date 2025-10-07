class ProfileModel {
  Data? data;
  String? message;
  int? status;
  bool? success;

  ProfileModel({this.data, this.message, this.status, this.success});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
    status = json['status'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    data['status'] = this.status;
    data['success'] = this.success;
    return data;
  }
}

class Data {
  int? id;
  String? vehicleNo;
  String? rcFront;
  String? rcBack;
  int? cityId;
  String? vehicleType;
  String? vehicleBodyDetailsType;
  String? vehicleBodyType;
  int? fuelType;
  String? ownerName;
  String? ownerAadhaarBack;
  String? ownerAadhaarFront;
  String? ownerPanFornt;
  String? ownerPanBack;
  String? ownerSelfie;
  String? driverName;
  String? drivingLicenceBack;
  String? drivingLicenceFront;
  int? verifyDocument;
  int? phone;
  int? driveOperator;
  dynamic deviceId;
  dynamic docRejResion;
  dynamic email;
  int? onlineStatus;
  String? fcm;
  String? updatedAt;
  String? createdAt;
  int? status;
  int? ownerDocStatus;
  int? vehicleDocStatus;
  int? driverDocStatus;
  String? vehicleTypeName;
  String? vehicleTypeImage;
  String? vehicleBodyDetail;
  String? vehicleBodyTypeName;
  String? vehicleBodyTypeImage;
  String? fuelTypeName;
  String? cityName;

  Data(
      {this.id,
        this.vehicleNo,
        this.rcFront,
        this.rcBack,
        this.cityId,
        this.vehicleType,
        this.vehicleBodyDetailsType,
        this.vehicleBodyType,
        this.fuelType,
        this.ownerName,
        this.ownerAadhaarBack,
        this.ownerAadhaarFront,
        this.ownerPanFornt,
        this.ownerPanBack,
        this.ownerSelfie,
        this.driverName,
        this.drivingLicenceBack,
        this.drivingLicenceFront,
        this.verifyDocument,
        this.phone,
        this.driveOperator,
        this.deviceId,
        this.docRejResion,
        this.email,
        this.onlineStatus,
        this.fcm,
        this.updatedAt,
        this.createdAt,
        this.status,
        this.ownerDocStatus,
        this.vehicleDocStatus,
        this.driverDocStatus,
        this.vehicleTypeName,
        this.vehicleTypeImage,
        this.vehicleBodyDetail,
        this.vehicleBodyTypeName,
        this.vehicleBodyTypeImage,
        this.fuelTypeName,
        this.cityName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    vehicleNo = json['vehicle_no'];
    rcFront = json['rc_front'];
    rcBack = json['rc_back'];
    cityId = json['city_id'];
    vehicleType = json['vehicle_type'];
    vehicleBodyDetailsType = json['vehicle_body_details_type'];
    vehicleBodyType = json['vehicle_body_type'];
    fuelType = json['fuel_type'];
    ownerName = json['owner_name'];
    ownerAadhaarBack = json['owner_aadhaar_back'];
    ownerAadhaarFront = json['owner_aadhaar_front'];
    ownerPanFornt = json['owner_pan_fornt'];
    ownerPanBack = json['owner_pan_back'];
    ownerSelfie = json['owner_selfie'];
    driverName = json['driver_name'];
    drivingLicenceBack = json['driving_licence_back'];
    drivingLicenceFront = json['driving_licence_front'];
    verifyDocument = json['verify_document'];
    phone = json['phone'];
    driveOperator = json['drive_operator'];
    deviceId = json['device_id'];
    docRejResion = json['doc_rej_resion'];
    email = json['email'];
    onlineStatus = json['online_status'];
    fcm = json['fcm'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    status = json['status'];
    ownerDocStatus = json['owner_doc_status'];
    vehicleDocStatus = json['vehicle_doc_status'];
    driverDocStatus = json['driver_doc_status'];
    vehicleTypeName = json['vehicle_type_name'];
    vehicleTypeImage = json['vehicle_type_image'];
    vehicleBodyDetail = json['vehicle_body_detail'];
    vehicleBodyTypeName = json['vehicle_body_type_name'];
    vehicleBodyTypeImage = json['vehicle_body_type_image'];
    fuelTypeName = json['fuel_type_name'];
    cityName = json['city_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['vehicle_no'] = this.vehicleNo;
    data['rc_front'] = this.rcFront;
    data['rc_back'] = this.rcBack;
    data['city_id'] = this.cityId;
    data['vehicle_type'] = this.vehicleType;
    data['vehicle_body_details_type'] = this.vehicleBodyDetailsType;
    data['vehicle_body_type'] = this.vehicleBodyType;
    data['fuel_type'] = this.fuelType;
    data['owner_name'] = this.ownerName;
    data['owner_aadhaar_back'] = this.ownerAadhaarBack;
    data['owner_aadhaar_front'] = this.ownerAadhaarFront;
    data['owner_pan_fornt'] = this.ownerPanFornt;
    data['owner_pan_back'] = this.ownerPanBack;
    data['owner_selfie'] = this.ownerSelfie;
    data['driver_name'] = this.driverName;
    data['driving_licence_back'] = this.drivingLicenceBack;
    data['driving_licence_front'] = this.drivingLicenceFront;
    data['verify_document'] = this.verifyDocument;
    data['phone'] = this.phone;
    data['drive_operator'] = this.driveOperator;
    data['device_id'] = this.deviceId;
    data['doc_rej_resion'] = this.docRejResion;
    data['email'] = this.email;
    data['online_status'] = this.onlineStatus;
    data['fcm'] = this.fcm;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['status'] = this.status;
    data['owner_doc_status'] = this.ownerDocStatus;
    data['vehicle_doc_status'] = this.vehicleDocStatus;
    data['driver_doc_status'] = this.driverDocStatus;
    data['vehicle_type_name'] = this.vehicleTypeName;
    data['vehicle_type_image'] = this.vehicleTypeImage;
    data['vehicle_body_detail'] = this.vehicleBodyDetail;
    data['vehicle_body_type_name'] = this.vehicleBodyTypeName;
    data['vehicle_body_type_image'] = this.vehicleBodyTypeImage;
    data['fuel_type_name'] = this.fuelTypeName;
    data['city_name'] = this.cityName;
    return data;
  }
}

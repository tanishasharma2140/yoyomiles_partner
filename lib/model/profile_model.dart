class ProfileModel {
  Data? data;
  int? duesStatus;
  dynamic duesMessage;
  String? message;
  int? status;
  bool? success;

  ProfileModel(
      {this.data,
        this.duesStatus,
        this.duesMessage,
        this.message,
        this.status,
        this.success});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    duesStatus = json['dues_status'];
    duesMessage = json['dues_message'];
    message = json['message'];
    status = json['status'];
    success = json['success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['dues_status'] = duesStatus;
    data['dues_message'] = duesMessage;
    data['message'] = message;
    data['status'] = status;
    data['success'] = success;
    return data;
  }
}

class Data {
  dynamic id;
  dynamic wallet;
  dynamic duesPayment;
  dynamic vehicleNo;
  dynamic rcFront;
  dynamic rcBack;
  dynamic cityId;
  dynamic vehicleType;
  dynamic vehicleBodyDetailsType;
  dynamic vehicleBodyType;
  dynamic fuelType;
  dynamic ownerName;
  dynamic ownerAadhaarBack;
  dynamic ownerAadhaarFront;
  dynamic ownerPanFornt;
  dynamic ownerPanBack;
  dynamic ownerSelfie;
  dynamic driverName;
  dynamic drivingLicenceBack;
  dynamic drivingLicenceFront;
  dynamic phone;
  dynamic driveOperator;
  dynamic deviceId;
  dynamic docRejResion;
  dynamic email;
  dynamic fcm;
  dynamic updatedAt;
  dynamic createdAt;
  dynamic status;
  dynamic verifyDocument;
  dynamic onlineStatus;
  dynamic ownerDocStatus;
  dynamic vehicleDocStatus;
  dynamic driverDocStatus;
  dynamic currentLatitude;
  dynamic currentLongitude;
  dynamic vehicleTypeName;
  dynamic vehicleTypeImage;
  dynamic vehicleBodyDetail;
  dynamic vehicleBodyTypeName;
  dynamic vehicleBodyTypeImage;
  dynamic fuelTypeName;
  dynamic cityName;

  Data(
      {this.id,
        this.wallet,
        this.duesPayment,
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
        this.phone,
        this.driveOperator,
        this.deviceId,
        this.docRejResion,
        this.email,
        this.fcm,
        this.updatedAt,
        this.createdAt,
        this.status,
        this.verifyDocument,
        this.onlineStatus,
        this.ownerDocStatus,
        this.vehicleDocStatus,
        this.driverDocStatus,
        this.currentLatitude,
        this.currentLongitude,
        this.vehicleTypeName,
        this.vehicleTypeImage,
        this.vehicleBodyDetail,
        this.vehicleBodyTypeName,
        this.vehicleBodyTypeImage,
        this.fuelTypeName,
        this.cityName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    wallet = json['wallet'];
    duesPayment = json['dues_payment'];
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
    phone = json['phone'];
    driveOperator = json['drive_operator'];
    deviceId = json['device_id'];
    docRejResion = json['doc_rej_resion'];
    email = json['email'];
    fcm = json['fcm'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    status = json['status'];
    verifyDocument = json['verify_document'];
    onlineStatus = json['online_status'];
    ownerDocStatus = json['owner_doc_status'];
    vehicleDocStatus = json['vehicle_doc_status'];
    driverDocStatus = json['driver_doc_status'];
    currentLatitude = json['current_latitude'];
    currentLongitude = json['current_longitude'];
    vehicleTypeName = json['vehicle_type_name'];
    vehicleTypeImage = json['vehicle_type_image'];
    vehicleBodyDetail = json['vehicle_body_detail'];
    vehicleBodyTypeName = json['vehicle_body_type_name'];
    vehicleBodyTypeImage = json['vehicle_body_type_image'];
    fuelTypeName = json['fuel_type_name'];
    cityName = json['city_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['wallet'] = wallet;
    data['dues_payment'] = duesPayment;
    data['vehicle_no'] = vehicleNo;
    data['rc_front'] = rcFront;
    data['rc_back'] = rcBack;
    data['city_id'] = cityId;
    data['vehicle_type'] = vehicleType;
    data['vehicle_body_details_type'] = vehicleBodyDetailsType;
    data['vehicle_body_type'] = vehicleBodyType;
    data['fuel_type'] = fuelType;
    data['owner_name'] = ownerName;
    data['owner_aadhaar_back'] = ownerAadhaarBack;
    data['owner_aadhaar_front'] = ownerAadhaarFront;
    data['owner_pan_fornt'] = ownerPanFornt;
    data['owner_pan_back'] = ownerPanBack;
    data['owner_selfie'] = ownerSelfie;
    data['driver_name'] = driverName;
    data['driving_licence_back'] = drivingLicenceBack;
    data['driving_licence_front'] = drivingLicenceFront;
    data['phone'] = phone;
    data['drive_operator'] = driveOperator;
    data['device_id'] = deviceId;
    data['doc_rej_resion'] = docRejResion;
    data['email'] = email;
    data['fcm'] = fcm;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['status'] = status;
    data['verify_document'] = verifyDocument;
    data['online_status'] = onlineStatus;
    data['owner_doc_status'] = ownerDocStatus;
    data['vehicle_doc_status'] = vehicleDocStatus;
    data['driver_doc_status'] = driverDocStatus;
    data['current_latitude'] = currentLatitude;
    data['current_longitude'] = currentLongitude;
    data['vehicle_type_name'] = vehicleTypeName;
    data['vehicle_type_image'] = vehicleTypeImage;
    data['vehicle_body_detail'] = vehicleBodyDetail;
    data['vehicle_body_type_name'] = vehicleBodyTypeName;
    data['vehicle_body_type_image'] = vehicleBodyTypeImage;
    data['fuel_type_name'] = fuelTypeName;
    data['city_name'] = cityName;
    return data;
  }
}

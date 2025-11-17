class RideHistoryModel {
  List<Data>? data;
  bool? success;
  String? message;
  RideHistoryModel({this.data, this.success, this.message});
  RideHistoryModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}

class Data {
  dynamic id;
  dynamic name;
  dynamic email;
  dynamic phone;
  dynamic vehicleNo;
  dynamic vehicleName;
  dynamic vehicleType;
  dynamic brand;
  dynamic year;
  dynamic ownerAadhaarCard;
  dynamic ownerPanCard;
  dynamic ownerSelfie;
  dynamic drivingLicence;
  dynamic onlineStatus;
  dynamic verifyDocument;
  dynamic datetime;
  dynamic userid;
  dynamic pickupAddress;
  dynamic pickupLatitute;
  dynamic pickLongitude;
  dynamic dropAddress;
  dynamic dropLatitute;
  dynamic dropLogitute;
  dynamic senderName;
  dynamic senderPhone;
  dynamic reciverName;
  dynamic reciverPhone;
  dynamic rideStatus;
  dynamic orderType;
  dynamic driverId;
  dynamic amount;
  dynamic distance;
  dynamic createdAt;
  dynamic updatedAt;

  Data(
      {this.id,
        this.name,
        this.email,
        this.phone,
        this.vehicleNo,
        this.vehicleName,
        this.vehicleType,
        this.brand,
        this.year,
        this.ownerAadhaarCard,
        this.ownerPanCard,
        this.ownerSelfie,
        this.drivingLicence,
        this.onlineStatus,
        this.verifyDocument,
        this.datetime,
        this.userid,
        this.pickupAddress,
        this.pickupLatitute,
        this.pickLongitude,
        this.dropAddress,
        this.dropLatitute,
        this.dropLogitute,
        this.senderName,
        this.senderPhone,
        this.reciverName,
        this.reciverPhone,
        this.rideStatus,
        this.orderType,
        this.driverId,
        this.amount,
        this.distance,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    vehicleNo = json['vehicle_no'];
    vehicleName = json['vehicle_name'];
    vehicleType = json['vehicle_type'];
    brand = json['brand'];
    year = json['year'];
    ownerAadhaarCard = json['owner_aadhaar_card'];
    ownerPanCard = json['owner_pan_card'];
    ownerSelfie = json['owner_selfie'];
    drivingLicence = json['driving_licence'];
    onlineStatus = json['online_status'];
    verifyDocument = json['verify_document'];
    datetime = json['datetime'];
    userid = json['userid'];
    pickupAddress = json['pickup_address'];
    pickupLatitute = json['pickup_latitute'];
    pickLongitude = json['pick_longitude'];
    dropAddress = json['drop_address'];
    dropLatitute = json['drop_latitute'];
    dropLogitute = json['drop_logitute'];
    senderName = json['sender_name'];
    senderPhone = json['sender_phone'];
    reciverName = json['reciver_name'];
    reciverPhone = json['reciver_phone'];
    rideStatus = json['ride_status'];
    orderType = json['order_type'];
    driverId = json['driver_id'];
    amount = json['amount'];
    distance = json['distance'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['vehicle_no'] = vehicleNo;
    data['vehicle_name'] = vehicleName;
    data['vehicle_type'] = vehicleType;
    data['brand'] = brand;
    data['year'] = year;
    data['owner_aadhaar_card'] = ownerAadhaarCard;
    data['owner_pan_card'] = ownerPanCard;
    data['owner_selfie'] = ownerSelfie;
    data['driving_licence'] = drivingLicence;
    data['online_status'] = onlineStatus;
    data['verify_document'] = verifyDocument;
    data['datetime'] = datetime;
    data['userid'] = userid;
    data['pickup_address'] = pickupAddress;
    data['pickup_latitute'] = pickupLatitute;
    data['pick_longitude'] = pickLongitude;
    data['drop_address'] = dropAddress;
    data['drop_latitute'] = dropLatitute;
    data['drop_logitute'] = dropLogitute;
    data['sender_name'] = senderName;
    data['sender_phone'] = senderPhone;
    data['reciver_name'] = reciverName;
    data['reciver_phone'] = reciverPhone;
    data['ride_status'] = rideStatus;
    data['driver_id'] = driverId;
    data['order_type'] = orderType;
    data['amount'] = amount;
    data['distance'] = distance;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

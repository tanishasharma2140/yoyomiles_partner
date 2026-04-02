class LiveOrderModel {
  bool? success;
  Data? data;
  String? message;

  LiveOrderModel({this.success, this.data, this.message});

  LiveOrderModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  dynamic id;
  dynamic userid;
  dynamic rideStatus;
  dynamic amount;
  dynamic paymode;
  List<Stops>? stops;
  dynamic vehicleType;
  dynamic vehicleBodyDetailsType;
  dynamic vehicleBodyType;
  dynamic availableDriverId;
  dynamic driverId;
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
  dynamic paymentStatus;
  dynamic distance;
  dynamic pickupSaveAs;
  dynamic dropSaveAs;
  dynamic orderType;
  dynamic otp;
  dynamic goodsType;
  dynamic txnId;
  dynamic orderTime;
  dynamic datetime;
  dynamic updatedAt;
  dynamic createdAt;
  dynamic couponId;
  dynamic ignoredDriverId;
  dynamic cancelByAdmin;
  dynamic extraCharges;
  dynamic walletApplied;
  dynamic amountWalletApplied;
  dynamic vehicleName;

  Data(
      {this.id,
        this.userid,
        this.rideStatus,
        this.amount,
        this.paymode,
        this.stops,
        this.vehicleType,
        this.vehicleBodyDetailsType,
        this.vehicleBodyType,
        this.availableDriverId,
        this.driverId,
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
        this.paymentStatus,
        this.distance,
        this.pickupSaveAs,
        this.dropSaveAs,
        this.orderType,
        this.otp,
        this.goodsType,
        this.txnId,
        this.orderTime,
        this.datetime,
        this.updatedAt,
        this.createdAt,
        this.couponId,
        this.ignoredDriverId,
        this.cancelByAdmin,
        this.extraCharges,
        this.walletApplied,
        this.amountWalletApplied,
        this.vehicleName});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userid = json['userid'];
    rideStatus = json['ride_status'];
    amount = json['amount'];
    paymode = json['paymode'];
    if (json['stops'] != null) {
      stops = <Stops>[];
      json['stops'].forEach((v) {
        stops!.add(Stops.fromJson(v));
      });
    }
    vehicleType = json['vehicle_type'];
    vehicleBodyDetailsType = json['vehicle_body_details_type'];
    vehicleBodyType = json['vehicle_body_type'];
    availableDriverId = json['available_driver_id'];
    driverId = json['driver_id'];
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
    paymentStatus = json['payment_status'];
    distance = json['distance'];
    pickupSaveAs = json['pickup_save_as'];
    dropSaveAs = json['drop_save_as'];
    orderType = json['order_type'];
    otp = json['otp'];
    goodsType = json['goods_type'];
    txnId = json['txn_id'];
    orderTime = json['order_time'];
    datetime = json['datetime'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    couponId = json['coupon_id'];
    ignoredDriverId = json['ignored_driver_id'];
    cancelByAdmin = json['cancel_by_admin'];
    extraCharges = json['extra_charges'];
    walletApplied = json['wallet_applied'];
    amountWalletApplied = json['amount_wallet_applied'];
    vehicleName = json['vehicle_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userid'] = userid;
    data['ride_status'] = rideStatus;
    data['amount'] = amount;
    data['paymode'] = paymode;
    if (stops != null) {
      data['stops'] = stops!.map((v) => v.toJson()).toList();
    }
    data['vehicle_type'] = vehicleType;
    data['vehicle_body_details_type'] = vehicleBodyDetailsType;
    data['vehicle_body_type'] = vehicleBodyType;
    data['available_driver_id'] = availableDriverId;
    data['driver_id'] = driverId;
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
    data['payment_status'] = paymentStatus;
    data['distance'] = distance;
    data['pickup_save_as'] = pickupSaveAs;
    data['drop_save_as'] = dropSaveAs;
    data['order_type'] = orderType;
    data['otp'] = otp;
    data['goods_type'] = goodsType;
    data['txn_id'] = txnId;
    data['order_time'] = orderTime;
    data['datetime'] = datetime;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['coupon_id'] = couponId;
    data['ignored_driver_id'] = ignoredDriverId;
    data['cancel_by_admin'] = cancelByAdmin;
    data['extra_charges'] = extraCharges;
    data['wallet_applied'] = walletApplied;
    data['amount_wallet_applied'] = amountWalletApplied;
    data['vehicle_name'] = vehicleName;
    return data;
  }
}

class Stops {
  String? name;
  String? phone;
  double? lat;
  double? lng;
  String? address;
  int? status;

  Stops({this.name, this.phone, this.lat, this.lng, this.address, this.status});

  Stops.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    phone = json['phone'];
    lat = json['lat'];
    lng = json['lng'];
    address = json['address'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['phone'] = phone;
    data['lat'] = lat;
    data['lng'] = lng;
    data['address'] = address;
    data['status'] = status;
    return data;
  }
}

class RideHistoryModel {
  bool? success;
  List<Data>? data;
  String? message;

  RideHistoryModel({this.success, this.data, this.message});

  RideHistoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  int? id;
  int? userid;
  String? vehicleType;
  int? vehicleBodyDetailsType;
  int? vehicleBodyType;
  String? availableDriverId;
  int? driverId;
  String? pickupAddress;
  String? pickupLatitute;
  String? pickLongitude;
  String? dropAddress;
  String? dropLatitute;
  String? dropLogitute;
  String? senderName;
  int? senderPhone;
  String? reciverName;
  int? reciverPhone;
  int? rideStatus;
  int? amount;
  int? paymode;
  int? paymentStatus;
  int? distance;
  dynamic pickupSaveAs;
  String? dropSaveAs;
  int? orderType;
  int? otp;
  String? goodsType;
  dynamic txnId;
  dynamic orderTime;
  String? datetime;
  String? updatedAt;
  String? createdAt;
  dynamic couponId;
  int? ratingId;
  int? ratingUserId;
  String? ratingUserName;
  int? userRating;
  String? ratingCreatedAt;
  int? ratingDriverId;
  String? ratingOrderId;

  Data(
      {this.id,
        this.userid,
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
        this.rideStatus,
        this.amount,
        this.paymode,
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
        this.ratingId,
        this.ratingUserId,
        this.ratingUserName,
        this.userRating,
        this.ratingCreatedAt,
        this.ratingDriverId,
        this.ratingOrderId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userid = json['userid'];
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
    rideStatus = json['ride_status'];
    amount = json['amount'];
    paymode = json['paymode'];
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
    ratingId = json['rating_id'];
    ratingUserId = json['rating_user_id'];
    ratingUserName = json['rating_user_name'];
    userRating = json['user_rating'];
    ratingCreatedAt = json['rating_created_at'];
    ratingDriverId = json['rating_driver_id'];
    ratingOrderId = json['rating_order_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['userid'] = userid;
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
    data['ride_status'] = rideStatus;
    data['amount'] = amount;
    data['paymode'] = paymode;
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
    data['rating_id'] = ratingId;
    data['rating_user_id'] = ratingUserId;
    data['rating_user_name'] = ratingUserName;
    data['user_rating'] = userRating;
    data['rating_created_at'] = ratingCreatedAt;
    data['rating_driver_id'] = ratingDriverId;
    data['rating_order_id'] = ratingOrderId;
    return data;
  }
}

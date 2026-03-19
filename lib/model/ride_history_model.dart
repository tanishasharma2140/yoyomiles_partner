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
        data!.add(new Data.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  dynamic id;
  dynamic userid;
  dynamic rideStatus;
  dynamic amount;
  dynamic paymode;
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
  dynamic ratingId;
  dynamic ratingUserId;
  dynamic ratingUserName;
  dynamic userRating;
  dynamic ratingCreatedAt;
  dynamic ratingDriverId;
  dynamic ratingOrderId;

  Data(
      {this.id,
        this.userid,
        this.rideStatus,
        this.amount,
        this.paymode,
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
    rideStatus = json['ride_status'];
    amount = json['amount'];
    paymode = json['paymode'];
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
    ratingId = json['rating_id'];
    ratingUserId = json['rating_user_id'];
    ratingUserName = json['rating_user_name'];
    userRating = json['user_rating'];
    ratingCreatedAt = json['rating_created_at'];
    ratingDriverId = json['rating_driver_id'];
    ratingOrderId = json['rating_order_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userid'] = this.userid;
    data['ride_status'] = this.rideStatus;
    data['amount'] = this.amount;
    data['paymode'] = this.paymode;
    data['vehicle_type'] = this.vehicleType;
    data['vehicle_body_details_type'] = this.vehicleBodyDetailsType;
    data['vehicle_body_type'] = this.vehicleBodyType;
    data['available_driver_id'] = this.availableDriverId;
    data['driver_id'] = this.driverId;
    data['pickup_address'] = this.pickupAddress;
    data['pickup_latitute'] = this.pickupLatitute;
    data['pick_longitude'] = this.pickLongitude;
    data['drop_address'] = this.dropAddress;
    data['drop_latitute'] = this.dropLatitute;
    data['drop_logitute'] = this.dropLogitute;
    data['sender_name'] = this.senderName;
    data['sender_phone'] = this.senderPhone;
    data['reciver_name'] = this.reciverName;
    data['reciver_phone'] = this.reciverPhone;
    data['payment_status'] = this.paymentStatus;
    data['distance'] = this.distance;
    data['pickup_save_as'] = this.pickupSaveAs;
    data['drop_save_as'] = this.dropSaveAs;
    data['order_type'] = this.orderType;
    data['otp'] = this.otp;
    data['goods_type'] = this.goodsType;
    data['txn_id'] = this.txnId;
    data['order_time'] = this.orderTime;
    data['datetime'] = this.datetime;
    data['updated_at'] = this.updatedAt;
    data['created_at'] = this.createdAt;
    data['coupon_id'] = this.couponId;
    data['ignored_driver_id'] = this.ignoredDriverId;
    data['cancel_by_admin'] = this.cancelByAdmin;
    data['extra_charges'] = this.extraCharges;
    data['wallet_applied'] = this.walletApplied;
    data['amount_wallet_applied'] = this.amountWalletApplied;
    data['rating_id'] = this.ratingId;
    data['rating_user_id'] = this.ratingUserId;
    data['rating_user_name'] = this.ratingUserName;
    data['user_rating'] = this.userRating;
    data['rating_created_at'] = this.ratingCreatedAt;
    data['rating_driver_id'] = this.ratingDriverId;
    data['rating_order_id'] = this.ratingOrderId;
    return data;
  }
}

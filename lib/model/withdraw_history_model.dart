class WithdrawHistoryModel {
  bool? success;
  String? message;
  List<Data>? data;

  WithdrawHistoryModel({this.success, this.message, this.data});

  WithdrawHistoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  String? orderId;
  int? status;
  String? amount;
  String? createdAt;

  Data(
      {this.id,
        this.userId,
        this.orderId,
        this.status,
        this.amount,
        this.createdAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    status = json['status'];
    amount = json['amount'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['order_id'] = orderId;
    data['status'] = status;
    data['amount'] = amount;
    data['created_at'] = createdAt;
    return data;
  }
}

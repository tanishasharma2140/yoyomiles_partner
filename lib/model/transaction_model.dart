class TransactionsModel {
  bool? status;
  String? message;
  int? total;
  List<Data>? data;

  TransactionsModel({this.status, this.message, this.total, this.data});

  TransactionsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    total = json['total'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? totalAmount;
  String? platformFee;
  String? createdAt;
  int? paymetBy;
  int? paymentGatewayStatus;
  String? orderId;
  String? amount;

  Data(
      {this.id,
        this.totalAmount,
        this.platformFee,
        this.createdAt,
        this.paymetBy,
        this.paymentGatewayStatus,
        this.orderId,
        this.amount});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalAmount = json['total_amount'];
    platformFee = json['platform_fee'];
    createdAt = json['created_at'];
    paymetBy = json['paymet_by'];
    paymentGatewayStatus = json['payment_gateway_status'];
    orderId = json['order_id'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['total_amount'] = totalAmount;
    data['platform_fee'] = platformFee;
    data['created_at'] = createdAt;
    data['paymet_by'] = paymetBy;
    data['payment_gateway_status'] = paymentGatewayStatus;
    data['order_id'] = orderId;
    data['amount'] = amount;
    return data;
  }
}

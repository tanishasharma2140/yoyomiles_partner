class BankDetailModel {
  BankDetails? bankDetails;
  bool? success;
  String? message;

  BankDetailModel({this.bankDetails, this.success, this.message});

  BankDetailModel.fromJson(Map<String, dynamic> json) {
    bankDetails = json['bank_details'] != null
        ? BankDetails.fromJson(json['bank_details'])
        : null;
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bankDetails != null) {
      data['bank_details'] = bankDetails!.toJson();
    }
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}

class BankDetails {
  int? id;
  int? driverId;
  String? accountNumber;
  String? accountHolderName;
  String? ifscCode;
  String? reAccountNumber;
  String? bankName;
  String? datetime;
  String? updatedAt;

  BankDetails(
      {this.id,
        this.driverId,
        this.accountNumber,
        this.accountHolderName,
        this.ifscCode,
        this.reAccountNumber,
        this.bankName,
        this.datetime,
        this.updatedAt});

  BankDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    driverId = json['driver_id'];
    accountNumber = json['account_number'];
    accountHolderName = json['account_holder_name'];
    ifscCode = json['ifsc_code'];
    reAccountNumber = json['re_account_number'];
    bankName = json['bank_name'];
    datetime = json['datetime'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['driver_id'] = driverId;
    data['account_number'] = accountNumber;
    data['account_holder_name'] = accountHolderName;
    data['ifsc_code'] = ifscCode;
    data['re_account_number'] = reAccountNumber;
    data['bank_name'] = bankName;
    data['datetime'] = datetime;
    data['updated_at'] = updatedAt;
    return data;
  }
}

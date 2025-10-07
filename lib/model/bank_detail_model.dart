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
  String? accountNumber;
  String? accountHolderName;
  String? ifscCode;
  String? reAccountNumber;
  String? datetime;

  BankDetails(
      {this.id,
        this.accountNumber,
        this.accountHolderName,
        this.ifscCode,
        this.reAccountNumber,
        this.datetime});

  BankDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    accountNumber = json['account_number'];
    accountHolderName = json['account_holder_name'];
    ifscCode = json['ifsc_code'];
    reAccountNumber = json['re_account_number'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['account_number'] = accountNumber;
    data['account_holder_name'] = accountHolderName;
    data['ifsc_code'] = ifscCode;
    data['re_account_number'] = reAccountNumber;
    data['datetime'] = datetime;
    return data;
  }
}

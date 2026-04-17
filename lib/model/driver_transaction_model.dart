class DriverTransactionModel {
  int? status;
  String? message;
  int? type;

  // Type 1
  List<ReferralData>? referralData;

  // Type 2
  List<TransactionHistory>? transactionHistory;
  String? totalTransferred;

  // Common
  String? totalReward;
  String? rewardWallet;

  DriverTransactionModel({
    this.status,
    this.message,
    this.type,
    this.referralData,
    this.transactionHistory,
    this.totalTransferred,
    this.totalReward,
    this.rewardWallet,
  });

  DriverTransactionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    type = json['type'];
    totalTransferred = json['total_transferred']?.toString();
    totalReward = json['total_reward']?.toString();
    rewardWallet = json['reward_wallet']?.toString();

    // Type 1 → "data" key
    if (json['data'] != null) {
      referralData = <ReferralData>[];
      json['data'].forEach((v) {
        referralData!.add(ReferralData.fromJson(v));
      });
    }

    // Type 2 → "transaction_history" key
    if (json['transaction_history'] != null) {
      transactionHistory = <TransactionHistory>[];
      json['transaction_history'].forEach((v) {
        transactionHistory!.add(TransactionHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    data['type'] = type;
    data['total_transferred'] = totalTransferred;
    data['total_reward'] = totalReward;
    data['reward_wallet'] = rewardWallet;
    if (referralData != null) {
      data['data'] = referralData!.map((v) => v.toJson()).toList();
    }
    if (transactionHistory != null) {
      data['transaction_history'] =
          transactionHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// ─── Type 1 ka model ───
class ReferralData {
  int? status;
  String? rewardAmount;
  int? referredDriverId;
  String? driverName;
  String? createdAt;

  ReferralData({
    this.status,
    this.rewardAmount,
    this.referredDriverId,
    this.driverName,
    this.createdAt,
  });

  ReferralData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    rewardAmount = json['reward_amount']?.toString();
    referredDriverId = json['referred_driver_id'];
    driverName = json['driver_name'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['reward_amount'] = rewardAmount;
    data['referred_driver_id'] = referredDriverId;
    data['driver_name'] = driverName;
    data['created_at'] = createdAt;
    return data;
  }
}

// ─── Type 2 ka model (same as before) ───
class TransactionHistory {
  String? rewardAmount;
  int? actionType;
  String? createdAt;

  TransactionHistory({
    this.rewardAmount,
    this.actionType,
    this.createdAt,
  });

  TransactionHistory.fromJson(Map<String, dynamic> json) {
    rewardAmount = json['reward_amount']?.toString();
    actionType = json['action_type'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['reward_amount'] = rewardAmount;
    data['action_type'] = actionType;
    data['created_at'] = createdAt;
    return data;
  }
}
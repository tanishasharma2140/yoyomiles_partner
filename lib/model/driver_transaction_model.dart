class DriverTransactionModel {
  int? status;
  String? message;
  int? type;
  List<TransactionHistory>? transactionHistory;
  String? totalTransferred;
  int? totalReward;
  int? rewardWallet;

  DriverTransactionModel({
    this.status,
    this.message,
    this.type,
    this.transactionHistory,
    this.totalTransferred,
    this.totalReward,
    this.rewardWallet,
  });

  DriverTransactionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    type = json['type'];

    if (json['transaction_history'] != null) {
      transactionHistory = <TransactionHistory>[];
      json['transaction_history'].forEach((v) {
        transactionHistory!.add(TransactionHistory.fromJson(v));
      });
    }

    totalTransferred = json['total_transferred'];
    totalReward = json['total_reward'];
    rewardWallet = json['reward_wallet'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    data['type'] = type;

    if (transactionHistory != null) {
      data['transaction_history'] =
          transactionHistory!.map((v) => v.toJson()).toList();
    }

    data['total_transferred'] = totalTransferred;
    data['total_reward'] = totalReward;
    data['reward_wallet'] = rewardWallet;

    return data;
  }
}

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
    rewardAmount = json['reward_amount'];
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
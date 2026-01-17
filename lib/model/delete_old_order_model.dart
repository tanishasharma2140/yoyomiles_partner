class DeleteOldOrderModel {
  int? status;
  String? orderTime;
  int? deletedCount;
  List<String>? deletedIds;

  DeleteOldOrderModel(
      {this.status, this.orderTime, this.deletedCount, this.deletedIds});

  DeleteOldOrderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    orderTime = json['order_time'];
    deletedCount = json['deleted_count'];
    deletedIds = json['deleted_ids'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['order_time'] = orderTime;
    data['deleted_count'] = deletedCount;
    data['deleted_ids'] = deletedIds;
    return data;
  }
}

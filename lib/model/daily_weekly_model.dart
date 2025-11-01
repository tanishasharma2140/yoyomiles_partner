class DailyWeeklyModel {
  String? message;
  int? status;
  String? totalTime;
  int? tripCompleted;
  String? offlinePlusOnline;
  List<TripDetails>? tripDetails;

  DailyWeeklyModel(
      {this.message,
        this.status,
        this.totalTime,
        this.tripCompleted,
        this.offlinePlusOnline,
        this.tripDetails});

  DailyWeeklyModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    totalTime = json['total_time'];
    tripCompleted = json['trip_completed'];
    offlinePlusOnline = json['offline_plus_online'];
    if (json['trip_details'] != null) {
      tripDetails = <TripDetails>[];
      json['trip_details'].forEach((v) {
        tripDetails!.add(TripDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    data['total_time'] = totalTime;
    data['trip_completed'] = tripCompleted;
    data['offline_plus_online'] = offlinePlusOnline;
    if (tripDetails != null) {
      data['trip_details'] = tripDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TripDetails {
  int? id;
  int? distance;
  int? amount;
  String? createdAt;

  TripDetails({this.id, this.distance, this.amount, this.createdAt});

  TripDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    distance = json['distance'];
    amount = json['amount'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['distance'] = distance;
    data['amount'] = amount;
    data['created_at'] = createdAt;
    return data;
  }
}

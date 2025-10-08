class HelpTopicsModel {
  int? status;
  String? message;
  List<Data>? data;

  HelpTopicsModel({this.status, this.message, this.data});

  HelpTopicsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
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
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? heading;
  String? text;

  Data({this.id, this.heading, this.text});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    heading = json['heading'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['heading'] = heading;
    data['text'] = text;
    return data;
  }
}

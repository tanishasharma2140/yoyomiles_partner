class VehicleTypeModel {
  List<Data>? data;
  bool? success;
  String? message;

  VehicleTypeModel({this.data, this.success, this.message});

  VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? image;
  int? time;
  int? price;
  int? maxWeight;
  String? vehicleType;
  String? datetime;

  Data(
      {this.id,
        this.name,
        this.image,
        this.time,
        this.price,
        this.maxWeight,
        this.vehicleType,
        this.datetime});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    time = json['time'];
    price = json['price'];
    maxWeight = json['max_weight'];
    vehicleType = json['vehicle_type'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['time'] = time;
    data['price'] = price;
    data['max_weight'] = maxWeight;
    data['vehicle_type'] = vehicleType;
    data['datetime'] = datetime;
    return data;
  }
}

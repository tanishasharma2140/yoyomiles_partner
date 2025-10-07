class VehicleNameModel {
  List<Data>? data;
  List<Brands>? brands;
  bool? success;
  String? message;

  VehicleNameModel({this.data, this.brands, this.success, this.message});

  VehicleNameModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    if (json['brands'] != null) {
      brands = <Brands>[];
      json['brands'].forEach((v) {
        brands!.add(Brands.fromJson(v));
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
    if (brands != null) {
      data['brands'] = brands!.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    data['message'] = message;
    return data;
  }
}

class Data {
  int? id;
  String? name;
  String? vehicleTypeId;
  String? datetime;

  Data({this.id, this.name, this.vehicleTypeId, this.datetime});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    vehicleTypeId = json['vehicle_typeId'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['vehicle_typeId'] = vehicleTypeId;
    data['datetime'] = datetime;
    return data;
  }
}

class Brands {
  int? id;
  String? name;
  int? vehicleTypeId;
  String? datetime;

  Brands({this.id, this.name, this.vehicleTypeId, this.datetime});

  Brands.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    vehicleTypeId = json['vehicle_typeId'];
    datetime = json['datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['vehicle_typeId'] = vehicleTypeId;
    data['datetime'] = datetime;
    return data;
  }
}

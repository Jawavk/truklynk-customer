// To parse this JSON data, do
//
//     final vehicleModel = vehicleModelFromJson(jsonString);

import 'dart:convert';

VehicleModel vehicleModelFromJson(String str) =>
    VehicleModel.fromJson(json.decode(str));

String vehicleModelToJson(VehicleModel data) => json.encode(data.toJson());

class VehicleModel {
  List<Vehicle>? vehicle;
  bool? isSuccess;
  String? error;

  VehicleModel({
    this.vehicle,
    this.isSuccess,
    this.error,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        vehicle: json["json"] == null
            ? []
            : List<Vehicle>.from(json["json"]!.map((x) => Vehicle.fromJson(x))),
        isSuccess: json["isSuccess"],
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "Vehicle": vehicle == null
            ? []
            : List<dynamic>.from(vehicle!.map((x) => x.toJson())),
        "isSuccess": isSuccess,
        "error": error,
      };
}

class Vehicle {
  int? subcategorySno;
  DateTime? updatedOn;
  String? subcategoryName;
  List<Media>? media;
  int? categorySno;
  int? status;
  String? description;

  Vehicle(
      {this.subcategorySno,
      this.updatedOn,
      this.subcategoryName,
      this.media,
      this.categorySno,
      this.status,
      this.description});

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
      subcategorySno: json["subcategory_sno"],
      updatedOn: json["updated_on"] == null
          ? null
          : DateTime.parse(json["updated_on"]),
      subcategoryName: json["subcategory_name"],
      media: json["media"] == null
          ? []
          : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
      categorySno: json["category_sno"],
      status: json["status"],
      description: json["description"]);

  Map<String, dynamic> toJson() => {
        "subcategory_sno": subcategorySno,
        "updated_on": updatedOn?.toIso8601String(),
        "subcategory_name": subcategoryName,
        "media": media == null
            ? []
            : List<dynamic>.from(media!.map((x) => x.toJson())),
        "category_sno": categorySno,
        "status": status,
        "description": description
      };
}

class Media {
  String? mediaUrl;
  String? contentType;
  String? fileType;
  String? fileName;
  String? mediaType;
  dynamic thumbnailUrl;
  bool? isUploaded;

  Media({
    this.mediaUrl,
    this.contentType,
    this.fileType,
    this.fileName,
    this.mediaType,
    this.thumbnailUrl,
    this.isUploaded,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        mediaUrl: json["mediaUrl"],
        contentType: json["contentType"],
        fileType: json["fileType"],
        fileName: json["fileName"],
        mediaType: json["mediaType"],
        thumbnailUrl: json["thumbnailUrl"],
        isUploaded: json["isUploaded"],
      );

  Map<String, dynamic> toJson() => {
        "mediaUrl": mediaUrl,
        "contentType": contentType,
        "fileType": fileType,
        "fileName": fileName,
        "mediaType": mediaType,
        "thumbnailUrl": thumbnailUrl,
        "isUploaded": isUploaded,
      };
}

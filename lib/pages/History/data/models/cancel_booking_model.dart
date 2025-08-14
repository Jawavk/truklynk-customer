// To parse this JSON data, do
//
//     final cancelBookingResultModel = cancelBookingResultModelFromJson(jsonString);

import 'dart:convert';

CancelBookingResultModel cancelBookingResultModelFromJson(String str) =>
    CancelBookingResultModel.fromJson(json.decode(str));

String cancelBookingResultModelToJson(CancelBookingResultModel data) =>
    json.encode(data.toJson());

class CancelBookingResultModel {
  List<CancelBookings>? json;
  bool isSuccess;

  CancelBookingResultModel({
    this.json,
    required this.isSuccess,
  });

  factory CancelBookingResultModel.fromJson(Map<String, dynamic> json) =>
      CancelBookingResultModel(
        json: json["json"] == null
            ? []
            : List<CancelBookings>.from(
                json["json"]!.map((x) => CancelBookings.fromJson(x))),
        isSuccess: json["isSuccess"],
      );

  Map<String, dynamic> toJson() => {
        "json": json == null
            ? []
            : List<dynamic>.from(json!.map((x) => x.toJson())),
        "isSuccess": isSuccess,
      };
}

class CancelBookings {
  List<String>? updateservicebooking;

  CancelBookings({
    this.updateservicebooking,
  });

  factory CancelBookings.fromJson(Map<String, dynamic> json) => CancelBookings(
        updateservicebooking: json["updateservicebooking"] == null
            ? []
            : List<String>.from(json["updateservicebooking"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "updateservicebooking": updateservicebooking == null
            ? []
            : List<dynamic>.from(updateservicebooking!.map((x) => x)),
      };
}

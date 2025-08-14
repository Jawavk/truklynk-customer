// To parse this JSON data, do
//
//     final conformBookingModel = conformBookingModelFromJson(jsonString);

import 'dart:convert';

ConformBookingModel conformBookingModelFromJson(String str) => ConformBookingModel.fromJson(json.decode(str));

String conformBookingModelToJson(ConformBookingModel data) => json.encode(data.toJson());

class ConformBookingModel {
    List<Json>? json;
    bool isSuccess;

    ConformBookingModel({
        this.json,
       required this.isSuccess,
    });

    factory ConformBookingModel.fromJson(Map<String, dynamic> json) => ConformBookingModel(
        json: json["json"] == null ? [] : List<Json>.from(json["json"]!.map((x) => Json.fromJson(x))),
        isSuccess: json["isSuccess"],
    );

    Map<String, dynamic> toJson() => {
        "json": json == null ? [] : List<dynamic>.from(json!.map((x) => x.toJson())),
        "isSuccess": isSuccess,
    };
}

class Json {
    List<dynamic>? updateserviceproviderquotationprice;

    Json({
        this.updateserviceproviderquotationprice,
    });

    factory Json.fromJson(Map<String, dynamic> json) => Json(
        updateserviceproviderquotationprice: json["updateserviceproviderquotationprice"] == null ? [] : List<dynamic>.from(json["updateserviceproviderquotationprice"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "updateserviceproviderquotationprice": updateserviceproviderquotationprice == null ? [] : List<dynamic>.from(updateserviceproviderquotationprice!.map((x) => x)),
    };
}

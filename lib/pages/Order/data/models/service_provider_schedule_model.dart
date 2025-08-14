// To parse this JSON data, do
//
//     final serviceProviderScheduleModel = serviceProviderScheduleModelFromJson(jsonString);

import 'dart:convert';

ServiceProviderScheduleModel serviceProviderScheduleModelFromJson(String str) => ServiceProviderScheduleModel.fromJson(json.decode(str));

String serviceProviderScheduleModelToJson(ServiceProviderScheduleModel data) => json.encode(data.toJson());

class ServiceProviderScheduleModel {
    List<Json>? json;
    bool isSuccess;

    ServiceProviderScheduleModel({
        this.json,
       required this.isSuccess,
    });

    factory ServiceProviderScheduleModel.fromJson(Map<String, dynamic> json) => ServiceProviderScheduleModel(
        json: json["json"] == null ? [] : List<Json>.from(json["json"]!.map((x) => Json.fromJson(x))),
        isSuccess: json["isSuccess"],
    );

    Map<String, dynamic> toJson() => {
        "json": json == null ? [] : List<dynamic>.from(json!.map((x) => x.toJson())),
        "isSuccess": isSuccess,
    };
}

class Json {
    List<Searchserviceproviderschedule>? searchserviceproviderschedule;

    Json({
        this.searchserviceproviderschedule,
    });

    factory Json.fromJson(Map<String, dynamic> json) => Json(
        searchserviceproviderschedule: json["searchserviceproviderschedule"] == null ? [] : List<Searchserviceproviderschedule>.from(json["searchserviceproviderschedule"]!.map((x) => Searchserviceproviderschedule.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "searchserviceproviderschedule": searchserviceproviderschedule == null ? [] : List<dynamic>.from(searchserviceproviderschedule!.map((x) => x.toJson())),
    };
}

class Searchserviceproviderschedule {
    int? serviceBookingId;
    bool? isNoResult;

    Searchserviceproviderschedule({
        this.serviceBookingId,
        this.isNoResult,
    });

    factory Searchserviceproviderschedule.fromJson(Map<String, dynamic> json) => Searchserviceproviderschedule(
        serviceBookingId: json["service_booking_id"],
        isNoResult: json["isNoResult"],
    );

    Map<String, dynamic> toJson() => {
        "service_booking_id": serviceBookingId,
        "isNoResult": isNoResult,
    };
}

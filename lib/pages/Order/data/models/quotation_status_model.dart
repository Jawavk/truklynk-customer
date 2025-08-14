import 'dart:convert';

// To parse this JSON data, do
//
//     final serviceProviderScheduleModel = serviceProviderScheduleModelFromJson(jsonString);

SearchQuotationServiceProviderScheduleModel serviceProviderScheduleModelFromJson(String str) =>
    SearchQuotationServiceProviderScheduleModel.fromJson(json.decode(str));

String serviceProviderScheduleModelToJson(SearchQuotationServiceProviderScheduleModel data) =>
    json.encode(data.toJson());

class SearchQuotationServiceProviderScheduleModel {
  List<ServiceProviderJson>? json;
  bool isSuccess;

  SearchQuotationServiceProviderScheduleModel({
    this.json,
    required this.isSuccess,
  });

  factory SearchQuotationServiceProviderScheduleModel.fromJson(Map<String, dynamic> data) =>
      SearchQuotationServiceProviderScheduleModel(
        json: data["json"] == null
            ? []
            : List<ServiceProviderJson>.from(data["json"].map((x) => ServiceProviderJson.fromJson(x))),
        isSuccess: data["isSuccess"] ?? false,
      );

  Map<String, dynamic> toJson() => {
    "json": json == null ? [] : List<dynamic>.from(json!.map((x) => x.toJson())),
    "isSuccess": isSuccess,
  };
}

class ServiceProviderJson {
  List<SearchQuotationServiceProviderSchedule>? searchQuotationServiceProviderSchedule;

  ServiceProviderJson({
    this.searchQuotationServiceProviderSchedule,
  });

  factory ServiceProviderJson.fromJson(Map<String, dynamic> data) => ServiceProviderJson(
    searchQuotationServiceProviderSchedule: data["searchquotationserviceproviderschedule"] == null
        ? []
        : List<SearchQuotationServiceProviderSchedule>.from(data["searchquotationserviceproviderschedule"]
        .map((x) => SearchQuotationServiceProviderSchedule.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "searchquotationserviceproviderschedule": searchQuotationServiceProviderSchedule == null
        ? []
        : List<dynamic>.from(searchQuotationServiceProviderSchedule!.map((x) => x.toJson())),
  };
}

class SearchQuotationServiceProviderSchedule {
  int? serviceBookingSno;
  int? bookingPersonSno;
  double? lat;
  double? lang;
  bool? isNoResult;
  String? message;

  SearchQuotationServiceProviderSchedule({
    this.serviceBookingSno,
    this.bookingPersonSno,
    this.lat,
    this.lang,
    this.isNoResult,
    this.message,
  });

  factory SearchQuotationServiceProviderSchedule.fromJson(Map<String, dynamic> data) =>
      SearchQuotationServiceProviderSchedule(
        serviceBookingSno: data["service_booking_sno"],
        bookingPersonSno: data["booking_person"],
        lat: data["lat"] != null ? data["lat"].toDouble() : null,
        lang: data["lang"] != null ? data["lang"].toDouble() : null,
        isNoResult: data["isNoResult"],
        message: data["message"],
      );

  Map<String, dynamic> toJson() => {
    "service_booking_sno": serviceBookingSno,
    "booking_person": bookingPersonSno,
    "lat": lat,
    "lang": lang,
    "isNoResult": isNoResult,
    "message": message,
  };
}

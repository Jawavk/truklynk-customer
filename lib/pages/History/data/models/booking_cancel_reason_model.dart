// To parse this JSON data, do
//
//     final cancelBookingModel = cancelBookingModelFromJson(jsonString);

import 'dart:convert';

CancelBookingModel cancelBookingModelFromJson(String str) => CancelBookingModel.fromJson(json.decode(str));

String cancelBookingModelToJson(CancelBookingModel data) => json.encode(data.toJson());

class CancelBookingModel {
    String? bookingStatusName;
    int? serviceBookingSno;
    int? userProfileSno;
    dynamic updatedBy;
    DateTime? updatedTime;
    bool? isSendNotification;
    int? cancelreasonSno;
    bool? isCustomer;
    String? cancelreason;

    CancelBookingModel({
        this.bookingStatusName,
        this.serviceBookingSno,
        this.userProfileSno,
        this.updatedBy,
        this.updatedTime,
        this.isSendNotification,
        this.cancelreasonSno,
        this.isCustomer,
        this.cancelreason,
    });

    factory CancelBookingModel.fromJson(Map<String, dynamic> json) => CancelBookingModel(
        bookingStatusName: json["booking_status_name"],
        serviceBookingSno: json["service_booking_sno"],
        userProfileSno: json["user_profile_sno"],
        updatedBy: json["updated_by"],
        updatedTime: json["updated_time"] == null ? null : DateTime.parse(json["updated_time"]),
        isSendNotification: json["isSendNotification"],
        cancelreasonSno: json["cancelreasonSno"],
        isCustomer: json["isCustomer"],
        cancelreason: json["cancelreason"],
    );

    Map<String, dynamic> toJson() => {
        "booking_status_name": bookingStatusName,
        "service_booking_sno": serviceBookingSno,
        "user_profile_sno": userProfileSno,
        "updated_by": updatedBy,
        "updated_time": updatedTime?.toIso8601String(),
        "isSendNotification": isSendNotification,
        "cancelreasonSno": cancelreasonSno,
        "isCustomer": isCustomer,
        "cancelreason": cancelreason,
    };
}

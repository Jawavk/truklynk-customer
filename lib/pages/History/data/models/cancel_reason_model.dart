import 'dart:convert';

CancelReasonModel cancelReasonModelFromJson(String str) => CancelReasonModel.fromJson(json.decode(str));

String cancelReasonModelToJson(CancelReasonModel data) => json.encode(data.toJson());

class CancelReasonModel {
    List<CancelReason>? json;
    bool isSuccess;

    CancelReasonModel({
        this.json,
       required this.isSuccess,
    });

    factory CancelReasonModel.fromJson(Map<String, dynamic> json) => CancelReasonModel(
        json: json["json"] == null ? [] : List<CancelReason>.from(json["json"]!.map((x) => CancelReason.fromJson(x))),
        isSuccess: json["isSuccess"],
    );

    Map<String, dynamic> toJson() => {
        "json": json == null ? [] : List<dynamic>.from(json!.map((x) => x.toJson())),
        "isSuccess": isSuccess,
    };
}

class CancelReason {
    String? reason;
    int? roleSno;
    String? role;
    int? cancelReasonSno;
    int? status;

    CancelReason({
        this.reason,
        this.roleSno,
        this.role,
        this.cancelReasonSno,
        this.status,
    });

    factory CancelReason.fromJson(Map<String, dynamic> json) => CancelReason(
        reason: json["reason"],
        roleSno: json["role_sno"],
        role: json["role"],
        cancelReasonSno: json["cancel_reason_sno"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "reason": reason,
        "role_sno": roleSno,
        "role": role,
        "cancel_reason_sno": cancelReasonSno,
        "status": status,
    };
}

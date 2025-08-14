// To parse this JSON data, do
//
//     final enumModel = enumModelFromJson(jsonString);

import 'dart:convert';

EnumModel enumModelFromJson(String str) => EnumModel.fromJson(json.decode(str));

String enumModelToJson(EnumModel data) => json.encode(data.toJson());

class EnumModel {
    List<Enum>? enumModelEnum;
    bool? isSuccess;
    String? error;

    EnumModel({
        this.enumModelEnum,
        this.isSuccess,
        this.error,
    });

    factory EnumModel.fromJson(Map<String, dynamic> json) => EnumModel(
        enumModelEnum: json["json"] == null ? [] : List<Enum>.from(json["json"]!.map((x) => Enum.fromJson(x))),
        isSuccess: json["isSuccess"],
        error: json["error"],
    );

    Map<String, dynamic> toJson() => {
        "enumModelEnum": enumModelEnum == null ? [] : List<dynamic>.from(enumModelEnum!.map((x) => x.toJson())),
        "isSuccess": isSuccess,
        "error": error,
    };
}

class Enum {
    int? seqno;
    int? codesDtlSno;
    dynamic filter2;
    dynamic filter1;
    int? codesHdrSno;
    String? cdValue;
    dynamic filter3;

    Enum({
        this.seqno,
        this.codesDtlSno,
        this.filter2,
        this.filter1,
        this.codesHdrSno,
        this.cdValue,
        this.filter3,
    });

    factory Enum.fromJson(Map<String, dynamic> json) => Enum(
        seqno: json["seqno"],
        codesDtlSno: json["codes_dtl_sno"],
        filter2: json["filter_2"],
        filter1: json["filter_1"],
        codesHdrSno: json["codes_hdr_sno"],
        cdValue: json["cd_value"],
        filter3: json["filter_3"],
    );

    Map<String, dynamic> toJson() => {
        "seqno": seqno,
        "codes_dtl_sno": codesDtlSno,
        "filter_2": filter2,
        "filter_1": filter1,
        "codes_hdr_sno": codesHdrSno,
        "cd_value": cdValue,
        "filter_3": filter3,
    };
}

// To parse this JSON data, do
//
//     final authModel = authModelFromJson(jsonString);

import 'dart:convert';

AuthModel authModelFromJson(String str) => AuthModel.fromJson(json.decode(str));

String authModelToJson(AuthModel data) => json.encode(data.toJson());

class AuthModel {
  List<Json>? json;
  bool? isSuccess;

  AuthModel({
    this.json,
    this.isSuccess,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
        json: json["json"] == null
            ? []
            : List<Json>.from(json["json"]!.map((x) => Json.fromJson(x))),
        isSuccess: json["isSuccess"],
      );

  Map<String, dynamic> toJson() => {
        "json": json == null
            ? []
            : List<dynamic>.from(json!.map((x) => x.toJson())),
        "isSuccess": isSuccess,
      };
}

class Json {
  Verifyuser? verifyuser;
  Createuser? createuser;
  Loginuser? loginuser;

  Json({this.verifyuser, this.createuser, this.loginuser});

  factory Json.fromJson(Map<String, dynamic> json) => Json(
        verifyuser: json["verifyuser"] == null
            ? null
            : Verifyuser.fromJson(json["verifyuser"]),
        createuser: json["createuser"] == null
            ? null
            : Createuser.fromJson(json["createuser"]),
        loginuser: json["loginuser"] == null
            ? null
            : Loginuser.fromJson(json["loginuser"]),
      );

  Map<String, dynamic> toJson() => {
        "verifyuser": verifyuser?.toJson(),
        "createuser": createuser?.toJson(),
        "loginuser": loginuser?.toJson(),
      };
}

class Createuser {
  String message;
  int code;
  String? mobileNumber;
  int? usersSno;
  int? userProfileSno;
  String? name;
  String? email;
  dynamic gender;
  int? signinconfigSno;
  dynamic serviceProviders;
  dynamic photo;

  Createuser({
    required this.message,
    required this.code,
    this.mobileNumber,
    this.usersSno,
    this.userProfileSno,
    this.name,
    this.email,
    this.gender,
    this.signinconfigSno,
    this.serviceProviders,
    this.photo,
  });

  factory Createuser.fromJson(Map<String, dynamic> json) => Createuser(
        message: json["message"],
        code: json["code"],
        mobileNumber: json["mobileNumber"],
        usersSno: json["users_sno"],
        userProfileSno: json["user_profile_sno"],
        name: json["name"],
        email: json["email"],
        gender: json["gender"],
        signinconfigSno: json["signinconfig_sno"],
        serviceProviders: json["service_providers"],
        photo: json["photo"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "mobileNumber": mobileNumber,
        "users_sno": usersSno,
        "user_profile_sno": userProfileSno,
        "name": name,
        "email": email,
        "gender": gender,
        "signinconfig_sno": signinconfigSno,
        "service_providers": serviceProviders,
        "photo": photo,
      };
}

class Loginuser {
  String message;
  int code;
  String? mobileNumber;
  int? usersSno;
  int? userProfileSno;
  String? name;
  dynamic email;
  dynamic gender;
  int? signinconfigSno;
  dynamic serviceProviders;
  dynamic photo;

  Loginuser({
    required this.message,
    required this.code,
    this.mobileNumber,
    this.usersSno,
    this.userProfileSno,
    this.name,
    this.email,
    this.gender,
    this.signinconfigSno,
    this.serviceProviders,
    this.photo,
  });

  factory Loginuser.fromJson(Map<String, dynamic> json) => Loginuser(
        message: json["message"],
        code: json["code"],
        mobileNumber: json["mobileNumber"],
        usersSno: json["users_sno"],
        userProfileSno: json["user_profile_sno"],
        name: json["name"],
        email: json["email"],
        gender: json["gender"],
        signinconfigSno: json["signinconfig_sno"],
        serviceProviders: json["service_providers"],
        photo: json["photo"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "mobileNumber": mobileNumber,
        "users_sno": usersSno,
        "user_profile_sno": userProfileSno,
        "name": name,
        "email": email,
        "gender": gender,
        "signinconfig_sno": signinconfigSno,
        "service_providers": serviceProviders,
        "photo": photo,
      };
}

class Verifyuser {
  String message;
  int code;
  int? otp;
  int? usersSno;

  Verifyuser({
    required this.message,
    required this.code,
    this.otp,
    this.usersSno,
  });

  factory Verifyuser.fromJson(Map<String, dynamic> json) => Verifyuser(
        message: json["message"],
        code: json["code"],
        otp: json["otp"],
        usersSno: json["usersSno"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "otp": otp,
        "usersSno": usersSno,
      };
}

// To parse this JSON data, do
//
//     final blockedServiceProvidersModel = blockedServiceProvidersModelFromJson(jsonString);

import 'dart:convert';

BlockedServiceProvidersModel blockedServiceProvidersModelFromJson(String str) => BlockedServiceProvidersModel.fromJson(json.decode(str));

String blockedServiceProvidersModelToJson(BlockedServiceProvidersModel data) => json.encode(data.toJson());

class BlockedServiceProvidersModel {
    List<BlockedServiceProviders>? json;
    bool isSuccess;

    BlockedServiceProvidersModel({
        this.json,
       required this.isSuccess,
    });

    factory BlockedServiceProvidersModel.fromJson(Map<String, dynamic> json) => BlockedServiceProvidersModel(
        json: json["json"] == null ? [] : List<BlockedServiceProviders>.from(json["json"]!.map((x) => BlockedServiceProviders.fromJson(x))),
        isSuccess: json["isSuccess"],
    );

    Map<String, dynamic> toJson() => {
        "json": json == null ? [] : List<dynamic>.from(json!.map((x) => x.toJson())),
        "isSuccess": isSuccess,
    };
}

class BlockedServiceProviders {
    List<Photo>? photo;
    int blockServiceProvidersSno;
    String? companyName;

    BlockedServiceProviders({
        this.photo,
       required this.blockServiceProvidersSno,
        this.companyName,
    });

    factory BlockedServiceProviders.fromJson(Map<String, dynamic> json) => BlockedServiceProviders(
        photo: json["photo"] == null ? [] : List<Photo>.from(json["photo"]!.map((x) => Photo.fromJson(x))),
        blockServiceProvidersSno: json["block_service_providers_sno"],
        companyName: json["company_name"],
    );

    Map<String, dynamic> toJson() => {
        "photo": photo == null ? [] : List<dynamic>.from(photo!.map((x) => x.toJson())),
        "block_service_providers_sno": blockServiceProvidersSno,
        "company_name": companyName,
    };
}

class Photo {
    String? mediaUrl;
    dynamic contentType;
    String? fileType;
    String? fileName;
    String? mediaType;
    dynamic thumbnailUrl;
    bool? isUploaded;

    Photo({
        this.mediaUrl,
        this.contentType,
        this.fileType,
        this.fileName,
        this.mediaType,
        this.thumbnailUrl,
        this.isUploaded,
    });

    factory Photo.fromJson(Map<String, dynamic> json) => Photo(
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

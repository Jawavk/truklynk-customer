// To parse this JSON data, do
//
//     final blockServiceProvidersModel = blockServiceProvidersModelFromJson(jsonString);

import 'dart:convert';

BlockServiceProvidersModel blockServiceProvidersModelFromJson(String str) => BlockServiceProvidersModel.fromJson(json.decode(str));

String blockServiceProvidersModelToJson(BlockServiceProvidersModel data) => json.encode(data.toJson());

class BlockServiceProvidersModel {
    List<Json>? json;
    bool isSuccess;

    BlockServiceProvidersModel({
        this.json,
       required this.isSuccess,
    });

    factory BlockServiceProvidersModel.fromJson(Map<String, dynamic> json) => BlockServiceProvidersModel(
        json: json["json"] == null ? [] : List<Json>.from(json["json"]!.map((x) => Json.fromJson(x))),
        isSuccess: json["isSuccess"],
    );

    Map<String, dynamic> toJson() => {
        "json": json == null ? [] : List<dynamic>.from(json!.map((x) => x.toJson())),
        "isSuccess": isSuccess,
    };
}

class Json {
    int? insertBlockServiceProviders;

    Json({
        this.insertBlockServiceProviders,
    });

    factory Json.fromJson(Map<String, dynamic> json) => Json(
        insertBlockServiceProviders: json["insert_block_service_providers"],
    );

    Map<String, dynamic> toJson() => {
        "insert_block_service_providers": insertBlockServiceProviders,
    };
}

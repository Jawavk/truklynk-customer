
import 'dart:convert';

RemoveServiceProvidersModel removeServiceProvidersModelFromJson(String str) => RemoveServiceProvidersModel.fromJson(json.decode(str));

String removeServiceProvidersModelToJson(RemoveServiceProvidersModel data) => json.encode(data.toJson());

class RemoveServiceProvidersModel {
    List<RemoveServiceProvider>? json;
    bool isSuccess;

    RemoveServiceProvidersModel({
        this.json,
       required this.isSuccess,
    });

    factory RemoveServiceProvidersModel.fromJson(Map<String, dynamic> json) => RemoveServiceProvidersModel(
        json: json["json"] == null ? [] : List<RemoveServiceProvider>.from(json["json"]!.map((x) => RemoveServiceProvider.fromJson(x))),
        isSuccess: json["isSuccess"],
    );

    Map<String, dynamic> toJson() => {
        "json": json == null ? [] : List<dynamic>.from(json!.map((x) => x.toJson())),
        "isSuccess": isSuccess,
    };
}

class RemoveServiceProvider {
    int? rBlockServiceProvidersSno;

    RemoveServiceProvider({
        this.rBlockServiceProvidersSno,
    });

    factory RemoveServiceProvider.fromJson(Map<String, dynamic> json) => RemoveServiceProvider(
        rBlockServiceProvidersSno: json["r_block_service_providers_sno"],
    );

    Map<String, dynamic> toJson() => {
        "r_block_service_providers_sno": rBlockServiceProvidersSno,
    };
}

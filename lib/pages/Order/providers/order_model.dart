import 'dart:convert';

PickUpData pickUpDataFromJson(String str) =>
    PickUpData.fromJson(json.decode(str));

String pickUpDataToJson(PickUpData data) => json.encode(data.toJson());

class PickUpData {
  DateTime pickupDate;
  double totalWeight;
  String weightType;
  String weightTypeSno;
  String items;
  int vehicleId;
  String notes;
  String name;
  String phoneNumber;

  PickUpData(
      {required this.pickupDate,
      required this.totalWeight,
      required this.weightType,
      required this.weightTypeSno,
      required this.items,
      required this.vehicleId,
      required this.notes,
      required this.name,
      required this.phoneNumber});


  factory PickUpData.fromJson(Map<String, dynamic> json) => PickUpData(
      pickupDate: json["pickupDate"],
      totalWeight: json["totalWeight"]?.toDouble(),
      weightType: json["weightType"],
      weightTypeSno: json["weightTypeSno"],
      items: json["items"],
      vehicleId: json["vehicleId"],
      notes: json["notes"],
      // contactInfo: json["contactInfo"]
      name: json["name"],
      phoneNumber: json["phoneNumber"],
    // contactInfo: json["contactInfo"] != null
    //     ? Map<String, String>.from(json["contactInfo"])
    //     : {},   // Parse contactInfo as a map
  );

  Map<String, dynamic> toJson() => {
        "pickupDate": pickupDate,
        "totalWeight": totalWeight,
        "weightType": weightType,
        "weightTypeSno": weightTypeSno,
        "items": items,
        "vehicleId": vehicleId,
        "notes": notes,
        "name": name,
        "phoneNumber": phoneNumber,
        // "contactInfo": contactInfo
  };
}

import 'dart:convert';

JourneyDetailsModel journeyDetailsModelFromJson(String str) =>
    JourneyDetailsModel.fromJson(json.decode(str));

String journeyDetailsModelToJson(JourneyDetailsModel data) =>
    json.encode(data.toJson());

class JourneyDetailsModel {
  List<JourneyDetails>? json;
  bool isSuccess;

  JourneyDetailsModel({
    this.json,
    required this.isSuccess,
  });

  factory JourneyDetailsModel.fromJson(Map<String, dynamic> json) =>
      JourneyDetailsModel(
        json: json["json"] == null
            ? []
            : List<JourneyDetails>.from(
            json["json"]!.map((x) => JourneyDetails.fromJson(x))),
        isSuccess: json["isSuccess"],
      );

  Map<String, dynamic> toJson() => {
    "json": json == null
        ? []
        : List<dynamic>.from(json!.map((x) => x.toJson())),
    "isSuccess": isSuccess,
  };
}

class JourneyDetails {
  String? driverName;
  List<JourneyDetail>? journeyDetails;
  String? plateNumber;
  double? totalWeight;
  String? weightType;
  dynamic cancelPermission;
  Location? pickupLocation; // New field
  Location? dropLocation; // New field

  JourneyDetails({
    this.driverName,
    this.journeyDetails,
    this.plateNumber,
    this.totalWeight,
    this.weightType,
    required this.cancelPermission,
    this.pickupLocation,
    this.dropLocation,
  });

  factory JourneyDetails.fromJson(Map<String, dynamic> json) => JourneyDetails(
    driverName: json["driver_name"],
    journeyDetails: json["journey_details"] == null
        ? []
        : List<JourneyDetail>.from(
        json["journey_details"]!.map((x) => JourneyDetail.fromJson(x))),
    plateNumber: json["plate_number"],
    totalWeight: json["total_weight"],
    weightType: json["weight_type"],
    cancelPermission: json["cancel_permission"],
    pickupLocation: json["pickup_location"] == null
        ? null
        : Location.fromJson(json["pickup_location"]), // New field
    dropLocation: json["drop_location"] == null
        ? null
        : Location.fromJson(json["drop_location"]), // New field
  );

  Map<String, dynamic> toJson() => {
    "driver_name": driverName,
    "journey_details": journeyDetails == null
        ? []
        : List<dynamic>.from(journeyDetails!.map((x) => x.toJson())),
    "plate_number": plateNumber,
    "total_weight": totalWeight,
    "weight_type": weightType,
    "cancel_permission": cancelPermission,
    "pickup_location": pickupLocation?.toJson(), // New field
    "drop_location": dropLocation?.toJson(), // New field
  };
}

class JourneyDetail {
  String? status;
  DateTime? createdOn;
  bool? finished;
  String? icon;
  int? activeIndex;

  JourneyDetail({
    this.status,
    this.createdOn,
    this.finished,
    this.icon,
    this.activeIndex,
  });

  factory JourneyDetail.fromJson(Map<String, dynamic> json) => JourneyDetail(
    status: json["status"],
    createdOn: json["createdOn"] == null
        ? null
        : DateTime.parse(json["createdOn"]),
    finished: json["finished"],
    icon: json["icon"],
    activeIndex: json["activeIndex"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "createdOn": createdOn?.toIso8601String(),
    "finished": finished,
    "icon": icon,
    "activeIndex": activeIndex,
  };
}

class Location {
  String? city;
  String? state;
  CustomLatLng? latlng; // Use CustomLatLng here
  String? address;
  String? country;
  String? landmark;
  String? contactInfo;

  Location({
    this.city,
    this.state,
    this.latlng,
    this.address,
    this.country,
    this.landmark,
    this.contactInfo,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    city: json["city"],
    state: json["state"],
    latlng: json["latlng"] == null ? null : CustomLatLng.fromJson(json["latlng"]), // Use CustomLatLng here
    address: json["address"],
    country: json["country"],
    landmark: json["landmark"],
    contactInfo: json["contact_info"],
  );

  Map<String, dynamic> toJson() => {
    "city": city,
    "state": state,
    "latlng": latlng?.toJson(),
    "address": address,
    "country": country,
    "landmark": landmark,
    "contact_info": contactInfo,
  };
}

class CustomLatLng {
  double? latitude;
  double? longitude;

  CustomLatLng({
    this.latitude,
    this.longitude,
  });

  factory CustomLatLng.fromJson(Map<String, dynamic> json) => CustomLatLng(
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}
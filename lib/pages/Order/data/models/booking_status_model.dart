import 'dart:convert';


import '../../../History/data/models/booking_model.dart';

BookingStatusModel bookingStatusModelFromJson(String str) =>
    BookingStatusModel.fromJson(json.decode(str));

String bookingStatusModelToJson(BookingStatusModel data) =>
    json.encode(data.toJson());

class BookingStatusModel {
  List<Json>? json;
  bool isSuccess;

  BookingStatusModel({
    this.json,
    required this.isSuccess,
  });

  factory BookingStatusModel.fromJson(Map<String, dynamic> json) =>
      BookingStatusModel(
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
  dynamic price;
  List<ServiceProviderList>? serviceProviderList;

  Json({
    this.price,
    this.serviceProviderList,
  });

  factory Json.fromJson(Map<String, dynamic> json) => Json(
    price: json["price"],
    serviceProviderList: json["service_provider_list"] == null
        ? []
        : List<ServiceProviderList>.from(json["service_provider_list"]!
        .map((x) => ServiceProviderList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "price": price,
    "service_provider_list": serviceProviderList == null
        ? []
        : List<dynamic>.from(serviceProviderList!.map((x) => x.toJson())),
  };
}

class ServiceProviderList {
  int? serviceProviderSno;
  dynamic vehicleSno;
  dynamic serviceProviderQuotationSno;
  dynamic priceBreakup;
  dynamic price;
  int? userProfileSno;
  String? serviceProviderName;
  dynamic driverSno;
  String? registeringType;
  Ratings? ratings;
  String? city;
  dynamic driverName;
  BookingDetails? bookingDetails;
  dynamic mobileNo;
  String? quotationStatus;
  dynamic quotationStatusCode;
  List<NearbyVehicle>? nearbyVehicles; // New field

  ServiceProviderList({
    this.serviceProviderSno,
    this.vehicleSno,
    this.serviceProviderQuotationSno,
    this.priceBreakup,
    this.price,
    this.userProfileSno,
    this.serviceProviderName,
    this.driverSno,
    this.registeringType,
    this.ratings,
    this.city,
    this.driverName,
    this.bookingDetails,
    this.mobileNo,
    this.quotationStatus,
    this.quotationStatusCode,
    this.nearbyVehicles, // New field
  });

  factory ServiceProviderList.fromJson(Map<String, dynamic> json) =>
      ServiceProviderList(
        serviceProviderSno: json["service_provider_sno"],
        vehicleSno: json["vehicle_sno"],
        serviceProviderQuotationSno: json["service_provider_quotation_sno"],
        priceBreakup: json["price_breakup"],
        price: json["price"],
        userProfileSno: json["user_profile_sno"],
        serviceProviderName: json["service_provider_name"],
        driverSno: json["driver_sno"],
        registeringType: json["registering_type"],
        ratings: json["ratings"] == null
            ? null
            : Ratings.fromJson(json["ratings"]),
        city: json["city"],
        driverName: json["driver_name"],
        bookingDetails: json["bookingDetails"] == null
            ? null
            : BookingDetails.fromJson(json["bookingDetails"]),
        mobileNo: json["mobileNo"],
        quotationStatus: json["quotation_status"],
        quotationStatusCode: json["quotation_status_code"],
        nearbyVehicles: json["nearby_vehicles"] == null
            ? []
            : List<NearbyVehicle>.from(json["nearby_vehicles"]!
            .map((x) => NearbyVehicle.fromJson(x))), // New field
      );

  Map<String, dynamic> toJson() => {
    "service_provider_sno": serviceProviderSno,
    "vehicle_sno": vehicleSno,
    "service_provider_quotation_sno": serviceProviderQuotationSno,
    "price_breakup": priceBreakup,
    "price": price,
    "user_profile_sno": userProfileSno,
    "service_provider_name": serviceProviderName,
    "driver_sno": driverSno,
    "registering_type": registeringType,
    "ratings": ratings?.toJson(),
    "city": city,
    "driver_name": driverName,
    "bookingDetails": bookingDetails?.toJson(),
    "mobileNo": mobileNo,
    "quotationStatus": quotationStatus,
    "quotationStatusCode": quotationStatusCode,
    "nearby_vehicles": nearbyVehicles == null
        ? []
        : List<dynamic>.from(nearbyVehicles!.map((x) => x.toJson())), // New field
  };
}

class BookingDetails {
  DateTime? bookingTime;
  PLocation? pickupLocation;
  PLocation? dropLocation;
  String? notes;
  String? vehicleName;
  int? service_booking_sno;

  BookingDetails({
    this.bookingTime,
    this.pickupLocation,
    this.dropLocation,
    this.notes,
    this.vehicleName,
    this.service_booking_sno,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) => BookingDetails(
    bookingTime: json["booking_time"] == null
        ? null
        : DateTime.parse(json["booking_time"]),
    pickupLocation: json["pickup_location"] == null
        ? null
        : PLocation.fromJson(json["pickup_location"]),
    dropLocation: json["drop_location"] == null
        ? null
        : PLocation.fromJson(json["drop_location"]),
    notes: json["notes"],
    vehicleName: json["vehicleName"],
    service_booking_sno: json["service_booking_sno"],
  );

  Map<String, dynamic> toJson() => {
    "booking_time": bookingTime?.toIso8601String(),
    "pickup_location": pickupLocation?.toJson(),
    "drop_location": dropLocation?.toJson(),
    "notes": notes,
    "vehicleName": vehicleName,
    "service_booking_sno": service_booking_sno,
  };
}

class Ratings {
  int? overallRating;
  int? totalOrders;

  Ratings({
    this.overallRating,
    this.totalOrders,
  });

  factory Ratings.fromJson(Map<String, dynamic> json) => Ratings(
    overallRating: json["overall_rating"],
    totalOrders: json["totalOrders"],
  );

  Map<String, dynamic> toJson() => {
    "overall_rating": overallRating,
    "totalOrders": totalOrders,
  };
}

class NearbyVehicle {
  int? vehicleSno;
  double? distanceKm;
  String? lat;
  String? lng;
  String? heading;
  String? vehicleName;
  String? vehicleNumber;

  NearbyVehicle({
    this.vehicleSno,
    this.distanceKm,
    this.lat,
    this.lng,
    this.heading,
    this.vehicleName,
    this.vehicleNumber,
  });

  factory NearbyVehicle.fromJson(Map<String, dynamic> json) => NearbyVehicle(
    vehicleSno: json["vehicle_sno"],
    distanceKm: json["distance_km"],
    lat: json["lat"],
    lng: json["lng"],
    heading: json["heading"],
    vehicleName: json["vehicle_name"],
    vehicleNumber: json["vehicle_number"],
  );

  Map<String, dynamic> toJson() => {
    "vehicleSno": vehicleSno,
    "distanceKm": distanceKm,
    "lat": lat,
    "lng": lng,
    "heading": heading,
    "vehicleName": vehicleName,
    "vehicleNumber": vehicleNumber,
  };
}
import 'dart:convert';

BookingModel bookingModelFromJson(String str) =>
    BookingModel.fromJson(json.decode(str));

String bookingModelToJson(BookingModel data) => json.encode(data.toJson());

class BookingModel {
  List<Booking>? json;
  bool? isSuccess;

  BookingModel({
    this.json,
    this.isSuccess,
  });

  factory BookingModel.fromJson(dynamic json) {
    List<Booking> bookings;
    bool isSuccess;

    // Handle both array and object responses
    if (json is List) {
      bookings = List<Booking>.from(json.map((x) => Booking.fromJson(x)));
      isSuccess = true; // Assume success if data is returned
    } else if (json is Map<String, dynamic>) {
      bookings = json["json"] == null
          ? []
          : List<Booking>.from(json["json"]!.map((x) => Booking.fromJson(x)));
      isSuccess = json["isSuccess"] ?? false;
    } else {
      bookings = [];
      isSuccess = false;
    }

    return BookingModel(
      json: bookings,
      isSuccess: isSuccess,
    );
  }

  Map<String, dynamic> toJson() => {
    "json": json == null
        ? []
        : List<dynamic>.from(json!.map((x) => x.toJson())),
    "isSuccess": isSuccess,
  };
}

class Booking {
  int? serviceBookingSno;
  String? categoryName;
  double? distance;
  dynamic cancelreasonsno;
  int? quotationCount;
  String? subcategoryName;
  dynamic vehicleCurrentPrice;
  String? name;
  String? number;
  List<Media>? media;
  PLocation? dropLocation;
  dynamic serviceProviderMobileNo;
  int? subCategorySno;
  int? pin;
  double? price;
  int? vehicleSno;
  List<dynamic>? ratings;
  dynamic firstName;
  dynamic cancelreason;
  PLocation? pickupLocation;
  int? bookingStatusCd;
  DateTime? bookingTime;
  dynamic lastName;
  String? bookingTypeName;
  List<QuotationDetail>? quotationDetails;
  int? bookingPerson;
  dynamic serviceProvidersSno;
  String? bookingStatusName;
  dynamic vehicleNumber;
  dynamic companyName;
  dynamic userProfileSno;
  int? bookingType;
  String? typesOfGoods;
  String? weightTypeName;
  dynamic weightOfGoods; // Changed to dynamic to handle int or String
  DateTime? createdOn;

  Booking({
    this.serviceBookingSno,
    this.categoryName,
    this.distance,
    this.cancelreasonsno,
    this.quotationCount,
    this.subcategoryName,
    this.vehicleCurrentPrice,
    this.name,
    this.number,
    this.media,
    this.dropLocation,
    this.serviceProviderMobileNo,
    this.subCategorySno,
    this.pin,
    this.price,
    this.vehicleSno,
    this.ratings,
    this.firstName,
    this.cancelreason,
    this.pickupLocation,
    this.bookingStatusCd,
    this.bookingTime,
    this.lastName,
    this.bookingTypeName,
    this.quotationDetails,
    this.bookingPerson,
    this.serviceProvidersSno,
    this.bookingStatusName,
    this.vehicleNumber,
    this.companyName,
    this.userProfileSno,
    this.bookingType,
    this.typesOfGoods,
    this.weightTypeName,
    this.weightOfGoods,
    this.createdOn,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Parse contact_info if present
    String? name;
    String? number;
    if (json["contact_info"] != null) {
      try {
        final contactInfo = jsonDecode(json["contact_info"] as String);
        name = contactInfo["name"] as String?;
        number = contactInfo["phone"] as String?;
      } catch (e) {
        print("Error parsing contact_info: $e");
      }
    }

    return Booking(
      serviceBookingSno: json["service_booking_sno"] as int?,
      categoryName: json["category_name"] as String?,
      distance: (json["distance"] as num?)?.toDouble(),
      cancelreasonsno: json["cancelreasonsno"],
      quotationCount: json["quotation_count"] as int?,
      subcategoryName: json["subcategory_name"] as String?,
      vehicleCurrentPrice: json["vehicle_current_price"],
      name: name,
      number: number,
      media: json["media"] == null
          ? []
          : List<Media>.from(json["media"]!.map((x) => Media.fromJson(x))),
      dropLocation: json["drop_location"] == null
          ? null
          : PLocation.fromJson(json["drop_location"]),
      serviceProviderMobileNo: json["service_provider_mobile_no"],
      subCategorySno: json["sub_category_sno"] as int?,
      pin: json["pin"] as int?,
      price: (json["price"] as num?)?.toDouble(),
      vehicleSno: json["vehicle_sno"] as int?,
      ratings: json["ratings"] == null
          ? []
          : List<dynamic>.from(json["ratings"]!.map((x) => x)),
      firstName: json["first_name"],
      cancelreason: json["cancelreason"],
      pickupLocation: json["pickup_location"] == null
          ? null
          : PLocation.fromJson(json["pickup_location"]),
      bookingStatusCd: json["booking_status_cd"] as int?,
      bookingTime: json["booking_time"] == null
          ? null
          : DateTime.parse(json["booking_time"] as String),
      lastName: json["last_name"],
      bookingTypeName: json["booking_type_name"] as String?,
      quotationDetails: json["quotation_details"] == null
          ? []
          : List<QuotationDetail>.from(
          json["quotation_details"]!.map((x) => QuotationDetail.fromJson(x))),
      bookingPerson: json["booking_person"] as int?,
      serviceProvidersSno: json["service_providers_sno"],
      bookingStatusName: json["booking_status_name"] as String?,
      vehicleNumber: json["vehicle_number"],
      companyName: json["company_name"],
      userProfileSno: json["user_profile_sno"],
      bookingType: json["booking_type"] as int?,
      typesOfGoods: json["types_of_goods"] as String?,
      weightTypeName: json["weight_type_name"] as String?,
      weightOfGoods: json["weight_of_goods"], // Handle int or String
      createdOn: json["created_on"] == null
          ? null
          : DateTime.parse(json["created_on"] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    "service_booking_sno": serviceBookingSno,
    "category_name": categoryName,
    "distance": distance,
    "cancelreasonsno": cancelreasonsno,
    "quotation_count": quotationCount,
    "subcategory_name": subcategoryName,
    "vehicle_current_price": vehicleCurrentPrice,
    "contact_info":
    name != null && number != null ? jsonEncode({"name": name, "phone": number}) : null,
    "media": media == null
        ? []
        : List<dynamic>.from(media!.map((x) => x.toJson())),
    "drop_location": dropLocation?.toJson(),
    "service_provider_mobile_no": serviceProviderMobileNo,
    "sub_category_sno": subCategorySno,
    "pin": pin,
    "price": price,
    "vehicle_sno": vehicleSno,
    "ratings": ratings == null ? [] : List<dynamic>.from(ratings!.map((x) => x)),
    "first_name": firstName,
    "cancelreason": cancelreason,
    "pickup_location": pickupLocation?.toJson(),
    "booking_status_cd": bookingStatusCd,
    "booking_time": bookingTime?.toIso8601String(),
    "last_name": lastName,
    "booking_type_name": bookingTypeName,
    "quotation_details": quotationDetails == null
        ? []
        : List<dynamic>.from(quotationDetails!.map((x) => x.toJson())),
    "booking_person": bookingPerson,
    "service_providers_sno": serviceProvidersSno,
    "booking_status_name": bookingStatusName,
    "vehicle_number": vehicleNumber,
    "company_name": companyName,
    "user_profile_sno": userProfileSno,
    "booking_type": bookingType,
    "types_of_goods": typesOfGoods,
    "weight_type_name": weightTypeName,
    "weight_of_goods": weightOfGoods,
    "created_on": createdOn?.toIso8601String(),
  };
}

class PLocation {
  String? address;
  String? city;
  String? state;
  String? country;
  Latlng? latlng;
  String? landmark;
  String? contactInfo;

  PLocation({
    this.address,
    this.city,
    this.state,
    this.country,
    this.latlng,
    this.landmark,
    this.contactInfo,
  });

  factory PLocation.fromJson(Map<String, dynamic> json) => PLocation(
    address: json["address"] as String?,
    city: json["city"] as String?,
    state: json["state"] as String?,
    country: json["country"] as String?,
    latlng: json["latlng"] == null ? null : Latlng.fromJson(json["latlng"]),
    landmark: json["landmark"] as String?,
    contactInfo: json["contact_info"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "city": city,
    "state": state,
    "country": country,
    "latlng": latlng?.toJson(),
    "landmark": landmark,
    "contact_info": contactInfo,
  };
}

class Latlng {
  double? latitude;
  double? longitude;

  Latlng({
    this.latitude,
    this.longitude,
  });

  factory Latlng.fromJson(Map<String, dynamic> json) => Latlng(
    latitude: (json["latitude"] as num?)?.toDouble(),
    longitude: (json["longitude"] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
  };
}

class Media {
  String? mediaUrl;
  String? contentType;
  String? fileType;
  String? fileName;
  String? mediaType;
  dynamic thumbnailUrl;
  bool? isUploaded;

  Media({
    this.mediaUrl,
    this.contentType,
    this.fileType,
    this.fileName,
    this.mediaType,
    this.thumbnailUrl,
    this.isUploaded,
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    mediaUrl: json["mediaUrl"] as String?,
    contentType: json["contentType"] as String?,
    fileType: json["fileType"] as String?,
    fileName: json["fileName"] as String?,
    mediaType: json["mediaType"] as String?,
    thumbnailUrl: json["thumbnailUrl"],
    isUploaded: json["isUploaded"] as bool?,
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

class QuotationDetail {
  dynamic quotationAmount;
  dynamic priceBreakup;
  int? serviceProviderQuotationSno;

  QuotationDetail({
    this.quotationAmount,
    this.priceBreakup,
    this.serviceProviderQuotationSno,
  });

  factory QuotationDetail.fromJson(Map<String, dynamic> json) => QuotationDetail(
    quotationAmount: json["quotation_amount"],
    priceBreakup: json["price_breakup"],
    serviceProviderQuotationSno: json["service_provider_quotation_sno"] as int?,
  );

  Map<String, dynamic> toJson() => {
    "quotation_amount": quotationAmount,
    "price_breakup": priceBreakup,
    "service_provider_quotation_sno": serviceProviderQuotationSno,
  };
}
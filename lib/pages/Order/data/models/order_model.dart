// To parse this JSON data, do
//
//     final polyLineSteps = polyLineStepsFromJson(jsonString);

import 'dart:convert';

PolyLineSteps polyLineStepsFromJson(String str) =>
    PolyLineSteps.fromJson(json.decode(str));

String polyLineStepsToJson(PolyLineSteps data) => json.encode(data.toJson());

class PolyLineSteps {
  int? distanceMeters;
  String? staticDuration;
  Polylines? polyline;
  Location? startLocation;
  Location? endLocation;
  NavigationInstruction? navigationInstruction;
  LocalizedValues? localizedValues;
  String? travelMode;

  PolyLineSteps({
    this.distanceMeters,
    this.staticDuration,
    this.polyline,
    this.startLocation,
    this.endLocation,
    this.navigationInstruction,
    this.localizedValues,
    this.travelMode,
  });

  factory PolyLineSteps.fromJson(Map<String, dynamic> json) => PolyLineSteps(
        distanceMeters: json["distanceMeters"],
        staticDuration: json["staticDuration"],
        polyline: json["polyline"] == null
            ? null
            : Polylines.fromJson(json["polyline"]),
        startLocation: json["startLocation"] == null
            ? null
            : Location.fromJson(json["startLocation"]),
        endLocation: json["endLocation"] == null
            ? null
            : Location.fromJson(json["endLocation"]),
        navigationInstruction: json["navigationInstruction"] == null
            ? null
            : NavigationInstruction.fromJson(json["navigationInstruction"]),
        localizedValues: json["localizedValues"] == null
            ? null
            : LocalizedValues.fromJson(json["localizedValues"]),
        travelMode: json["travelMode"],
      );

  Map<String, dynamic> toJson() => {
        "distanceMeters": distanceMeters,
        "staticDuration": staticDuration,
        "polyline": polyline?.toJson(),
        "startLocation": startLocation?.toJson(),
        "endLocation": endLocation?.toJson(),
        "navigationInstruction": navigationInstruction?.toJson(),
        "localizedValues": localizedValues?.toJson(),
        "travelMode": travelMode,
      };
}

class Location {
  LatLngs? latLng;
  String? name;
  String? placeId;
  bool? isEditingPicking;
  String? city; // City name
  String? state; // State name
  String? country;
  Location(
      {this.latLng,
      this.name,
      this.placeId,
      this.isEditingPicking,
      this.city,
      this.state,
      this.country});
  factory Location.fromJson(Map<String, dynamic> json) => Location(
        latLng:
            json["latLng"] == null ? null : LatLngs.fromJson(json["latLng"]),
      );
  Map<String, dynamic> toJson() => {
        "latLng": latLng?.toJson(),
      };
}

class LatLngs {
  double? latitude;
  double? longitude;

  LatLngs({
    this.latitude,
    this.longitude,
  });

  factory LatLngs.fromJson(Map<String, dynamic> json) => LatLngs(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}

class LocalizedValues {
  Distance? distance;
  Distance? staticDuration;

  LocalizedValues({
    this.distance,
    this.staticDuration,
  });

  factory LocalizedValues.fromJson(Map<String, dynamic> json) =>
      LocalizedValues(
        distance: json["distance"] == null
            ? null
            : Distance.fromJson(json["distance"]),
        staticDuration: json["staticDuration"] == null
            ? null
            : Distance.fromJson(json["staticDuration"]),
      );

  Map<String, dynamic> toJson() => {
        "distance": distance?.toJson(),
        "staticDuration": staticDuration?.toJson(),
      };
}

class Distance {
  String? text;

  Distance({
    this.text,
  });

  factory Distance.fromJson(Map<String, dynamic> json) => Distance(
        text: json["text"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
      };
}

class NavigationInstruction {
  String? maneuver;
  String? instructions;

  NavigationInstruction({
    this.maneuver,
    this.instructions,
  });

  factory NavigationInstruction.fromJson(Map<String, dynamic> json) =>
      NavigationInstruction(
        maneuver: json["maneuver"],
        instructions: json["instructions"],
      );

  Map<String, dynamic> toJson() => {
        "maneuver": maneuver,
        "instructions": instructions,
      };
}

class Polylines {
  String? encodedPolyline;

  Polylines({
    this.encodedPolyline,
  });

  factory Polylines.fromJson(Map<String, dynamic> json) => Polylines(
        encodedPolyline: json["encodedPolyline"],
      );

  Map<String, dynamic> toJson() => {
        "encodedPolyline": encodedPolyline,
      };
}

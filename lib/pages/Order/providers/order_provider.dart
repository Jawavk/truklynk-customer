import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truklynk/pages/Order/providers/order_model.dart';
import '../data/models/order_model.dart';

class OrderDataProvider extends ChangeNotifier {
  Location pickup = Location(
      latLng: null,
      name: '',
      placeId: '',
      isEditingPicking: false,
      city: '',
      state: '',
      country: '');
  Location drop = Location(
      latLng: null,
      name: '',
      placeId: '',
      isEditingPicking: false,
      city: '',
      state: '',
      country: '');

  Location get getPickupLocation => pickup;
  Location get getDropLocation => drop;

  void addPickupLocation(LatLng latLng, String name, String placeId,
      bool? isEditingPicking, String? city, String? state, String? country) {
    pickup.latLng =
        LatLngs(longitude: latLng.longitude, latitude: latLng.latitude);
    pickup.name = name;
    pickup.isEditingPicking = isEditingPicking;
    pickup.city = city;
    pickup.state = state;
    pickup.country = country;
    notifyListeners();
  }

  void addDropLocation(LatLng latLng, String name, String placeId,
      isEditingPicking, String? city, String? state, String? country) {
    drop.latLng =
        LatLngs(longitude: latLng.longitude, latitude: latLng.latitude);
    drop.name = name;
    drop.isEditingPicking = isEditingPicking;
    drop.city = city;
    drop.state = state;
    drop.country = country;
    notifyListeners();
  }

  void resetPickupLocations() {
    pickup = Location(
        latLng: null,
        name: '',
        placeId: '',
        isEditingPicking: false,
        city: '',
        state: '',
        country: '');
    notifyListeners();
  }

  void resetDropupLocations() {
    drop = Location(
        latLng: null,
        name: '',
        placeId: '',
        isEditingPicking: false,
        city: '',
        state: '',
        country: '');
    notifyListeners();
  }

  PickUpData pickupInfo = PickUpData(
      pickupDate: DateTime.now(),
      totalWeight: 0,
      weightType: '',
      weightTypeSno: '',
      items: '',
      vehicleId: 0,
      notes: '',
      name: '',
      phoneNumber: '');

  PickUpData get getPickupInfo => pickupInfo;

  void addPickupInfo(PickUpData data) {
    pickupInfo = data;
    notifyListeners();
  }

  void resetPickupInfo() {
    pickupInfo = PickUpData(
        pickupDate: DateTime.now(),
        totalWeight: 0,
        weightType: '',
        weightTypeSno: '',
        items: '',
        vehicleId: 0,
        notes: '',
        name:'',
        phoneNumber: '');
    notifyListeners();
  }
}

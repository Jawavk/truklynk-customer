import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:truklynk/pages/History/data/models/cancel_booking_model.dart';
import 'package:truklynk/pages/Order/bloc/order_state.dart';
import 'package:truklynk/pages/Order/data/models/block_service_providers_model.dart';
import 'package:truklynk/pages/Order/data/models/booking_status_model.dart';
import 'package:truklynk/pages/Order/data/models/conform_booking_model.dart';
import 'package:truklynk/pages/Order/data/models/enum.dart';
import 'package:truklynk/pages/Order/data/models/service_provider_schedule_model.dart';
import 'package:truklynk/pages/Order/data/models/subcategory_model.dart';
import 'package:truklynk/services/api_service.dart';
import 'package:http/http.dart' as http;

import '../models/quotation_status_model.dart';

class OrderRepo {
  ApiService apiService = ApiService();
  final String _apiKey = 'AIzaSyCq3n0PuZCtun6j0kiLnprf0mEqgQOvGls';

  // Add this to your OrderRepo class
  String _sessionToken = '';

// Update this method to generate a new session token when needed
  void generateSessionToken() {
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<List<Suggestion>> getSuggestion(Map<String, dynamic> data) async {
    if (_sessionToken.isEmpty) {
      generateSessionToken();
    }

    final response = await http.get(
      Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': data["query"],
          'key': _apiKey,
          'components':
              'country:in', // Keep this if you only want results from India
          'sessiontoken': _sessionToken,
        },
      ),
    );
    print('data$data');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['predictions'] as List;
      final suggestions = results.where((e) {
        final description = e['description'] as String;
        return description.contains(', India'); // Check for India
      }).map((e) {
        final description = e['description'] as String;
        final parts = description.split(', '); // Split by comma

        String city = parts.length > 2
            ? parts[parts.length - 3]
            : ''; // Third last part as city
        String state = parts.length > 1
            ? parts[parts.length - 2]
            : ''; // Second last part as state
        String country =
            parts.isNotEmpty ? parts.last : ''; // Last part as country

        return Suggestion(
          name: description,
          location: null,
          placeId: e['place_id'] as String,
          isEditingPicking: false,
          city: city,
          state: state,
          country: country,
        );
      }).toList();

      // final suggestions = results.map((e) {
      //   return Suggestion(
      //       name: e['description'] as String,
      //       location: null,
      //       placeId: e['place_id'] as String,
      //       isEditingPicking: false);
      // }).toList();
      return suggestions;
    } else {
      return [];
    }
  }

  Future<LatLng?> getLatLng(Map<String, dynamic> data) async {
    final response = await http.get(
      Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/details/json',
        {
          'place_id': data["query"],
          'key': _apiKey,
        },
      ),
    );
    print('jawa$data');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('result') &&
          data['result'].containsKey('geometry')) {
        final location = data['result']['geometry']['location'];
        // Ensure 'lat' and 'lng' are present
        if (location.containsKey('lat') && location.containsKey('lng')) {
          final lat = location['lat'];
          final lng = location['lng'];
          // Create and return LatLng object
          return LatLng(lat, lng);
        } else {
          throw Exception('Latitude or longitude not found in the response');
        }
      } else {
        throw Exception('Invalid response structure');
      }
    } else {
      return null;
    }
  }

  Future<VehicleModel> getSubCategory(Map<String, dynamic> data) async {
    return VehicleModel.fromJson(await apiService
        .makeRequest(HttpMethod.get.value, 'service/subcategory', body: data));
  }

  Future<EnumModel> getEnum(Map<String, dynamic> data) async {
    return EnumModel.fromJson(await apiService
        .makeRequest(HttpMethod.get.value, 'enums', body: data));
  }

  Future<dynamic> bookVehicle(Map<String, dynamic> data) async {
    return ServiceProviderScheduleModel.fromJson(await apiService
        .makeRequest(HttpMethod.post.value, 'service/booking', body: data));
  }

  Future<dynamic> getBookingStatus(Map<String, dynamic> data) async {
    return BookingStatusModel.fromJson(await apiService
        .makeRequest(HttpMethod.get.value, 'service/quotation', body: data));
  }

  Future<dynamic> quoteConfirmation(Map<String, dynamic> data) async {
    return ConformBookingModel.fromJson(await apiService
        .makeRequest(HttpMethod.put.value, 'service/quotation', body: data));
  }

  Future<dynamic> blockServiceProvider(Map<String, dynamic> data) async {
    return BlockServiceProvidersModel.fromJson(await apiService
        .makeRequest(HttpMethod.post.value, 'service/block', body: data));
  }

  Future<CancelBookingResultModel> cancelBooking(
      Map<String, dynamic> data) async {
    return CancelBookingResultModel.fromJson(await apiService
        .makeRequest(HttpMethod.put.value, 'service/booking', body: data));
  }
}

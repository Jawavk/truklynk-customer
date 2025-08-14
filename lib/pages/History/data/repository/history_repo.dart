import 'package:truklynk/pages/History/data/models/booking_model.dart';
import 'package:truklynk/pages/History/data/models/cancel_booking_model.dart';
import 'package:truklynk/pages/History/data/models/cancel_reason_model.dart';
import 'package:truklynk/pages/History/data/models/journey_details.dart';
import 'package:truklynk/services/api_service.dart';

import '../../../Order/data/models/quotation_status_model.dart';

class HistoryRepo {
  ApiService apiService = ApiService();
  Future<BookingModel> getHistory(Map<String, dynamic> data) async {
    final response = await apiService
        .makeRequest(HttpMethod.get.value, 'service/getallbooking', body: data);

    print('Raw API response: $response');

    // Extract booking data from nested structure
    final jsonData = response["json"] as List?;
    if (jsonData?.isNotEmpty == true) {
      final firstItem = jsonData!.first as Map<String, dynamic>;
      if (firstItem.containsKey("get_all_booking")) {
        response["json"] = firstItem["get_all_booking"];
      }
    }

    return BookingModel.fromJson(response);
  }

  Future<CancelReasonModel> getCancelReason(Map<String, dynamic> data) async {
    return CancelReasonModel.fromJson(await apiService
        .makeRequest(HttpMethod.get.value, 'cancelreason', body: data));
  }

  Future<CancelBookingResultModel> cancelBooking(
      Map<String, dynamic> data) async {
    return CancelBookingResultModel.fromJson(await apiService
        .makeRequest(HttpMethod.put.value, 'service/booking', body: data));
  }

  Future<JourneyDetailsModel> getTrackOrder(Map<String, dynamic> data) async {
    return JourneyDetailsModel.fromJson(await apiService.makeRequest(
        HttpMethod.get.value, 'users/get_track_order',
        body: data));
  }

  Future<Map<String, dynamic>?> getLastVehicleLocation(int vehicleSno) async {
    try {
      final response = await apiService.makeRequest(
        HttpMethod.get.value,
        'serviceproviders/lastvehiclelocation',
        body: {
          'vehicle_sno': vehicleSno,
        },
      );
      print('response$response');

      if (response != null &&
          response['json'] != null &&
          response['json'].isNotEmpty &&
          response['json'][0]['getlastvehiclelocation'] != null) {
        return response['json'][0]['getlastvehiclelocation']
            as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching last vehicle location: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getVehicleLocationHistory(
      int vehicleSno, DateTime startDate, DateTime endDate) async {
    try {
      final response = await apiService.makeRequest(
        HttpMethod.get.value,
        'serviceproviders/vehiclelocationhistory',
        body: {
          'vehicle_sno': vehicleSno,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      if (response != null && response['data'] != null) {
        final List<dynamic> locationData = response['data'];
        return locationData
            .map((item) => item as Map<String, dynamic>)
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching vehicle location history: $e');
      return [];
    }
  }

  Future<SearchQuotationServiceProviderScheduleModel> getQuotationStatus(
      Map<String, dynamic> data) async {
    print('datas$data');
    return SearchQuotationServiceProviderScheduleModel.fromJson(
        await apiService.makeRequest(HttpMethod.put.value,
            'service/searchQuotationServiceProviderSchedule',
            body: data));
  }
}

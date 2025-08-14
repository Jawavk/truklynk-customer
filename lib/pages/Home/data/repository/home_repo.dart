import 'package:truklynk/pages/History/data/models/booking_model.dart';
import 'package:truklynk/services/api_service.dart';

class HomeRepo {
  ApiService apiService = ApiService();

  Future<BookingModel> getHistory(Map<String, dynamic> data) async {
    return BookingModel.fromJson(await apiService.makeRequest(
        HttpMethod.get.value, 'service/getallbooking',
        body: data));
  }
}

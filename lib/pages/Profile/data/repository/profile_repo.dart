import 'package:truklynk/pages/Profile/data/models/blocked_service_providers_model.dart';
import 'package:truklynk/pages/Profile/data/models/remove_service_provider_model.dart';
import 'package:truklynk/services/api_service.dart';

class ProfileRepo {
  ApiService apiService = ApiService();

  Future<BlockedServiceProvidersModel> getBlockedServiceProvider(
      Map<String, dynamic> data) async {
    return BlockedServiceProvidersModel.fromJson(await apiService.makeRequest(
        HttpMethod.get.value, 'users/blocked_service_provider',
        body: data));
  }

  Future<RemoveServiceProvidersModel> removeBlockedServiceProvider(
      Map<String, dynamic> data) async {
    return RemoveServiceProvidersModel.fromJson(await apiService.makeRequest(
        HttpMethod.put.value, 'users/remove_blocked_service_provider',
        body: data));
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> data) async {
    return await apiService.makeRequest(
      HttpMethod.put.value,
      'users/profile',
      body: data,
    );
  }

  Future<Map<String, dynamic>> getUserProfile(int userProfileSno) async {
    print('Getting profile for userProfileSno: $userProfileSno');
    final data = {"userProfileSno": userProfileSno};
    try {
      final response = await apiService
          .makeRequest(HttpMethod.get.value, 'users/getprofile', body: data);
      print('API Response: $response');
      return response;
    } catch (e) {
      print('Error in getUserProfile: $e');
      rethrow;
    }
  }

  Future<void> logOut(Map<String, dynamic> data) async {
    await apiService.makeRequest(HttpMethod.post.value, 'users/logout',
        body: data);
    return;
  }
}

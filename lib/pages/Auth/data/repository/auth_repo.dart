import 'package:truklynk/pages/Auth/data/models/auth_model.dart';
import 'package:truklynk/services/api_service.dart';

class AuthRepo {
  ApiService apiService = ApiService();
  Future<AuthModel> getOTP(Map<String, dynamic> data) async {
    return AuthModel.fromJson(await apiService
        .makeRequest(HttpMethod.post.value, 'users/verify', body: data));
  }

  Future<AuthModel> loginUser(Map<String, dynamic> data) async {
    print('data$data');
    return AuthModel.fromJson(await apiService
        .makeRequest(HttpMethod.post.value, 'users/login', body: data));
  }

  Future<AuthModel> createUser(Map<String, dynamic> data) async {
    return AuthModel.fromJson(await apiService
        .makeRequest(HttpMethod.post.value, 'users/create', body: data));
  }
}

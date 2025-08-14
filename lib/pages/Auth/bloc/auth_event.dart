abstract class AuthEvent {}

class PhoneNumberChanged extends AuthEvent {
  final String phoneNumber;
  PhoneNumberChanged({required this.phoneNumber});
}

class GenerateOTP extends AuthEvent {
  final String page;
  final String countryCode;
  final String deviceId;
  final String otpHashCode;
  final String role;
  GenerateOTP(
      {required this.page,
      required this.countryCode,
      required this.deviceId,
      required this.otpHashCode,
      required this.role});
}

class EnterOTP extends AuthEvent {
  late String otp;
  EnterOTP({required this.otp});
}

class RegisterUser extends AuthEvent {
  final String name;
  final String deviceId;
  final String OTP;
  RegisterUser(
      {required this.name,required this.deviceId, required this.OTP});
}

class LoginUser extends AuthEvent {
  final String deviceId;
  final String OTP;
  LoginUser({required this.deviceId, required this.OTP});
}

class AddUserSno extends AuthEvent {
  int? userSno;
  AddUserSno({required this.userSno});
}

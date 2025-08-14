abstract class AuthState {}

class AuthInitial extends AuthState {}

class PhoneNumberValid extends AuthState {
  final bool verifyNow;
  PhoneNumberValid({required this.verifyNow});
}

class PhoneNumberInvalid extends AuthState {
  final String errorMessage;
  PhoneNumberInvalid({required this.errorMessage});
}

class Message extends AuthState {
  final String? message;
  final int? code;
  Message({required this.message,required this.code});
}

class ShowOTP extends AuthState {}

class OTP extends AuthState {
  late String otp;
  OTP({required this.otp});
}

class ResentOTP extends AuthState {
  final int count;
  final int attempt;
  ResentOTP({required this.count, required this.attempt});
}

class NewUser extends AuthState {
  final String phoneNumber;
  final int? userSno;
  NewUser({required this.phoneNumber, required this.userSno});
}

class RegisterSuccess extends AuthState {}

class LoginSuccess extends AuthState {}

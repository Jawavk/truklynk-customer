import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/pages/Auth/bloc/auth_event.dart';
import 'package:truklynk/pages/Auth/bloc/auth_state.dart';
import 'package:truklynk/pages/Auth/data/repository/auth_repo.dart';
import 'package:truklynk/services/token_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // ignore: prefer_typing_uninitialized_variables
  String? phoneNumber;
  int? userSno;
  AuthRepo authRepo = AuthRepo();
  TokenService tokenService = TokenService();
  int attempt = 0;

  AuthBloc() : super(AuthInitial()) {
    on<PhoneNumberChanged>(_onValidPhoneNumber);
    on<GenerateOTP>(_generateOTP);
    on<EnterOTP>(_changeOTP);
    on<RegisterUser>(_registerUser);
    on<LoginUser>(_loginUser);
    on<AddUserSno>(_addUserSno);
  }

  Future<void> _onValidPhoneNumber(
    PhoneNumberChanged event,
    Emitter<AuthState> emit,
  ) async {
    final phoneNumber = event.phoneNumber;
    // Updated regex for 10 digit validation
    final phoneNumberRegex = RegExp(r'^\d{10}$');
    if (phoneNumber.length < 10) {
      emit(PhoneNumberValid(verifyNow: false));
      emit(PhoneNumberInvalid(
          errorMessage: 'Phone number must be at least 10 digits'));
    } else if (phoneNumberRegex.hasMatch(phoneNumber)) {
      this.phoneNumber = phoneNumber;
      emit(PhoneNumberValid(verifyNow: true));
    } else {
      emit(PhoneNumberValid(verifyNow: false));
      emit(PhoneNumberInvalid(errorMessage: 'Invalid phone number'));
    }
  }

  Future<void> _generateOTP(
    GenerateOTP event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // emit(Message(message: "Please Wait"));
      final otp = await authRepo.getOTP({
        "countryCode": event.countryCode,
        "device_id": event.deviceId,
        "otpHashCode": event.otpHashCode,
        "role": event.role,
        "mobileNumber": phoneNumber,
        'type': event.page
      });
      print('code${otp.json}');
      if (otp.json!.isNotEmpty && otp.json![0].verifyuser != null) {
        int code = otp.json![0].verifyuser!.code;
        print('code$code');
        if (code > 0) {
          userSno = otp.json![0].verifyuser?.usersSno;
          emit(Message(
              message: otp.json![0].verifyuser?.message,
              code: otp.json![0].verifyuser?.code));
          if (code == 1) {
            Future<void> countdownFuture = _startCountdown(emit);
            Future<void> delayedEmitFuture =
                Future.delayed(const Duration(seconds: 5), () {
              emit(OTP(otp: otp.json![0].verifyuser!.otp.toString()));
            });
            await Future.wait([countdownFuture, delayedEmitFuture]);
          }
        } else {
          print("1111");
          emit(Message(
              message: otp.json![0].verifyuser?.message ?? "Please try again",
              code: otp.json![0].verifyuser?.code));
        }
      } else {
        print("2222");
        emit(Message(message: "Please try again", code: 2));
      }
    } catch (e) {
      print("3333");
      emit(Message(message: "Please try again", code: 0));
    }
  }

  Future<void> _startCountdown(Emitter<AuthState> emit) async {
    attempt++;
    int counter = 30;
    final Completer<void> completer = Completer<void>();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter <= 0) {
        timer.cancel();
        completer.complete();
      } else {
        counter--;
        emit(ResentOTP(count: counter, attempt: attempt));
      }
    });

    await completer.future;
  }

  Future<void> _changeOTP(
    EnterOTP event,
    Emitter<AuthState> emit,
  ) async {
    emit(OTP(otp: event.otp));
    emit(PhoneNumberValid(verifyNow: true));
  }

  Future<void> _loginUser(
    LoginUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(Message(message: "Please Wait", code: 0));
    final login = await authRepo.loginUser({
      "device_id": event.deviceId,
      "mobileNumber": phoneNumber,
      "device_type": "mobile",
      "push_token": await tokenService.getFCMToken(),
      "users_sno": userSno,
      "otp": event.OTP
    });
    print('login${jsonEncode(login)}');
    if (login.json!.isNotEmpty && login.json![0].loginuser != null) {
      int code = login.json![0].loginuser!.code;
      print("codesssss $code");
      if (code > 0) {
        login.json![0].loginuser!.mobileNumber = phoneNumber;
        await tokenService
            .saveUser(login.json![0].loginuser!.toJson().toString());
        emit(Message(
            message: login.json![0].loginuser?.message,
            code: login.json![0].loginuser?.code));
        emit(LoginSuccess());
      } else {
        emit(Message(
            message: login.json![0].loginuser?.message ?? "Please try again",
            code: login.json![0].loginuser?.code));
      }
    } else {
      emit(Message(message: "Please try again", code: 0));
    }
  }

  Future<void> _registerUser(
    RegisterUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(Message(message: "Please Wait", code: 0));
    final create = await authRepo.createUser({
      "device_id": event.deviceId,
      "mobileNumber": phoneNumber,
      "name": event.name,
      "device_type": "mobile",
      "push_token": await tokenService.getFCMToken(),
      "users_sno": userSno,
      "otp": event.OTP
    });
    if (create.json!.isNotEmpty && create.json![0].createuser != null) {
      int code = create.json![0].createuser!.code;
      if (code > 0) {
        create.json![0].createuser!.mobileNumber = phoneNumber;
        await tokenService
            .saveUser(create.json![0].createuser!.toJson().toString());
        emit(Message(message: create.json![0].createuser?.message, code: 0));
        emit(RegisterSuccess());
      } else {
        emit(Message(
            message: create.json![0].createuser?.message ?? "Please try again",
            code: create.json![0].createuser?.code));
      }
    } else {
      emit(Message(message: "Please try again", code: 0));
    }
  }

  Future<void> _addUserSno(
    AddUserSno event,
    Emitter<AuthState> emit,
  ) async {
    userSno = event.userSno;
  }
}

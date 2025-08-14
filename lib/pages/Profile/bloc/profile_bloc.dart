import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truklynk/pages/Profile/bloc/profile_event.dart';
import 'package:truklynk/pages/Profile/bloc/profile_state.dart';
import 'package:truklynk/pages/Profile/data/models/blocked_service_providers_model.dart';
import 'package:truklynk/pages/Profile/data/models/remove_service_provider_model.dart';
import 'package:truklynk/pages/Profile/data/repository/profile_repo.dart';
import 'package:truklynk/services/token_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileRepo profileRepo = ProfileRepo();
  TokenService tokenService = TokenService();

  ProfileBloc() : super(ProfileInitial()) {
    on<SubmitPersonalInfo>(_onSubmitPersonalInfo);
    on<SubmitBusinessInfo>(_onSubmitBusinessInfo);
    on<PersonalInfoChangedEvent>(_onPersonalInfoChanged);
    on<BusinessInfoChangedEvent>(_onBusinessInfoChanged);
    on<CheckPageValid>(_onCheckPageValid);
    on<SubmitProfile>(_onSubmitProfile);
    on<GetUserProfile>(_onGetUserProfile);
    on<GetBlockedServiceProvider>(_onGetBlockedServiceProvider);
    on<RemoveBlockedServiceProvider>(_onRemoveBlockedServiceProvider);
    on<LogOutEvent>(_onLogOut);
  }

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is PickFile) {
      yield ProfileInitial(); // or some state to indicate file picked
    }

    if (event is SubmitBusinessInfo) {
      yield BusinessInfoSubmissionInProgress();

      // Validate inputs
      if (event.taxIdNumber.isEmpty || !_validateGST(event.taxIdNumber)) {
        yield BusinessInfoSubmissionFailure('Invalid GST number');
        return;
      }
      if (event.businessName.isEmpty) {
        yield BusinessInfoSubmissionFailure('Please enter the business name');
        return;
      }
      if (event.registeredAddress.isEmpty) {
        yield BusinessInfoSubmissionFailure(
            'Please enter the registered address');
        return;
      }

      // Simulate successful submission
      await Future.delayed(Duration(seconds: 2)); // Simulate network call
      yield BusinessInfoSubmissionSuccess();
    }
  }

  Future<void> _onSubmitPersonalInfo(
      SubmitPersonalInfo event, Emitter<ProfileState> emit) async {
    emit(PersonalInfoSubmissionInProgress());

    bool isFullNameValid = event.fullName.isNotEmpty;
    bool isEmailValid = _validateEmail(event.email);
    bool isPhoneNumberValid = _validatePhoneNumber(event.phoneNumber);

    if (isFullNameValid && isEmailValid && isPhoneNumberValid) {
      await Future.delayed(const Duration(seconds: 2));
      emit(PersonalInfoSubmissionSuccess());
    } else {
      emit(PersonalInfoValid(
        isFullNameValid: isFullNameValid,
        isEmailValid: isEmailValid,
        isPhoneNumberValid: isPhoneNumberValid,
      ));
    }
  }

  Future<void> _onSubmitBusinessInfo(
      SubmitBusinessInfo event, Emitter<ProfileState> emit) async {
    emit(BusinessInfoSubmissionInProgress());

    bool isTaxNumberValid = _validateGST(event.taxIdNumber);
    bool isBusinessNameValid = event.businessName.isNotEmpty;
    bool isRegisteredAddressValid = event.registeredAddress.isNotEmpty;

    if (isTaxNumberValid && isBusinessNameValid && isRegisteredAddressValid) {
      await Future.delayed(const Duration(seconds: 2));
      emit(BusinessInfoSubmissionSuccess());
    } else {
      emit(BusinessInfoValid(
        isTaxNumberValid: isTaxNumberValid,
        isBusinessNameValid: isBusinessNameValid,
        isRegisteredAddressValid: isRegisteredAddressValid,
      ));
    }
  }

  void _onPersonalInfoChanged(
      PersonalInfoChangedEvent event, Emitter<ProfileState> emit) {
    emit(PersonalInfoValid(
      isFullNameValid: event.fullName?.isNotEmpty ?? true,
      isEmailValid: event.email != null ? _validateEmail(event.email!) : true,
      isPhoneNumberValid: event.phoneNumber != null
          ? _validatePhoneNumber(event.phoneNumber!)
          : true,
    ));
  }

  void _onBusinessInfoChanged(
      BusinessInfoChangedEvent event, Emitter<ProfileState> emit) {
    emit(BusinessInfoValid(
      isTaxNumberValid:
          event.taxIdNumber != null ? _validateGST(event.taxIdNumber!) : true,
      isBusinessNameValid: event.businessName?.isNotEmpty ?? true,
      isRegisteredAddressValid: event.registeredAddress?.isNotEmpty ?? true,
    ));
  }

  Future<void> _onSubmitProfile(
      SubmitProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileAndDocumentsSubmissionInProgress());
    try {
      print('event.data${event.data}');
      final result = await profileRepo.updateUserProfile(event.data);
      if (result['isSuccess']) {
        emit(ProfileAndDocumentsSubmissionSuccess());
        final userProfileSno = event.data['profile']['user_profile_sno'];
        if (userProfileSno != null) {
          add(GetUserProfile(userProfileSno: userProfileSno));
        }
      } else {
        emit(ProfileAndDocumentsSubmissionFailure(
            result['message'] ?? 'Update failed'));
      }
    } catch (e) {
      emit(ProfileAndDocumentsSubmissionFailure('Error: $e'));
    }
  }

  Future<void> _onGetUserProfile(
      GetUserProfile event, Emitter<ProfileState> emit) async {
    emit(LoadingState());
    try {
      final result = await profileRepo.getUserProfile(event.userProfileSno);
      print('Raw API response: $result');

      // Handle the nested structure
      if (result['json'] != null && result['json'].isNotEmpty) {
        final getuserprofile = result['json'][0]['getuserprofile'];

        if (getuserprofile['isSuccess'] == true) {
          // Combine profile and documents into one map
          final profileData = {
            'profile': getuserprofile['profile'],
            'documents': getuserprofile['documents'],
          };

          print('Processed profile data: $profileData');
          emit(UserProfileLoadedState(profileData: profileData));
        } else {
          emit(ProfileAndDocumentsSubmissionFailure(
              getuserprofile['message'] ?? 'Failed to load profile'));
        }
      } else {
        emit(
            ProfileAndDocumentsSubmissionFailure('Invalid response structure'));
      }
    } catch (e) {
      print('Error in _onGetUserProfile: $e');
      emit(ProfileAndDocumentsSubmissionFailure('Error: $e'));
    }
  }

  bool _validateEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  bool _validatePhoneNumber(String phoneNumber) {
    return phoneNumber.length == 10 && RegExp(r'^\d+$').hasMatch(phoneNumber);
  }

  bool _validateGST(String gstNumber) {
    final gstRegex =
        RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    return gstRegex.hasMatch(gstNumber);
  }

  Future<void> _onCheckPageValid(
      CheckPageValid event, Emitter<ProfileState> emit) async {
    emit(CheckPageValidState(isCheckPageValid: event.pageInvalid));
  }

  Future<void> _onGetBlockedServiceProvider(
      GetBlockedServiceProvider event, Emitter<ProfileState> emit) async {
    emit(LoadingState());
    BlockedServiceProvidersModel result = await profileRepo
        .getBlockedServiceProvider({"user_sno": event.userSno});
    if (result.isSuccess) {
      emit(GetBlockedServiceProviderState(
          blockedServiceProviders: result.json ?? []));
    }
  }

  Future<void> _onRemoveBlockedServiceProvider(
      RemoveBlockedServiceProvider event, Emitter<ProfileState> emit) async {
    RemoveServiceProvidersModel result = await profileRepo
        .removeBlockedServiceProvider(
            {"blockServiceProvidersSno": event.blockServiceProvidersSno});
    if (result.isSuccess) {
      if (result.json!.isNotEmpty) {
        add(GetBlockedServiceProvider(userSno: event.userSno));
      }
    }
  }

  Future<void> _onLogOut(LogOutEvent event, Emitter<ProfileState> emit) async {
    await profileRepo.logOut(
        {"signinconfig_sno": event.signinconfigsno, "status": event.status});
    tokenService.clearUser();
    emit(LogOutState());
  }
}

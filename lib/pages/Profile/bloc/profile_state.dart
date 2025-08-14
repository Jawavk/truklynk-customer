import 'package:truklynk/pages/Profile/data/models/blocked_service_providers_model.dart';

abstract class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class PersonalInfoValid extends ProfileState {
  final bool isFullNameValid;
  final bool isEmailValid;
  final bool isPhoneNumberValid;

  PersonalInfoValid({
    required this.isFullNameValid,
    required this.isEmailValid,
    required this.isPhoneNumberValid,
  });
  bool get isPersonalInfoFormValid =>
      isFullNameValid && isEmailValid && isPhoneNumberValid;
}

final class BusinessInfoValid extends ProfileState {
  final bool isTaxNumberValid;
  final bool isBusinessNameValid;
  final bool isRegisteredAddressValid;

  BusinessInfoValid({
    required this.isTaxNumberValid,
    required this.isBusinessNameValid,
    required this.isRegisteredAddressValid,
  });

  bool get isBusinessInfoFormValid =>
      isTaxNumberValid && isBusinessNameValid && isRegisteredAddressValid;
}

final class PersonalInfoSubmissionInProgress extends ProfileState {}

final class PersonalInfoSubmissionSuccess extends ProfileState {}

final class PersonalInfoSubmissionFailure extends ProfileState {
  final String errorMessage;

  PersonalInfoSubmissionFailure(this.errorMessage);
}

final class BusinessInfoSubmissionInProgress extends ProfileState {}

final class BusinessInfoSubmissionSuccess extends ProfileState {}

final class BusinessInfoSubmissionFailure extends ProfileState {
  final String errorMessage;

  BusinessInfoSubmissionFailure(this.errorMessage);
}

class CheckPageValidState extends ProfileState {
  final bool isCheckPageValid;
  CheckPageValidState({required this.isCheckPageValid});
}

class LoadingState extends ProfileState {}

class GetBlockedServiceProviderState extends ProfileState {
  List<BlockedServiceProviders> blockedServiceProviders;
  GetBlockedServiceProviderState({required this.blockedServiceProviders});
}

final class ProfileAndDocumentsSubmissionFailure extends ProfileState {
  final String errorMessage;
  ProfileAndDocumentsSubmissionFailure(this.errorMessage);
}

final class ProfileAndDocumentsSubmissionSuccess extends ProfileState {}

final class ProfileAndDocumentsSubmissionInProgress extends ProfileState {}

class LogOutState extends ProfileState {
  LogOutState();
}

class UserProfileLoadedState extends ProfileState {
  final Map<String, dynamic> profileData;
  UserProfileLoadedState({required this.profileData});
}

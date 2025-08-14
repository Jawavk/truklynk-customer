import 'dart:io';

abstract class ProfileEvent {}

class SubmitPersonalInfo extends ProfileEvent {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String countryCode;

  SubmitPersonalInfo({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.countryCode,
  });
}

class SubmitProfile extends ProfileEvent {
  final Map<String, dynamic> data;
  SubmitProfile(this.data);
}

class SubmitBusinessInfo extends ProfileEvent {
  final String taxIdNumber;
  final String businessName;
  final String registeredAddress;

  SubmitBusinessInfo({
    required this.taxIdNumber,
    required this.businessName,
    required this.registeredAddress,
  });
}


class GetUserProfile extends ProfileEvent {
  final int userProfileSno;
  GetUserProfile({required this.userProfileSno});
}

class PickFile extends ProfileEvent {
  final File file;
  PickFile(this.file);
}

// Event for when form field changes
class PersonalInfoChangedEvent extends ProfileEvent {
  final String? fullName;
  final String? email;
  final String? phoneNumber;

  PersonalInfoChangedEvent({this.fullName, this.email, this.phoneNumber});
}

class BusinessInfoChangedEvent extends ProfileEvent {
  final String? taxIdNumber;
  final String? businessName;
  final String? registeredAddress;

  BusinessInfoChangedEvent(
      {this.taxIdNumber, this.businessName, this.registeredAddress});
}

class CheckPageValid extends ProfileEvent {
  final bool pageInvalid;
  CheckPageValid({required this.pageInvalid});
}

class GetBlockedServiceProvider extends ProfileEvent {
  dynamic userSno;
  GetBlockedServiceProvider({required this.userSno});
}

class RemoveBlockedServiceProvider extends ProfileEvent {
  int blockServiceProvidersSno;
  dynamic userSno;
  RemoveBlockedServiceProvider(
      {required this.blockServiceProvidersSno, required this.userSno});
}

class LogOutEvent extends ProfileEvent {
  int signinconfigsno;
  int status;
  LogOutEvent({required this.signinconfigsno, required this.status});
}
